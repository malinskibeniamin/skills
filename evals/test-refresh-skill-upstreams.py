"""Public CLI contracts: real Git trees; trusted importer boundaries stubbed offline."""
import json
import os
import subprocess
import shutil
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/refresh-skill-upstreams.py'
SOURCES = {
    'pstack': ('cursor/plugins', 'poteto', 'pstack', 'pstack/skills/example/SKILL.md'),
    'mattpocock': ('mattpocock/skills', 'mattpocock', 'mattpocock', 'skills/example/SKILL.md'),
    't3code': ('pingdotgg/t3code', 't3code-skills', 't3code-skills', '.agents/skills/example/SKILL.md'),
    'tstack': ('t3dotgg/tstack', 'tstack', 'tstack', 'skills/example/SKILL.md'),
    'emil': ('emilkowalski/skills', 'emil', 'emil', 'skills/example/SKILL.md'),
}


class RefreshTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.sources = self.root / 'sources'
        self.sources.mkdir()
        self.repo.mkdir()
        self.init(self.repo)
        self.before = {}
        self.after = {}
        for name, (remote, importer, lock, skill) in SOURCES.items():
            source = self.sources / name
            source.mkdir()
            self.init(source)
            self.write(source, skill, 'Old skill\n')
            self.before[name] = self.commit(source)
            self.write(source, skill, 'New skill\n')
            self.after[name] = self.commit(source)
            self.write(self.repo, f'vendor/{lock}.lock.json', json.dumps({
                'repository': f'https://github.com/{remote}', 'revision': self.before[name], 'files': {}}))
            self.write(self.repo, f'vendor/{name}/snapshot', 'Old snapshot\n')
            # Trusted destination helper, not an upstream script. Its CLI matches the real importer.
            self.write(self.repo, f'scripts/vendor-{importer}.py', f'''import argparse,json
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--repo-root',type=Path);p.add_argument('--source');p.add_argument('--revision');p.add_argument('--check',action='store_true')
a=p.parse_args()
if not a.check:
    lock=a.repo_root/'vendor/{lock}.lock.json'
    data=json.loads(lock.read_text());data['revision']=a.revision
    lock.write_text(json.dumps(data)+'\\n')
    (a.repo_root/'vendor/{name}/snapshot').write_text('Imported '+a.revision+'\\n')
''')
        self.write(self.repo, 'scripts/generate-skill-catalog.sh', '#!/bin/bash\nset -eu\n')
        self.write(self.repo, 'CLAUDE.md', 'Local execution policy\n')
        self.write(self.repo, 'animate/SKILL.md', 'Local Emil adaptation\n')
        self.base = self.commit(self.repo)

    def init(self, root):
        self.git(root, 'init', '-q', '-b', 'main')
        self.git(root, 'config', 'user.name', 'Fixture')
        self.git(root, 'config', 'user.email', 'fixture@example.com')

    def write(self, root, path, value):
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(value)
        return target

    def git(self, root, *args):
        return subprocess.check_output(['git', '-C', str(root), *args], text=True).strip()

    def commit(self, root):
        self.git(root, 'add', '.')
        self.git(root, 'commit', '-qm', 'fixture')
        return self.git(root, 'rev-parse', 'HEAD')

    def cli(self, *args, env=None):
        return subprocess.run(['python3', str(SCRIPT), '--repo-root', str(self.repo),
                               '--sources', str(self.sources), *args], capture_output=True, text=True, env=env)

    def result(self, *args, env=None):
        result = self.cli(*args, env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_five_sources_are_pinned_and_applied_without_executing_upstream(self):
        # A source helper is data, not an executable dependency of the refresh.
        self.write(self.sources/'emil', 'skills/example/run.sh', f'touch {self.root}/PWNED\n')
        self.after['emil'] = self.commit(self.sources/'emil')
        result = self.result('--apply')
        self.assertEqual(result['status'], 'changed')
        self.assertEqual({s['name'] for s in result['sources']}, set(SOURCES))
        for name, (_, _, lock, _) in SOURCES.items():
            data = json.loads((self.repo/f'vendor/{lock}.lock.json').read_text())
            self.assertEqual(data['revision'], self.after[name])
            self.assertEqual((self.repo/f'vendor/{name}/snapshot').read_text(), 'Imported '+self.after[name]+'\n')
        self.assertEqual((self.repo/'CLAUDE.md').read_text(), 'Local execution policy\n')
        self.assertEqual((self.repo/'animate/SKILL.md').read_text(), 'Local Emil adaptation\n')
        self.assertFalse((self.root/'PWNED').exists())
        self.assertIn(self.after['pstack'], (self.repo/'reports/skill-updates.md').read_text())

    def test_dry_run_leaves_checkout_untouched(self):
        self.assertEqual(self.result()['status'], 'changed')
        self.assertEqual(self.git(self.repo, 'status', '--porcelain'), '')

    def test_app_only_churn_and_repeat_run_do_not_propose_updates(self):
        self.result('--apply')
        self.commit(self.repo)
        for name in SOURCES:
            self.write(self.sources/name, 'app.ts', 'Not a skill update')
            self.commit(self.sources/name)
        result = self.result('--apply')
        self.assertEqual(result['status'], 'unchanged')
        self.assertEqual(result['paths'], [])
        self.assertEqual(self.git(self.repo, 'status', '--porcelain'), '')

    def test_dirty_apply_refuses_without_losing_work(self):
        self.write(self.repo, 'CLAUDE.md', 'User changes')
        result = self.cli('--apply')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('clean checkout', result.stderr)
        self.assertEqual((self.repo/'CLAUDE.md').read_text(), 'User changes')
        self.assertFalse((self.repo/'reports/skill-updates.md').exists())

    def test_unsafe_symlink_blocks_only_its_source_and_is_visible(self):
        (self.sources/'pstack/pstack/skills/escape').symlink_to('/etc/passwd')
        self.commit(self.sources/'pstack')
        result = self.result('--apply')
        self.assertEqual(result['status'], 'blocked')
        self.assertEqual([s['name'] for s in result['sources'] if s['status']=='blocked'], ['pstack'])
        self.assertIn('Unsafe upstream entry', result['sources'][0]['error'])
        lock = json.loads((self.repo/'vendor/pstack.lock.json').read_text())
        self.assertEqual(lock['revision'], self.before['pstack'])
        self.assertIn('Compatibility blockers', (self.repo/'reports/skill-updates.md').read_text())
        self.assertEqual(result['sources'][1]['status'], 'updated')

    def test_protected_changes_roll_back_source_instead_of_copying_policy(self):
        helper = self.repo/'scripts/vendor-poteto.py'
        helper.write_text(helper.read_text()+"\nif not a.check: (a.repo_root/'CLAUDE.md').write_text('Overwritten')\n")
        self.commit(self.repo)
        result = self.result('--apply')
        self.assertEqual(result['status'], 'blocked')
        self.assertIn('Protected local path', result['sources'][0]['error'])
        self.assertEqual((self.repo/'CLAUDE.md').read_text(), 'Local execution policy\n')
        self.assertEqual((self.repo/'vendor/pstack/snapshot').read_text(), 'Old snapshot\n')

    def transport(self, **overrides):
        remote = self.root/'remote.git'
        self.git(self.root, 'clone', '--quiet', '--bare', str(self.repo), str(remote))
        state = self.root/'github.json'
        state.write_text(json.dumps({'pulls': [], 'calls': [], **overrides}))
        config = self.write(self.root, 'gitconfig', f'[url "{remote}"]\n    insteadOf = https://github.com/fixture/skills.git\n')
        gh = self.write(self.root, 'bin/gh', r'''#!/usr/bin/env python3
import json,os,subprocess,sys
from pathlib import Path
file=Path(os.environ['FAKE_GITHUB_STATE']);state=json.loads(file.read_text())
args=sys.argv[1:]; method=args[args.index('--method')+1];route=args[args.index('--hostname')+2].split('repos/fixture/skills/',1)[-1]
from urllib.parse import unquote
route=unquote(route)
payload=json.load(sys.stdin) if '--input' in args else None
state['calls'].append({'method':method,'route':route,'payload':payload})
remote=os.environ['FAKE_REMOTE']
def git(*args):
    return subprocess.check_output(['git','-C',remote,*args],text=True).strip()
def ref(branch):
    result=subprocess.run(['git','-C',remote,'rev-parse','--verify',branch],capture_output=True,text=True)
    return result.stdout.strip() if result.returncode==0 else None
if route=='repos/fixture/skills': result={'default_branch':'main'}
elif route.startswith('git/ref/heads/'):
    result={'object':{'sha':ref(route.removeprefix('git/ref/heads/'))}}
elif route.startswith('git/matching-refs/'):
    head=ref('refs/heads/ben-malinski/maintenance/priority-skill-updates')
    result=[{'ref':'refs/heads/ben-malinski/maintenance/priority-skill-updates','object':{'sha':head}}] if head else []
elif route.startswith('commits/'):
    sha=route.split('/')[-1]
    email=git('show','-s','--format=%ce',sha)
    login='github-actions[bot]' if email.startswith('41898282+') else 'human'
    result={'author':{'login':login},'committer':{'login':login},'commit':{'message':git('show','-s','--format=%B',sha)},
            'parents':[{'sha':p} for p in git('show','-s','--format=%P',sha).split()]}
elif route.startswith('pulls?'): result=[state['pulls']]
elif route=='pulls' and method=='POST':
    result={'number':7,'html_url':'https://github.com/fixture/skills/pull/7','state':'open','draft':payload['draft'],
        'body':payload['body'],'user':{'login':'github-actions[bot]'},'head':{'ref':payload['head'],'sha':ref(payload['head']),'repo':{'full_name':'fixture/skills'}},'base':{'ref':payload['base']}}
    state['pulls'].append(result)
elif route.startswith('pulls/'):
    result=state['pulls'][0];result['head']['sha']=ref(result['head']['ref'])
    if method=='PATCH': result.update(payload)
elif '/runs?' in route: result={'workflow_runs':[r for r in state.get('runs',[]) if r['head_sha'] in route]}
elif route.endswith('/dispatches'): result=None;state['runs']=[{'head_sha':ref(payload['ref'])}]
elif route.startswith('pulls/') and method=='PATCH': result=state['pulls'][0]
else: raise SystemExit('Unexpected API call '+route)
file.write_text(json.dumps(state))
if state.get('lost_create') and route=='pulls' and method=='POST': raise SystemExit('lost response')
if result is not None: print(json.dumps(result))
''')
        gh.chmod(0o755)
        for name,(repository,_,_,_) in SOURCES.items():
            with config.open('a') as f: f.write(f'[url "{self.sources/name}"]\n    insteadOf = https://github.com/{repository}.git\n')
        self.state, self.remote = state, remote
        return {**os.environ, 'PATH':f'{gh.parent}:{os.environ["PATH"]}', 'GIT_CONFIG_GLOBAL':str(config),
                'FAKE_GITHUB_STATE':str(state),'FAKE_REMOTE':str(remote)}

    def hosted(self, env):
        return subprocess.run(['python3',str(SCRIPT),'--repo-root',str(self.repo),'--publish','--repository','fixture/skills'],
                              env=env,capture_output=True,text=True)

    def test_offline_overrides_cannot_publish(self):
        env=self.transport()
        # Offline overrides are never accepted by hosted publication. Fetch URL rewrites model fixed remotes.
        result=self.cli('--publish','--repository','fixture/skills',env=env)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('offline', result.stderr.lower())

    def test_publishes_one_draft_and_dispatches_ci_without_an_approval_click(self):
        env=self.transport()
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        result=json.loads(result.stdout)
        self.assertEqual(result['publication']['status'],'published')
        state=json.loads(self.state.read_text())
        self.assertEqual(len(state['pulls']),1)
        self.assertIs(state['pulls'][0]['draft'],True)
        self.assertEqual(state['pulls'][0]['base']['ref'],'main')
        self.assertTrue(any(c['route'].endswith('/dispatches') for c in state['calls']))
        # A fresh scheduled run still starts from trusted main, not its prior update branch.
        self.git(self.repo,'reset','--hard',self.base)
        self.git(self.repo,'clean','-fdq')
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(json.loads(result.stdout)['publication']['status'],'existing')
        state=json.loads(self.state.read_text())
        self.assertEqual(len(state['pulls']),1)
        self.assertEqual(sum(c['route'].endswith('/dispatches') for c in state['calls']),1)

    def reset_for_schedule(self):
        self.git(self.repo,'reset','--hard',self.base)
        self.git(self.repo,'clean','-fdq')

    def test_new_updates_reuse_the_draft_with_one_commit_on_current_base(self):
        env=self.transport()
        first=self.hosted(env)
        self.assertEqual(first.returncode,0,first.stderr)
        old=json.loads(first.stdout)['publication']['head']
        self.reset_for_schedule()
        self.write(self.sources/'emil','skills/example/SKILL.md','Newer Emil skill')
        self.commit(self.sources/'emil')
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        head=json.loads(result.stdout)['publication']['head']
        self.assertNotEqual(head,old)
        self.assertEqual(self.git(self.remote,'rev-list','--count',f'{self.base}..{head}'),'1')
        self.assertEqual(self.git(self.remote,'show','-s','--format=%P',head),self.base)
        self.assertEqual(len(json.loads(self.state.read_text())['pulls']),1)

    def test_human_branch_edit_is_preserved(self):
        env=self.transport()
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        head=json.loads(result.stdout)['publication']['head']
        tree=self.git(self.remote,'rev-parse',head+'^{tree}')
        human=self.git(self.repo,'commit-tree',tree,'-p',head,'-m','Human repair')
        branch='refs/heads/ben-malinski/maintenance/priority-skill-updates'
        self.git(self.repo,'push','--quiet',str(self.remote),f'{human}:{branch}')
        self.reset_for_schedule()
        result=self.hosted(env)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('foreign commits',result.stderr)
        self.assertEqual(self.git(self.remote,'rev-parse',branch),human)

    def test_lost_pr_creation_response_is_read_back_not_replayed(self):
        env=self.transport(lost_create=True)
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        calls=json.loads(self.state.read_text())['calls']
        self.assertEqual(sum(c['method']=='POST' and c['route']=='pulls' for c in calls),1)
        self.assertEqual(json.loads(result.stdout)['publication']['status'],'published')

    def test_dismissed_snapshot_is_not_reopened(self):
        env=self.transport()
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        state=json.loads(self.state.read_text());state['pulls'][0]['state']='closed';self.state.write_text(json.dumps(state))
        self.reset_for_schedule()
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(json.loads(result.stdout)['publication']['status'],'dismissed')
        self.assertEqual(len(json.loads(self.state.read_text())['pulls']),1)


    def test_snapshot_gitignore_cannot_hide_required_imported_resources(self):
        helper=self.repo/'scripts/vendor-emil.py'
        helper.write_text(helper.read_text()+"\nif not a.check:\n    (a.repo_root/'vendor/emil/.gitignore').write_text('resource.txt\\n')\n    (a.repo_root/'vendor/emil/resource.txt').write_text('Required source resource')\n")
        self.commit(self.repo)
        result=self.result('--apply')
        self.assertEqual(result['status'],'changed')
        self.assertEqual((self.repo/'vendor/emil/resource.txt').read_text(),'Required source resource')

    def test_emil_refresh_can_retain_the_gestures_license_without_replacing_its_owner(self):
        self.write(self.repo, 'gestures/SKILL.md', 'Local gesture adaptation\n')
        helper = self.repo/'scripts/vendor-emil.py'
        helper.write_text(helper.read_text()+"\nif not a.check:\n    (a.repo_root/'gestures/LICENSE').write_text('Retained Emil license\\n')\n")
        self.commit(self.repo)
        result = self.result('--apply')
        self.assertEqual(next(s for s in result['sources'] if s['name'] == 'emil')['status'], 'updated')
        self.assertEqual((self.repo/'gestures/LICENSE').read_text(), 'Retained Emil license\n')
        self.assertEqual((self.repo/'gestures/SKILL.md').read_text(), 'Local gesture adaptation\n')

    def test_explicit_lease_preserves_a_concurrent_push_after_ownership_check(self):
        env=self.transport()
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        old=json.loads(result.stdout)['publication']['head']
        tree=self.git(self.remote,'rev-parse',old+'^{tree}')
        human=self.git(self.repo,'commit-tree',tree,'-p',old,'-m','Concurrent human repair')
        self.git(self.repo,'push','--quiet',str(self.remote),f'{human}:refs/heads/race-object')
        self.reset_for_schedule()
        self.write(self.sources/'emil','skills/example/SKILL.md','Newer candidate')
        self.commit(self.sources/'emil')
        real_git=shutil.which('git')
        wrapper=self.write(self.root,'bin/git',f'''#!/usr/bin/env python3
import os,sys
args=sys.argv[1:]
if 'push' in args:
    import subprocess
    subprocess.check_call([{real_git!r},'-C',{str(self.remote)!r},'update-ref','refs/heads/ben-malinski/maintenance/priority-skill-updates',{human!r}])
os.execv({real_git!r},[{real_git!r},*args])
''')
        wrapper.chmod(0o755)
        result=self.hosted(env)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('lease lost',result.stderr)
        self.assertEqual(self.git(self.remote,'rev-parse','refs/heads/ben-malinski/maintenance/priority-skill-updates'),human)

    def test_shallow_trusted_checkout_is_supported(self):
        shallow=self.root/'shallow'
        self.git(self.root,'clone','--quiet','--depth=1',self.repo.as_uri(),str(shallow))
        result=subprocess.run(['python3',str(SCRIPT),'--repo-root',str(shallow),'--sources',str(self.sources),'--apply'],capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(json.loads(result.stdout)['status'],'changed')

    def test_app_only_churn_neither_rewrites_pending_draft_nor_undoes_dismissal(self):
        env=self.transport()
        first=self.hosted(env)
        self.assertEqual(first.returncode,0,first.stderr)
        head=json.loads(first.stdout)['publication']['head']
        self.reset_for_schedule()
        self.write(self.sources/'emil','application-only.ts','Not a skill')
        self.commit(self.sources/'emil')
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(json.loads(result.stdout)['publication']['head'],head)
        state=json.loads(self.state.read_text())
        self.assertEqual(sum(c['route'].endswith('/dispatches') for c in state['calls']),1)
        state['pulls'][0]['state']='closed';self.state.write_text(json.dumps(state))
        self.reset_for_schedule()
        self.write(self.sources/'emil','application-only.ts','Still not a skill')
        self.commit(self.sources/'emil')
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(json.loads(result.stdout)['publication']['status'],'dismissed')
        self.assertEqual(len(json.loads(self.state.read_text())['pulls']),1)

    def test_real_matt_importer_retains_crlf_through_staging_and_clean_checkout(self):
        source=self.sources/'mattpocock'
        self.git(source,'config','core.autocrlf','false')
        self.write(source,'LICENSE','MIT fixture license')
        self.write(source,'README.md','Fixture source')
        self.write(source,'skills/example/SKILL.md','---\nname: example\ndescription: Fixture skill\n---\n# Example\n')
        baseline=self.commit(source)
        self.write(self.repo,'.claude-plugin/plugin.json',json.dumps({'skills':[]}))
        self.write(self.repo,'.gitattributes',(SCRIPT.parents[1]/'.gitattributes').read_text())
        shutil.rmtree(self.repo/'vendor/mattpocock')
        (self.repo/'vendor/mattpocock.lock.json').unlink()
        helper=self.repo/'scripts/vendor-mattpocock.py'
        shutil.copyfile(SCRIPT.parent/'vendor-mattpocock.py',helper)
        command=['python3',str(helper),'--repo-root',str(self.repo)]
        subprocess.run([*command,'--source',str(source),'--revision',baseline],check=True,capture_output=True)
        self.commit(self.repo)
        expected=b'first\r\nsecond\r\n'
        (source/'skills/example/resource.txt').write_bytes(expected)
        self.commit(source)
        result=self.result('--apply')
        self.assertEqual(result['status'],'changed')
        path='vendor/mattpocock/upstream/skills/example/resource.txt'
        self.assertEqual((self.repo/path).read_bytes(),expected)
        self.commit(self.repo)
        checkout=self.root/'clean-clone'
        self.git(self.root,'clone','--quiet',str(self.repo),str(checkout))
        self.assertEqual((checkout/path).read_bytes(),expected)
        result=subprocess.run(['python3',str(helper),'--repo-root',str(checkout),'--check'],capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stderr)

    def test_base_advance_rebases_owned_draft_without_accumulating_commits(self):
        env=self.transport()
        first=self.hosted(env)
        self.assertEqual(first.returncode,0,first.stderr)
        old=json.loads(first.stdout)['publication']['head']
        self.reset_for_schedule()
        self.write(self.repo,'new-main-file.txt','Concurrent main improvement')
        base=self.commit(self.repo)
        self.git(self.repo,'push','--quiet',str(self.remote),f'{base}:refs/heads/main')
        result=self.hosted(env)
        self.assertEqual(result.returncode,0,result.stderr)
        head=json.loads(result.stdout)['publication']['head']
        self.assertNotEqual(head,old)
        self.assertEqual(self.git(self.remote,'show','-s','--format=%P',head),base)
        self.assertEqual(self.git(self.remote,'show',head+':new-main-file.txt'),'Concurrent main improvement')
        self.assertEqual(self.git(self.remote,'rev-list','--count',f'{base}..{head}'),'1')
        self.assertEqual(len(json.loads(self.state.read_text())['pulls']),1)


if __name__ == '__main__':
    unittest.main()
