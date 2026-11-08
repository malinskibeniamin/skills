#!/usr/bin/env python3
"""Prepare pinned priority-skill updates with trusted importers; never execute upstream code."""
import argparse
import html
import hashlib
import os
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath
from urllib.parse import quote


# No workflow inputs can substitute a repository, executable, or upstream ref.
SOURCES = (
    ('pstack', 'cursor/plugins', 'poteto', 'pstack', ('pstack/',)),
    ('mattpocock', 'mattpocock/skills', 'mattpocock', 'mattpocock', ('skills/', 'LICENSE', 'README.md')),
    ('t3code', 'pingdotgg/t3code', 't3code-skills', 't3code-skills',
     ('.agents/skills/', '.repos/effect-smol/.agents/skills/', 'LICENSE', '.repos/effect-smol/LICENSE')),
    ('tstack', 't3dotgg/tstack', 'tstack', 'tstack', ('skills/', 'LICENSE', 'README.md')),
    ('emil', 'emilkowalski/skills', 'emil', 'emil',
     ('skills/', 'LICENSE', 'README.md', 'performance-cheatsheet.md', 'ui-cheatsheet.md')),
)
EMIL = ('animate', 'remove-animations', 'improve-animations', 'animation-performance',
        'animation-vocabulary', 'mobile-native', 'break-ui', 'ask-sonner', 'gestures')
REPORT = 'reports/skill-updates.md'
BRANCH = 'ben-malinski/maintenance/priority-skill-updates'


def run(command, **kwargs):
    result = subprocess.run(command, capture_output=True, timeout=180, check=False, **kwargs)
    if result.returncode:
        raise ValueError(f'{command[0]} failed: {result.stderr.decode(errors="replace")[-1800:].strip()}')
    return result.stdout


def git(root, *args, **kwargs):
    return run(['git', '-c', 'core.hooksPath=/dev/null', '-C', str(root), *args], **kwargs)


def sha(value):
    if not isinstance(value, str) or not re.fullmatch(r'[0-9a-f]{40}', value):
        raise ValueError('Expected full lowercase commit SHA')
    return value


def inventory(source, revision, watched):
    sha(revision)
    if git(source, 'rev-parse', '--verify', f'{revision}^{{commit}}').decode().strip() != revision:
        raise ValueError('Revision must directly identify a commit')
    entries = {}
    for record in git(source, 'ls-tree', '-rz', revision).split(b'\0'):
        if not record:
            continue
        metadata, raw_path = record.split(b'\t', 1)
        path = raw_path.decode('utf-8')
        if any(path.startswith(p) if p.endswith('/') else path == p for p in watched):
            mode, kind, oid = metadata.decode().split()
            if (kind != 'blob' or mode not in ('100644', '100755') or
                    PurePosixPath(path).is_absolute() or '..' in PurePosixPath(path).parts):
                raise ValueError(f'Unsafe upstream entry: {path}')
            entries[path] = (mode, oid)
    if not entries:
        raise ValueError('No watched source files; refusing empty snapshot')
    return entries


def materialize_pstack(source, revision, destination):
    entries = inventory(source, revision, ('pstack/',))
    total, names = 0, set()
    for path, (mode, oid) in entries.items():
        relative = path.removeprefix('pstack/')
        if relative.casefold() in names:
            raise ValueError('Case-colliding upstream paths')
        names.add(relative.casefold())
        size = int(git(source, 'cat-file', '-s', oid))
        total += size
        if size > 5_000_000 or total > 50_000_000 or len(entries) > 20_000:
            raise ValueError('pstack snapshot exceeds safety limit')
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(git(source, 'cat-file', 'blob', oid))
        target.chmod(int(mode[-3:], 8))
    return destination


def changed_paths(candidate, base):
    return [p.decode() for p in git(candidate, 'diff', '--name-only', '--no-renames', '-z', base).split(b'\0') if p]


