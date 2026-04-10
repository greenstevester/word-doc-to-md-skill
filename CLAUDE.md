# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code skill plugin that converts `.docx` files into clean, agent/LLM-readable Markdown. Single Go binary, cross-platform (Windows/macOS/Linux), zero external dependencies. Auto-bootstraps pandoc on first run.

## Repository Structure

```
.claude-plugin/
  marketplace.json         # Plugin registry metadata (required for Claude Code)
  plugin.json              # Basic plugin config (name, version, author)
skills/
  convert-docx/
    SKILL.md               # Skill definition with frontmatter + instructions
go.mod                     # Go module (docx-to-agent-md)
main.go                    # CLI routing, arg parsing, shared utilities
bootstrap.go               # Platform detection, pandoc download + extract
convert.go                 # Orchestrator: bootstrap → pandoc → postprocess
postprocess.go             # 5 sequential regex/line transforms
postprocess_test.go        # Table-driven tests for all transforms
```

## Build and Test

```bash
go build -o docx-to-md .
go test -v ./...
```

Cross-compile:
```bash
GOOS=linux   GOARCH=amd64 go build -o docx-to-md-linux .
GOOS=darwin  GOARCH=arm64 go build -o docx-to-md-macos .
GOOS=windows GOARCH=amd64 go build -o docx-to-md.exe .
```

## Testing the Skill

No build step for the skill itself. To test changes:
1. Quick test: `claude --plugin-dir /path/to/docx-to-agent-md`
2. Full install test:
   ```
   /plugin marketplace remove docx-to-agent-md
   /plugin marketplace add /path/to/docx-to-agent-md
   /plugin install convert-docx@docx-to-agent-md
   ```
3. Ask Claude "Convert this Word doc to markdown" with a `.docx` file nearby

## Architecture

**Pipeline flow:** `convert()` → `bootstrap()` → pandoc subprocess → `postprocess()`

**Postprocess transforms (in order):** tracked-changes → heading-hierarchy → tables → images → blank-lines. Transform 2 (heading hierarchy) is two-pass (find min level, then shift). All others are single-pass regex or line filters.

**Bootstrap flow:** `detectPlatform()` via `runtime.GOOS/GOARCH` → `assetForPlatform()` → HTTP download to temp file → extract from tar.gz or zip (stdlib only) → place in `bin/`.

## Key Details

- **Pandoc version:** `defaultPandocVersion` constant in `main.go` (currently `3.9.0.2`)
- **Binary location:** `bin/pandoc` (or `bin/pandoc.exe`) relative to CWD — gitignored
- **Zero external deps:** Only Go stdlib
- **Windows compat:** `runtime.GOOS` replaces `uname`, `os.CreateTemp` replaces `mktemp`, `isExecutable()` checks file existence on Windows
- **Line endings:** `postprocess()` normalizes `\r\n` → `\n` before transforms

## When Modifying

- Skill SKILL.md is user-facing documentation and executable instructions combined
- Shell commands in `` !`backticks` `` run during skill execution (environment checks)
- Keep version in sync across `plugin.json`, `marketplace.json`, and skill entries
- Test with both fresh runs (no `bin/`) and cached runs (pandoc already downloaded)
