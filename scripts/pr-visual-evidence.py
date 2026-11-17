#!/usr/bin/env python3
"""Check hosted PR evidence and explicit UI packaging declarations, not semantic truth."""

import re
import sys
from urllib.parse import urlsplit


def visible_body(body: str) -> tuple[str, bool]:
    body = re.sub(r"<!--.*?(?:-->|\Z)", "", body.replace("\r\n", "\n").replace("\r", "\n"), flags=re.S)
    # Ignore examples inside non-Mermaid fences and incomplete diagram fences.
    fence = re.compile(r"^ {0,3}(`{3,}|~{3,})([^\n]*)\n", re.M)
    prose = []
    diagram = False
    cursor = 0
    while match := fence.search(body, cursor):
        prose.append(body[cursor : match.start()])
        marker = match[1]
        close = re.search(
            rf"^ {{0,3}}{re.escape(marker[0])}{{{len(marker)},}}[ \t]*$",
            body[match.end() :],
            re.M,
        )
        if not close:
            cursor = len(body)
            break
        content = body[match.end() : match.end() + close.start()].strip()
        if match[2].strip() == "mermaid":
            content = re.sub(r"\A---\n.*?\n---(?:\n|$)", "", content, count=1, flags=re.S)
            lines = [
                line.strip()
                for line in content.splitlines()
                if line.strip() and not line.lstrip().startswith("%%")
            ]
            # Require more than a bare header; the target renderer owns syntax.
            if len(lines) > 1 or (lines and re.search(r";\s*\S", lines[0])):
                diagram = True
        cursor = match.end() + close.end()
    prose.append(body[cursor:])
    visible = re.sub(r"`[^`\n]*`", "", "".join(prose))
    return visible, diagram


def hosted(url: str) -> bool:
    try:
        parsed = urlsplit(url)
        host = parsed.hostname
    except ValueError:
        return False
    return bool(
        parsed.scheme == "https" and host
        and host not in {"localhost", "127.0.0.1", "::1", "0.0.0.0"}
        and not host.endswith(".localhost") and not parsed.username
    )


def has_packaging(visible: str) -> bool:
    declarations = re.findall(r"^UI packaging: (.+)$", visible, re.M)
    if len(declarations) != 1:
        return False
    declaration = declarations[0].strip()
    # Scope and owner approval remain reviewable assertions, not machine proof.
    if re.fullmatch(r"not applicable [—-] \S.*", declaration):
        return True
    if re.fullmatch(r"waived [—-] \S.*; approval: \S.*", declaration):
        return True
    if not re.fullmatch(r"https://[^\s<>]+", declaration) or not hosted(declaration):
        return False
    path = urlsplit(declaration).path.lower()
    recording = path.endswith((".mp4", ".webm", ".mov", ".m4v")) or bool(
        re.fullmatch(r"https://github\.com/user-attachments/assets/[a-zA-Z0-9-]+", declaration)
    )
    return recording and declaration in media_urls(visible)


def has_visual(body: str) -> bool:
    visible, diagram = visible_body(body)
    if diagram:
        return True
    # Exceptions are public assertions; the author/review owns their truth.
    if re.search(r"^Visual evidence: not applicable [—-] \S.*$", visible, re.M):
        return True
    return any(hosted(url) for url in media_urls(visible))


def media_urls(visible: str) -> list[str]:
    urls = re.findall(r"!\[[^\]\n]*\]\(<?(https://[^\s)>]+)", visible)
    urls += re.findall(r'<(?:img|video)\b[^>]*\bsrc=[\"\'](https://[^\"\']+)', visible, re.I)
    # GitHub's native video uploads render from a standalone attachment URL.
    urls += re.findall(r"^https://github\.com/user-attachments/assets/[^\s<]+$", visible, re.M)
    return urls



if __name__ == "__main__":
    body = sys.stdin.read()
    if not has_packaging(visible_body(body)[0]):
        sys.exit(
            "Missing PR visual evidence: declare and display 'UI packaging: <hosted recording URL>' "
            "for every consumer/end-user-facing UI PR, including mixed changes and follow-ups. "
            "Screenshots and diagrams do not replace a packaged recording. Non-UI PRs must use "
            "'UI packaging: not applicable — <concrete non-UI reason>'; an explicit owner waiver "
            "uses 'UI packaging: waived — <reason>; approval: <reference>'. "
            "Follow package-my-work/PACKAGING.md#per-pr-delivery."
        )
    if not has_visual(body):
        sys.exit(
            "Missing PR visual evidence. Add a hosted screenshot/video or an inline "
            "architecture/sequence diagram (Mermaid works without Excalidraw). "
            "Backend/API/Protobuf/contract changes without explanatory captures need a diagram. "
            "Only out-of-scope changes may use 'Visual evidence: not applicable — <concrete reason>'. "
            "Follow excalidraw-diagram/PR-WORKFLOW.md."
        )