def guard(candidate, base):
    prefixes = ('vendor/pstack/', 'vendor/mattpocock/', 'vendor/t3code/', 'vendor/tstack/', 'vendor/emil/',
                'poteto-skills/', 'matt-skills/', 't3code-skills/', 'tstack-skills/', 'codex-skills/')
    files = {REPORT, '.claude-plugin/plugin.json', 'ask-ben/SKILL-CATALOG.md',
             *(f'vendor/{s[3]}.lock.json' for s in SOURCES), *(f'{name}/LICENSE' for name in EMIL)}
    for path in changed_paths(candidate, base):
        if path not in files and not path.startswith(prefixes):
            raise ValueError(f'Protected local path changed: {path}')
        target = candidate / path
        if target.is_symlink() and not target.resolve().is_relative_to(candidate):
            raise ValueError(f'Generated link escapes candidate: {path}')
    manifest = '.claude-plugin/plugin.json'
    if (candidate / manifest).exists():
        before = json.loads(git(candidate, 'show', f'{base}:{manifest}'))
        after = json.loads((candidate / manifest).read_bytes())
        managed = ('./poteto-skills/', './matt-skills/', './t3code-skills/', './tstack-skills/')
        for data in (before, after):
            data['skills'] = [s for s in data['skills'] if not s.startswith(managed)]
        if before != after:
            raise ValueError('Importer changed non-managed plugin policy or registrations')


