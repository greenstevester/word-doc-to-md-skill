# word-doc-to-md-skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Cross-platform](https://img.shields.io/badge/Platform-Win%20%7C%20macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)

> **Word doc in, clean agent-readable Markdown out.** One command, any platform.

## Why this skill?

Pasting a Word doc into Claude (or any LLM) usually ends in noise:

| Without this skill | With this skill |
|--------------------|-----------------|
| Tracked changes leak through as `[text]{.insertion}` | Insertions accepted, deletions and comments dropped |
| Tables come through as `+----+----+` grid garbage | Clean pipe tables |
| Image refs are broken file paths the model can't read | `[IMAGE: alt text]` placeholders |
| Heading levels jump (H3 → H5 with gaps) | Normalized to start at H1, no gaps |
| 3+ blank lines waste context | Collapsed to one |

The result: Markdown that an agent can read end-to-end without choking on Word's internal bookkeeping.

**Example prompts:**
```
"Convert this Word doc to markdown"
"Make requirements.docx agent-readable"
"Clean up this Word-exported markdown"
```

## How It Works

This is a **Claude Code skill** — you install it once, and Claude can convert Word documents for you on demand. There's nothing to build or configure.

### Architecture: thin skill, fast Go binary

The skill itself is a thin orchestration layer. The actual heavy lifting — pandoc invocation and the five post-processing passes — happens in a single static **Go** binary built from [`word-doc-to-md-skill-go`](https://github.com/greenstevester/word-doc-to-md-skill-go).

No Python, Node, or Ruby runtime is required:

- `CGO_ENABLED=0` and `-trimpath` — genuinely portable, no system libraries to satisfy
- ~2.5 MB per platform, native code on every target
- Cold start is sub-second; warm runs are pandoc-bound

The skill ships nothing but README + install layer + download manifest. All the conversion logic — and any future improvements to it — lives in the Go repo above.

### Lazy Loading: Nothing Downloads Until You Need It

When you install this skill, **no binaries are downloaded**. Everything is fetched on-demand:

1. **First time you use the skill** — the `docx-to-md` binary (~2.5 MB) is downloaded for your specific platform (macOS/Linux/Windows, Intel/ARM) from [GitHub Releases](https://github.com/greenstevester/word-doc-to-md-skill-go/releases)
2. **First time you convert a `.docx`** — pandoc (~30 MB) is downloaded automatically

Both are cached permanently in the **skill's plugin directory** (next to the binary, not in your project). You only download once.

### Where Things Are Stored

```
~/.claude/plugins/word-doc-to-md-skill/     # skill plugin directory
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
rm -rf ~/.claude/plugins/word-doc-to-md-skill/bin
# pandoc re-downloads on next conversion
```

## Installation

**From within Claude Code (recommended):**

First, add the marketplace:
```
/plugin marketplace add greenstevester/word-doc-to-md-skill
```

Then install the plugin:
```
/plugin install convert-docx@word-doc-to-md-skill
```

Reload plugins (or restart Claude Code):
```
/reload-plugins
```

**From the terminal:**
```bash
claude plugin add greenstevester/word-doc-to-md-skill
```

That's it — no build tools, no Go, no pandoc to install.

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
/plugin marketplace update word-doc-to-md-skill
```

Or from the terminal:
```bash
claude plugin update greenstevester/word-doc-to-md-skill
```

This pulls the latest skill (including any newer pandoc version). The next conversion auto-upgrades pandoc if needed.

## Related

- [word-doc-to-md-skill-go](https://github.com/greenstevester/word-doc-to-md-skill-go) — the Go source for the static binary that powers this skill. All the conversion logic, post-processing passes, and pandoc bootstrap live there. This skill is essentially the install + UX layer on top.

## License

MIT
