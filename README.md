# docx-to-agent-md

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Cross-platform](https://img.shields.io/badge/Platform-Win%20%7C%20macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)

> **Word doc in, clean agent-readable Markdown out.** One command, any platform.

## How It Works

This is a **Claude Code skill** — you install it once, and Claude can convert Word documents for you on demand. There's nothing to build or configure.

### Lazy Loading: Nothing Downloads Until You Need It

When you install this skill, **no binaries are downloaded**. Everything is fetched on-demand:

1. **First time you use the skill** — the `docx-to-md` binary (~2.5 MB) is downloaded for your specific platform (macOS/Linux/Windows, Intel/ARM) from [GitHub Releases](https://github.com/greenstevester/word-doc-to-md-skill-go/releases)
2. **First time you convert a `.docx`** — pandoc (~30 MB) is downloaded automatically

Both are cached permanently in the **skill's plugin directory** (next to the binary, not in your project). You only download once.

### Where Things Are Stored

```
~/.claude/plugins/docx-to-agent-md/     # skill plugin directory
  install.sh                              # platform-aware installer
  docx-to-md                              # converter binary (downloaded on first use)
  bin/
    pandoc                                # pandoc binary (downloaded on first conversion)
    .pandoc-version                       # tracks installed pandoc version
  skills/
    convert-docx/
      SKILL.md                            # skill instructions
```

Everything lives inside the plugin directory. **Nothing is added to your PATH or your project directories.**

### Pandoc Updates

Pandoc does the heavy lifting for the `.docx` parsing. When a new version of this skill ships with a newer pandoc version:

- On your next conversion, the tool detects the version mismatch
- It prints: `Pandoc update available: 3.9.0.2 -> 3.x.x`
- It automatically downloads the new version — no action needed from you

To force a pandoc re-download manually:
```bash
rm -rf ~/.claude/plugins/docx-to-agent-md/bin
# pandoc re-downloads on next conversion
```

## Installation

```
/plugin marketplace add greenstevester/docx-to-agent-md
```

Restart Claude Code. That's it — no build tools, no Go, no pandoc to install.

**Verify:** Ask Claude "Convert this Word doc to markdown" with a `.docx` file nearby.

## Usage

**Just ask Claude naturally:**
```
"Convert this Word doc to markdown"
"Make requirements.docx agent-readable"
"Clean up this Word-exported markdown"
```

**Or use the binary directly:**
```bash
./docx-to-md document.docx                      # convert, output to document.md
./docx-to-md document.docx output/clean.md       # explicit output path
./docx-to-md document.docx --stdout | your-tool  # pipe to another tool
./docx-to-md postprocess raw.md cleaned.md        # clean existing markdown (no pandoc)
```

## What Gets Cleaned

| # | Transform | What It Does |
|---|-----------|-------------|
| 1 | **Tracked changes** | Accepts insertions, drops deletions and comment markers |
| 2 | **Heading hierarchy** | Shifts so doc starts at H1 with no gaps |
| 3 | **Tables** | Removes empty rows and `+----+----+` grid dividers |
| 4 | **Images** | Replaces broken file refs with `[IMAGE: alt text]` |
| 5 | **Blank lines** | Collapses runs of 2+ blank lines to one |

## Platform Support

| OS | Architecture | Status |
|----|-------------|--------|
| macOS | Apple Silicon (M1-M4) | Supported |
| macOS | Intel | Supported |
| Linux | x86_64 | Supported |
| Linux | ARM64 | Supported |
| Windows | x86_64 | Supported |
| Windows | ARM64 | Supported |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Skills not loading | Restart Claude Code after install |
| `pandoc binary not found` | Run `./docx-to-md bootstrap` to trigger re-download |
| Proxy blocks download | Set `HTTPS_PROXY` env var |
| Legacy `.doc` file | Pre-convert: `libreoffice --headless --convert-to docx` |
| Want a different pandoc version | `./docx-to-md bootstrap 3.x.x` |

## Update

```
/plugin marketplace update docx-to-agent-md
```

This pulls the latest skill (including any newer pandoc version). The next conversion auto-upgrades pandoc if needed.

## Related

- [word-doc-to-md-skill-go](https://github.com/greenstevester/word-doc-to-md-skill-go) — Go source code and cross-platform binaries

## License

MIT