def refresh(root, sources, apply):
    base = sha(git(root, 'rev-parse', 'HEAD').decode().strip())
    if apply and git(root, 'status', '--porcelain'):
        raise ValueError('--apply requires a clean checkout; preserve local work first')
    results = []
    with tempfile.TemporaryDirectory(prefix='priority-skill-refresh-') as temporary:
        temporary = Path(temporary)
        candidate = temporary / 'candidate'
        run(['git', '-c', 'core.hooksPath=/dev/null', 'clone', '--quiet', '--shared', '--no-checkout', str(root), str(candidate)])
        git(candidate, 'checkout', '--quiet', '--detach', base)
        for name, repository, importer, lock_name, watched in SOURCES:
            checkpoint = git(candidate, 'rev-parse', 'HEAD').decode().strip()
            record = {'name': name, 'repository': f'https://github.com/{repository}', 'status': 'blocked'}
            results.append(record)
            try:
                lock = json.loads((candidate / f'vendor/{lock_name}.lock.json').read_bytes())
                if lock['repository'] != record['repository']:
                    raise ValueError('Lock repository differs from trusted source')
                before = sha(lock['revision'])
                record['before'] = before
                helper = root / f'scripts/vendor-{importer}.py'
                run([sys.executable, str(helper), '--repo-root', str(candidate), '--check'])
                record['checked'] = True
                if sources:
                    source = sources / name
                    revision = sha(git(source, 'rev-parse', 'refs/heads/main^{commit}').decode().strip())
                else:
                    source = temporary / f'{name}.git'
                    git(temporary, 'init', '--quiet', '--bare', str(source))
                    url = record['repository'] + '.git'
                    git(source, 'fetch', '--quiet', '--depth=1', url, before)
                    git(source, 'fetch', '--quiet', '--depth=1', url, 'refs/heads/main')
                    revision = sha(git(source, 'rev-parse', 'FETCH_HEAD^{commit}').decode().strip())
                record['after'] = revision
                # Include T3 support/policy files previously reached through relative links.
                if name == 't3code':
                    watched = (*watched, *(p.removesuffix('.upstream') for p in lock['files']))
                old_inputs, new_inputs = inventory(source, before, watched), inventory(source, revision, watched)
                record['inputs'] = hashlib.sha256(json.dumps([old_inputs, new_inputs], sort_keys=True).encode()).hexdigest()
                if old_inputs == new_inputs:
                    record['status'] = 'unchanged'
                    continue
                materialized = materialize_pstack(source, revision, temporary / 'pstack') if name == 'pstack' else source
                run([sys.executable, str(helper), '--repo-root', str(candidate),
                     '--source', str(materialized), '--revision', revision])
                run([sys.executable, str(helper), '--repo-root', str(candidate), '--check'])
                git(candidate, 'add', '--force', '-A')
                guard(candidate, base)
                git(candidate, '-c', 'user.name=Skill updater', '-c', 'user.email=skill-updater@localhost',
                    'commit', '--quiet', '-m', f'chore(upstreams): refresh {name}')
                record['status'] = 'updated'
            except (ValueError, OSError, KeyError, TypeError, subprocess.TimeoutExpired) as error:
                git(candidate, 'reset', '--hard', '--quiet', checkpoint)
                git(candidate, 'clean', '-fdqx')
                record['error'] = str(error)
        blocked = any(r['status'] == 'blocked' for r in results)
        changed = any(r['status'] == 'updated' for r in results)
        lines = ['# Priority skill updates', '',
                 'Pinned upstream data only; local owners and host policies are retained. No approval or merge.', '',
                 '| Source | Status | Pinned comparison | Candidate |', '| --- | --- | --- | --- |']
        for r in results:
            proposed = r.get('after') if r['status'] != 'unchanged' else r.get('before')
            comparison = (f"[compare]({r['repository']}/compare/{r['before']}...{proposed})"
                          if proposed else 'Fetch/integrity check blocked')
            lines.append(f"| {r['name']} | {r['status']} | {comparison} | `{proposed or 'unavailable'}` |")
        if blocked:
            lines += ['', '## Compatibility blockers', '', 'Do not merge as fully refreshed. Keep guards intact; reconcile these sources, then rerun.']
            for r in results:
                if r.get('error'):
                    lines += ['', f"### {r['name']}", '', '<pre>' + html.escape(r['error']) + '</pre>']
        report = '\n'.join(lines) + '\n'
        if changed or blocked:
            target = candidate / REPORT
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(report)
        run(['bash', str(candidate / 'scripts/generate-skill-catalog.sh')], cwd=candidate)
        git(candidate, 'add', '--force', '-A')
        guard(candidate, base)
        paths = changed_paths(candidate, base)
        patch = git(candidate, 'diff', '--binary', '--full-index', base)
        if paths:
            # Validate a clean checkout of the staged tree, not just pre-staging bytes.
            git(candidate, '-c', 'user.name=Skill updater', '-c', 'user.email=skill-updater@localhost',
                'commit', '--quiet', '-m', 'chore(upstreams): validate staged refresh')
            verified = temporary / 'verified'
            run(['git', '-c', 'core.hooksPath=/dev/null', 'clone', '--quiet', '--shared', str(candidate), str(verified)])
            for source_record, spec in zip(results, SOURCES):
                if source_record.get('checked'):
                    run([sys.executable, str(root / f'scripts/vendor-{spec[2]}.py'),
                         '--repo-root', str(verified), '--check'])
        fingerprint = hashlib.sha256(patch).hexdigest()
        if apply and paths:
            if git(root, 'status', '--porcelain') or git(root, 'rev-parse', 'HEAD').decode().strip() != base:
                raise ValueError('Checkout changed during refresh; nothing applied')
            git(root, 'apply', '--check', '--binary', '-', input=patch)
            git(root, 'apply', '--binary', '-', input=patch)
    recipe = hashlib.sha256(b''.join((root / f'scripts/vendor-{s[2]}.py').read_bytes() for s in SOURCES) +
                            (root / 'scripts/generate-skill-catalog.sh').read_bytes() + Path(__file__).read_bytes()).hexdigest()
    inputs = hashlib.sha256(json.dumps([recipe, [{k: r.get(k) for k in ('name', 'status', 'inputs')} for r in results]], sort_keys=True).encode()).hexdigest()
    return {'input_fingerprint': inputs, 'status': 'blocked' if blocked else 'changed' if paths else 'unchanged',
            'sources': results, 'paths': paths, 'report': report, 'base': base, 'fingerprint': fingerprint}


MESSAGE = 'chore(upstreams): refresh priority skills'
BOT = 'github-actions[bot]'


def api(repository, method, route, payload=None, paginate=False):
    command = ['gh', 'api', '--method', method, '--hostname', 'github.com', f'repos/{repository}/{route}'.rstrip('/'),
               '-H', 'Accept: application/vnd.github+json', '-H', 'X-GitHub-Api-Version: 2026-03-10']
    if paginate:
        command += ['--paginate', '--slurp']
    if payload is not None:
        command += ['--input', '-']
    output = run(command, input=json.dumps(payload).encode() if payload is not None else None)
    return json.loads(output) if output.strip() else None


