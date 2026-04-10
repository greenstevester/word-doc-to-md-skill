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
- Binary: !`PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$0")")")"; [ -x "${PLUGIN_DIR}/docx-to-md" ] && echo "✓ docx-to-md ready" || echo "○ docx-to-md not found — will install on first run"`
- Pandoc: !`PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$0")")")"; [ -x "${PLUGIN_DIR}/bin/pandoc" ] && echo "✓ pandoc ready" || echo "○ pandoc will download on first run (~30 MB)"`

### Target: ${ARGUMENTS:-current directory}

---

## Step 1: Ensure Binary is Installed (Once)

The binary is automatically downloaded for your platform from GitHub releases.
If `docx-to-md` is not present in the plugin directory, run the install script:

```bash
PLUGIN_DIR="$(dirname "$(dirname "$(dirname "$0")")")"
if [ ! -x "${PLUGIN_DIR}/docx-to-md" ]; then
  bash "${PLUGIN_DIR}/install.sh"
fi
```

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

## Next Steps

- **Batch convert?** `for f in *.docx; do ./docx-to-md "$f"; done`
- **Reinstall binary?** `rm docx-to-md && bash install.sh`
- **Integrate into pipeline?** Use `--stdout` to pipe directly into your ingestion tool
