#!/usr/bin/env bash
# Date        : 2026-11-25
# Description : Start the fallback orchestration stack when the Claude Code
#               session has hit its usage limit. Launches GitHub Copilot CLI
#               (gpt-6.2-astra) as the orchestrator in interactive mode. The
#               orchestrator delegates lecture-material edits to Codex CLI
#               (gpt-6.1-terra) as the worker, following the rules in CLAUDE.md.
# File        : start-fallback-orchestrator.sh
# Usage       : bash code/agent/2026-11-25/start-fallback-orchestrator.sh

set -euo pipefail

# Run from the repository root so that Copilot loads CLAUDE.md and AGENTS.md
# and so that the relative paths in the prompt below resolve.
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

# The prompt only points at the rule files and the handoff file. The rules
# themselves live in CLAUDE.md so that there is a single copy to maintain.
PROMPT='Claude 세션이 사용 한계로 멈췄다. 너는 이 저장소의 대체 경로 오케스트레이터다.
1. CLAUDE.md 의 "오케스트레이션 규칙" 절 전체(특히 "세션 한계 시 대체 경로")를 읽고 따른다.
2. memory/orchestration-handoff.md 와 git status, git diff 를 읽어 현재 상태를 파악한다.
3. 인계 파일의 active 를 fallback 으로, updated_by 를 copilot 으로 바꾸고 updated 를 현재 시각으로 갱신한다.
4. 인계 파일의 "다음 단계"부터 작업을 이어간다. 남은 작업이 없으면 그 사실만 보고하고 멈춘다.'

# Interactive mode (-i) keeps the user in the approval loop for tool calls.
exec copilot --model gpt-6.2-astra -i "$PROMPT"
