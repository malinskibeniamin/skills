#!/usr/bin/env python3
"""Check hosted PR-body evidence presence, not diagram correctness or skip eligibility."""

import re
import sys
from urllib.parse import urlsplit


def has_visual(body: str) -> bool:
    body = re.sub(r"<!--.*?(?:-->|\Z)", "", body.replace("\r\n", "\n").replace("\r", "\n"), flags=re.S)
    # Ignore examples inside non-Mermaid fences and incomplete diagram fences.
    fence = re.compile(r"^ {0,3}(`{3,}|~{3,})([^\n]*)\n", re.M)
    prose = []
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
                return True
        cursor = match.end() + close.end()
    prose.append(body[cursor:])
    visible = re.sub(r"`[^`\n]*`", "", "".join(prose))
    # Exceptions are public assertions; the author/review owns their truth.
    if re.search(r"^Visual evidence: not applicable [—-] \S.*$", visible, re.M):
        return True
    urls = re.findall(r"!\[[^\]\n]*\]\(<?(https://[^\s)>]+)", visible)
    urls += re.findall(r'<(?:img|video)\b[^>]*\bsrc=[\"\'](https://[^\"\']+)', visible, re.I)
    # GitHub's native video uploads render from a standalone attachment URL.
    urls += re.findall(r"^https://github\.com/user-attachments/assets/[^\s<]+$", visible, re.M)
    for url in urls:
        try:
            host = urlsplit(url).hostname
        except ValueError:
            continue
        if host and host not in {"localhost", "127.0.0.1", "::1"} and not host.endswith(".localhost"):
            return True
    return False


if __name__ == "__main__":
    if not has_visual(sys.stdin.read()):
        sys.exit(
            "Missing PR visual evidence. Add a hosted screenshot/video or an inline "
            "architecture/sequence diagram (Mermaid works without Excalidraw). "
            "Backend/API/Protobuf/contract changes without explanatory captures need a diagram. "
            "Only out-of-scope changes may use 'Visual evidence: not applicable — <concrete reason>'. "
            "Follow excalidraw-diagram/PR-WORKFLOW.md."
        )