def publish(root, result, repository, base):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+', repository or ''):
        raise ValueError('--repository must be owner/repository')
    if api(repository, 'GET', '')['default_branch'] != base:
        raise ValueError('Publication targets the trusted default branch only')
    base_route = 'git/ref/heads/' + quote(base, safe='')
    if api(repository, 'GET', base_route)['object']['sha'] != result['base']:
        raise ValueError('Default branch moved; rerun from a fresh checkout')
    if not result['paths']:
        return {'status': 'unchanged'}
    marker = '<!-- priority-skill-refresh:' + result['fingerprint'] + ' -->'
    input_marker = '<!-- priority-skill-inputs:' + result['input_fingerprint'] + ' -->'
    pull_route = 'pulls?state=all&per_page=100&head=' + quote(repository.split('/')[0] + ':' + BRANCH, safe='')
    def history():
        return [p for page in api(repository, 'GET', pull_route, paginate=True) for p in page
                if p['head']['repo'] and p['head']['repo']['full_name'].lower() == repository.lower()
                and p['head']['ref'] == BRANCH]
    pulls = history()
    for pull in pulls:
        if pull['state'] == 'closed' and input_marker in (pull['body'] or ''):
            return {'status': 'dismissed', 'url': pull['html_url']}
    opened = [p for p in pulls if p['state'] == 'open']
    if len(opened) > 1:
        raise ValueError('Multiple automation PRs; refusing ambiguous ownership')
    existing = opened[0] if opened else None
    if existing and (not existing['draft'] or existing['base']['ref'] != base or
                     existing.get('user', {}).get('login') != BOT):
        raise ValueError('PR is no longer a bot-owned draft; preserving the human handoff')
    refs = api(repository, 'GET', 'git/matching-refs/heads/' + quote(BRANCH, safe=''))
    matching = [r for r in refs if r['ref'] == 'refs/heads/' + BRANCH]
    expected = sha(matching[0]['object']['sha']) if matching else ''
    previous = None
    if expected:
        previous = api(repository, 'GET', 'commits/' + expected)
        if ((previous.get('author') or {}).get('login') != BOT or (previous.get('committer') or {}).get('login') != BOT
                or not previous['commit']['message'].startswith(MESSAGE + '\n\n<!-- priority-skill-refresh:')):
            raise ValueError('Automation branch has foreign commits; preserving work, never overwrite')
    elif existing:
        raise ValueError('Open automation PR has lost its branch; inspect before recovery')
    equivalent = (existing and previous and input_marker in (existing['body'] or '') and
                  input_marker in previous['commit']['message'] and
                  [p['sha'] for p in previous['parents']] == [result['base']])
    if equivalent:
        # Keep the already-proposed immutable pins/body when only upstream app commits moved.
        observed = confirm_draft(repository, existing['number'], expected, base)
        dispatch_checks(repository, expected)
        return {'status': 'existing', 'url': observed['html_url'], 'head': expected, 'equivalent_inputs': True}
    # Compare the exact candidate before staging: even a concurrent edit to an allowed file is not ours.
    git(root, 'add', '--force', '-A', '--', *result['paths'])
    guard(root, result['base'])
    actual = hashlib.sha256(git(root, 'diff', '--binary', '--full-index', result['base'])).hexdigest()
    if actual != result['fingerprint'] or git(root, 'rev-parse', 'HEAD').decode().strip() != result['base']:
        raise ValueError('Candidate changed after refresh; refusing publication')
    same = (previous and marker in previous['commit']['message'] and
            [p['sha'] for p in previous['parents']] == [result['base']])
    if same:
        commit = expected
    else:
        tree = sha(git(root, 'write-tree').decode().strip())
        env = {**os.environ, 'GIT_AUTHOR_NAME': BOT, 'GIT_COMMITTER_NAME': BOT,
               'GIT_AUTHOR_EMAIL': '41898282+github-actions[bot]@users.noreply.github.com',
               'GIT_COMMITTER_EMAIL': '41898282+github-actions[bot]@users.noreply.github.com'}
        commit = sha(git(root, 'commit-tree', tree, '-p', result['base'], input=(MESSAGE+'\n\n'+marker+'\n'+input_marker+'\n').encode(), env=env).decode().strip())
        if api(repository, 'GET', base_route)['object']['sha'] != result['base']:
            raise ValueError('Default branch moved during publication; rerun')
        # Explicit expected-head lease: neither unknown branches nor concurrent human pushes can be overwritten.
        try:
            git(root, '-c', 'credential.helper=', '-c', 'credential.helper=!gh auth git-credential',
                'push', '--porcelain', f'https://github.com/{repository}.git', f'{commit}:refs/heads/{BRANCH}',
                f'--force-with-lease=refs/heads/{BRANCH}:{expected}')
        except (ValueError, OSError, subprocess.TimeoutExpired):
            observed = api(repository, 'GET', 'git/ref/heads/' + quote(BRANCH, safe=''))
            if observed['object']['sha'] != commit:
                raise ValueError('Push not confirmed or lease lost; preserve remote work and rerun')
    body = ('Lane: Quality of life — remove manual priority-skill fetching.\n\n' + marker + '\n' + input_marker + '\n\n' + result['report'] +
            '\n## Evidence\nTrusted importer integrity and generated catalog checks ran; full evals are dispatched on this head.\n'
            '\n## Risk and rollback\nUpstream content is untrusted data. Compatibility blockers must be resolved before merge. '
            'No host policy replacement, approval, or merge. Revert this PR to restore prior pins.\n')
    if existing:
        if existing['body'] != body:
            api(repository, 'PATCH', f"pulls/{existing['number']}", {'body': body})
        created = existing
    else:
        try:
            created = api(repository, 'POST', 'pulls', {'title': MESSAGE, 'head': BRANCH, 'base': base, 'draft': True, 'body': body})
        except (ValueError, OSError, subprocess.TimeoutExpired) as error:
            recovered = [p for p in history() if p['state'] == 'open' and p['head']['sha'] == commit]
            if not recovered:
                raise ValueError('Draft creation not confirmed. GitHub must allow Actions to create PRs '
                                 '(Actions > General > Workflow permissions); inspect the branch before retrying: ' + str(error)) from error
            created = recovered[0]
    observed = confirm_draft(repository, created['number'], commit, base)
    dispatch_checks(repository, commit)
    return {'status': 'existing' if same and existing else 'published', 'url': observed['html_url'], 'head': commit}


