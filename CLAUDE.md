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
install.sh                 # Platform-aware binary installer (downloads from Go repo releases)
```

The `docx-to-md` binary is NOT committed — it is downloaded on first use by `install.sh` from [greenstevester/word-doc-to-md-skill-go](https://github.com/greenstevester/word-doc-to-md-skill-go) releases.

## Binary Distribution

- Go source and build infrastructure live in the `-go` repo
- Releases are built via GoReleaser, producing archives named `docx-to-md_{version}_{os}_{arch}.tar.gz` (or `.zip` for Windows)
- `install.sh` detects the user's OS/arch, fetches the latest release, and extracts the binary into the plugin directory
- The binary is gitignored — each user downloads the correct platform binary

## Testing the Skill

To test changes:
1. Quick test: `claude --plugin-dir /path/to/word-doc-to-md-skill`
2. Full install test:
   ```
   /plugin marketplace remove word-doc-to-md-skill
   /plugin marketplace add /path/to/word-doc-to-md-skill
   /plugin install convert-docx@word-doc-to-md-skill
   ```
3. Ask Claude "Convert this Word doc to markdown" with a `.docx` file nearby

## When Modifying

- Skill SKILL.md is user-facing documentation and executable instructions combined
- Shell commands in `` !`backticks` `` run during skill execution (environment checks)
- Keep version in sync across `plugin.json`, `marketplace.json`, and skill entries
- To update the binary: make changes in the `-go` repo, push to main, let the release workflow run, then `install.sh` will pick up the new version
