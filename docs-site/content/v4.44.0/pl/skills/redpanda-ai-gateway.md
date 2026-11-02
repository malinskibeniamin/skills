---
title: /redpanda-ai-gateway
description: Uruchamiaj Claude i Codex przez Redpanda AI Gateway za pomocą rpk ai.
type: skill
sidebar:
  label: /redpanda-ai-gateway
---
![Diagram umiejętności /redpanda-ai-gateway](/diagrams/skills/redpanda-ai-gateway.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/redpanda-ai-gateway.excalidraw)

Izolowana nakładka na interfejs wiersza poleceń Agentic Data Plane: komunikuj się z dostawcami LLM przez Redpanda AI Gateway zamiast bezpośrednio przez ich interfejsy API. Aplikacje komputerowe (Claude/Codex/ChatGPT) nadal działają bez zmian — ta umiejętność obejmuje tylko jawne wywołania przez bramę. Dokumentacja: https://docs.redpanda.com/agentic-data-plane/cli/

## Konfiguracja (raz na każdym komputerze)

```bash
rpk ai install                 # install the ai plugin into rpk
rpk cloud login --no-profile   # Redpanda Cloud auth (prerequisite)
rpk ai auth login              # OAuth device flow; credentials cached at ~/.rpai/credentials
rpk ai env list                # environments available to you
rpk ai env use <environment>   # pick one (independent of rpk cloud sessions)
rpk ai llm list                # verify: providers visible = auth works
```

Brama lokalna (bez chmury): `rpk ai env add local --ai-gateway-url http://localhost:8090 --auth-mode none`

## Uruchamianie interfejsu wiersza poleceń AI przez bramę

Wszystko po `--` jest przekazywane bez zmian do narzędzia bazowego:

```bash
rpk ai run claude --llmprovider claude-code-enterprise-local
rpk ai run claude --llmprovider claude-code-enterprise-local -- --dangerously-skip-permissions   # ONLY in sandboxed/throwaway envs: this disables Claude Code approval prompts
rpk ai run codex  --llmprovider <provider-name> -- exec -s read-only "<prompt>"
```

Wybierz `--llmprovider` z `rpk ai llm list` (`-o json|yaml|wide`, aby wyświetlić szczegóły; `RPAI_FORMAT` ustawia format domyślny). W razie potrzeby zastąp klaster: `rpk ai --rpai-endpoint https://aigw.<cluster-id>.clusters.cloud.redpanda.com ...`

## Zarządzanie dostawcami i zasobami

Każde z poleceń `rpk ai llm|mcp|oauth-provider|oauth-client|agent` obsługuje operacje `create|get|list|update|delete`; `rpk ai model` jest katalogiem tylko do odczytu.

```bash
rpk ai llm create --name openai --type openai --api-key-ref OPENAI_API_KEY
```

Klucze są zawsze *odwołaniami* do sekretów — interfejs wiersza poleceń nigdy nie przyjmuje surowego klucza API. Nigdy go nie wklejaj.

## Diagnozowanie błędów

- Nieznane polecenie `rpk ai` → uruchom `rpk ai install`, a następnie spróbuj ponownie.
- Błąd 401 lub wygaśnięcie poświadczeń → ponownie uruchom `rpk ai auth login` (poświadczenia bramy są niezależne od `rpk cloud`).
- Brak dostawcy w `rpk ai llm list` → wybrano niewłaściwe środowisko (`rpk ai env use`) lub dostawca nie został utworzony w tym środowisku.
- Ta umiejętność nie zmienia zasad routingu modeli: Claude lub Codex uruchomiony przez bramę nadal jest traktowany jako model bazowy na potrzeby przeglądu między modelami.