def confirm_draft(repository, number, commit, base):
    observed = api(repository, 'GET', f'pulls/{number}')
    if (observed['state'] != 'open' or not observed['draft'] or observed['head']['sha'] != commit
            or observed['base']['ref'] != base or observed['head']['ref'] != BRANCH
            or not observed['head']['repo'] or observed['head']['repo']['full_name'].lower() != repository.lower()):
        raise ValueError('Draft readback differs from expected head/base; inspect before recovery')
    return observed


def dispatch_checks(repository, commit):
    # GITHUB_TOKEN cannot reliably start PR checks without a manual approval. Explicit dispatch can.
    runs = api(repository, 'GET', 'actions/workflows/evals.yml/runs?event=workflow_dispatch&head_sha=' + commit)
    if not runs['workflow_runs']:
        api(repository, 'POST', 'actions/workflows/evals.yml/dispatches', {'ref': BRANCH})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo-root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--sources', type=Path, help='Offline Git stores, one directory per source name; never used by the workflow')
    parser.add_argument('--apply', action='store_true', help='Apply managed output to a clean checkout; default is read-only')
    parser.add_argument('--publish', action='store_true', help='Apply and publish one bot-owned draft; dispatch its existing evals workflow')
    parser.add_argument('--repository', help='Destination owner/repository (publication only)')
    parser.add_argument('--base', default='main')
    args = parser.parse_args()
    if args.publish and args.sources:
        parser.error('Offline source overrides cannot publish')
    root = args.repo_root.resolve()
    result = refresh(root, args.sources.resolve() if args.sources else None, args.apply or args.publish)
    if args.publish:
        try:
            result['publication'] = publish(root, result, args.repository, args.base)
        except (ValueError, OSError, KeyError, TypeError, subprocess.TimeoutExpired) as error:
            result['publication'] = {'status': 'failed', 'error': str(error)}
            print(json.dumps(result))
            raise
    print(json.dumps(result))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError, subprocess.TimeoutExpired) as error:
        print(f'Skill refresh failed: {error}', file=sys.stderr)
        sys.exit(1)
