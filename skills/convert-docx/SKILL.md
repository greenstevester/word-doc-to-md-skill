---
name: convert-docx
description: >
  Convert Word documents (.docx) into clean, agent-readable Markdown. Use when
  someone asks to convert, export, or transform a Word doc into Markdown for
  AI agents, LLM pipelines, Claude Code tools, or MCP context. Also triggers
  when someone wants to make a Word document "agent-readable" or "LLM-friendly",
  or asks to "clean up" Markdown exported from Word.
argument-hint: <input.docx> [output.md] [--stdout]
allowed-tools: Bash, Read, Write, Edit, Glob
---

## Convert Word Document to Agent-Readable Markdown

```
┌─────────────────────────────────────────────────────────────────┐
│  DOCX → AGENT MARKDOWN                                         │
│  ═════════════════════                                          │
│                                                                 │
│  .docx ──▶ pandoc ──▶ 5 transforms ──▶ clean .md               │
│                                                                 │
│  Tracked changes ✓   Heading hierarchy ✓   Tables ✓             │
│  Image refs ✓        Blank lines ✓                              │
│                                                                 │
│  Pandoc auto-downloads on first run. No manual install needed.  │
└─────────────────────────────────────────────────────────────────┘
```

### Environment Check
- Go: !`go version 2>/dev/null | grep -o "go[0-9.]*" || echo "✗ Install Go: https://go.dev/dl/"`
- Plugin dir: !`ls .claude-plugin/plugin.json 2>/dev/null && echo "✓ Plugin structure found" || echo "✗ Not in plugin root"`
- Binary built: !`ls bin/pandoc 2>/dev/null && echo "✓ pandoc ready" || echo "○ pandoc will download on first run (~30 MB)"`

### Target: ${ARGUMENTS:-current directory}

---

## Step 1: Build the Tool (Once)

```bash
go build -o docx-to-md .
```

This produces a single binary with zero runtime dependencies.

---

## Step 2: Convert

```bash
# Basic conversion
./docx-to-md document.docx

# Explicit output path
./docx-to-md document.docx output/clean.md

# Pipe to another tool
./docx-to-md document.docx --stdout | your-ingestion-tool
```

On first run, pandoc (~30 MB) downloads automatically to `bin/`. Cached forever after.

---

## What Gets Cleaned

| # | Transform | Before | After |
|---|-----------|--------|-------|
| 1 | **Tracked changes** | `[new text]{.insertion}` | `new text` |
| 2 | **Heading hierarchy** | H3 → H5 (gap) | H1 → H3 (no gap) |
| 3 | **Tables** | `+----+----+` grid dividers | Removed |
| 4 | **Images** | `![alt](media/image1.png)` | `[IMAGE: alt]` |
| 5 | **Blank lines** | 3+ blank lines | Single blank line |

---

## Standalone Post-Processing

Already have markdown from another source? Clean it without pandoc:

```bash
./docx-to-md postprocess existing.md cleaned.md
./docx-to-md postprocess existing.md --stdout
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `pandoc binary not found` | Run `./docx-to-md bootstrap` to force re-download |
| Proxy/firewall blocks download | Set `HTTPS_PROXY` env var before running |
| Legacy `.doc` file (not `.docx`) | Pre-convert: `libreoffice --headless --convert-to docx file.doc` |
| Multi-column layout garbled | Flag for human review — pandoc limitation |
| Missing alt text on images | Outputs `[IMAGE: no description]` — add alt text in Word |

---

## Cross-Compile

Build for any platform from any platform:

```bash
GOOS=linux   GOARCH=amd64 go build -o docx-to-md-linux .
GOOS=darwin  GOARCH=arm64 go build -o docx-to-md-macos .
GOOS=windows GOARCH=amd64 go build -o docx-to-md.exe .
```

---

## Next Steps

- **Batch convert?** `for f in *.docx; do ./docx-to-md "$f"; done`
- **Different pandoc version?** Edit `defaultPandocVersion` in `main.go`, then `rm -rf bin/ && ./docx-to-md bootstrap`
- **Integrate into pipeline?** Use `--stdout` to pipe directly into your ingestion tool
