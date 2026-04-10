# docx-to-agent-md

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Cross-platform](https://img.shields.io/badge/Platform-Win%20%7C%20macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-purple.svg)](https://claude.ai/code)
[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go&logoColor=white)](https://go.dev/)

> **Word doc in, clean agent-readable Markdown out.** One command, any platform.

## Why This Skill?

Word documents are everywhere — specs, contracts, requirements, meeting notes. But LLMs and AI agents choke on `.docx` files. Pandoc gets you 80% of the way, but the output is littered with tracked-change markup, broken image paths, heading gaps, and grid-table noise.

| Without This Skill | With This Skill |
|--------------------|-----------------|
| Install pandoc manually | Auto-downloads on first run |
| Raw pandoc output with artifacts | 5-stage cleanup pipeline |
| Broken `![](media/image1.png)` refs | Clean `[IMAGE: description]` text |
| Tracked changes markup everywhere | Insertions accepted, deletions gone |
| Heading hierarchy gaps (H2 → H5) | Shifted to H1 with no gaps |
| Works on your OS only | Single binary for Win/macOS/Linux |

## Prerequisites

- [Go 1.22+](https://go.dev/dl/) for building
- Internet access on first run (downloads pandoc ~30 MB, cached forever)

## Installation

```
/plugin marketplace add greenstevester/docx-to-agent-md
```

Restart Claude Code.

**Verify:** Ask Claude "Convert this Word doc to markdown" with a `.docx` file nearby.

## Usage

```
┌─────────────────────────────────────────────────────────────────┐
│                        Conversion Pipeline                      │
└─────────────────────────────────────────────────────────────────┘

  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │BOOTSTRAP │───▶│  PANDOC  │───▶│POSTPROC  │───▶│ CLEAN MD │
  │(once)    │    │  EXTRACT │    │5 TRANSFORMS   │          │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘
       │               │               │               │
       ▼               ▼               ▼               ▼
  Downloads        .docx → raw      Tracked changes   Ready for
  pandoc for       GFM markdown     headings, tables   agents,
  your platform                     images, blanks     LLMs, MCP
```

**Just ask Claude naturally:**
```
"Convert this Word doc to markdown"
"Make requirements.docx agent-readable"
"Clean up this Word-exported markdown"
```

**Or use the binary directly:**
```bash
# Build once
go build -o docx-to-md .

# Convert
./docx-to-md document.docx
./docx-to-md document.docx output/clean.md
./docx-to-md document.docx --stdout | your-tool
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

| OS | Arch | Pandoc Asset |
|----|------|-------------|
| Linux | x86_64 | `pandoc-{v}-linux-amd64.tar.gz` |
| Linux | arm64 | `pandoc-{v}-linux-arm64.tar.gz` |
| macOS | Intel | `pandoc-{v}-x86_64-macOS.zip` |
| macOS | Apple Silicon | `pandoc-{v}-arm64-macOS.zip` |
| Windows | x86_64 | `pandoc-{v}-windows-x86_64.zip` |

Cross-compile from any platform:
```bash
GOOS=linux   GOARCH=amd64 go build -o docx-to-md-linux .
GOOS=darwin  GOARCH=arm64 go build -o docx-to-md-macos .
GOOS=windows GOARCH=amd64 go build -o docx-to-md.exe .
```

## Subcommands

| Command | What It Does |
|---------|-------------|
| `./docx-to-md <file.docx>` | Full pipeline: bootstrap + convert + postprocess |
| `./docx-to-md postprocess <file.md>` | Clean existing markdown (no pandoc needed) |
| `./docx-to-md bootstrap [version]` | Force re-download pandoc |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Skills not loading | Restart Claude Code after install |
| `pandoc binary not found` | Run `./docx-to-md bootstrap` |
| Proxy blocks download | Set `HTTPS_PROXY` env var |
| Legacy `.doc` file | Pre-convert: `libreoffice --headless --convert-to docx` |
| Multi-column layout garbled | Flag for human review |

## Local Development

```bash
claude --plugin-dir /path/to/docx-to-agent-md
```

## Update

```
/plugin marketplace update docx-to-agent-md
```

## License

MIT - [github.com/greenstevester/docx-to-agent-md](https://github.com/greenstevester/docx-to-agent-md)
