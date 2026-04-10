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
│  Everything lazy-loads on first use. Nothing to install.        │
└─────────────────────────────────────────────────────────────────┘
```

### How this skill works

- **First use:** The `docx-to-md` binary is downloaded for this platform (~2.5 MB)
- **First conversion:** Pandoc is downloaded automatically (~30 MB)
- **Both are cached** in the skill's plugin directory (not in the user's project)
- **Pandoc upgrades** happen automatically when a newer version is expected

### Environment Check
- Binary: !`PLUGIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"; [ -x "${PLUGIN_DIR}/docx-to-md" ] && echo "✓ docx-to-md ready" || echo "○ docx-to-md will download on first use (~2.5 MB)"`
- Pandoc: !`PLUGIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"; [ -x "${PLUGIN_DIR}/bin/pandoc" ] && echo "✓ pandoc ready (version: $(cat "${PLUGIN_DIR}/bin/.pandoc-version" 2>/dev/null || echo 'unknown'))" || echo "○ pandoc will download on first conversion (~30 MB)"`

### Target: ${ARGUMENTS:-current directory}

---

## Step 1: Ensure Binary is Installed

The binary is lazy-loaded: it downloads automatically on first use.
All files are stored in the **skill plugin directory**, not in the user's project.

```bash
PLUGIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
if [ ! -x "${PLUGIN_DIR}/docx-to-md" ]; then
  echo "First run — downloading docx-to-md for this platform..."
  bash "${PLUGIN_DIR}/install.sh"
fi
DOCX_TO_MD="${PLUGIN_DIR}/docx-to-md"
```

---

## Step 2: Convert

```bash
# Basic conversion (output goes next to the input file)
"${DOCX_TO_MD}" document.docx

# Explicit output path
"${DOCX_TO_MD}" document.docx output/clean.md

# Pipe to another tool
"${DOCX_TO_MD}" document.docx --stdout | your-ingestion-tool
```

On the first conversion, pandoc (~30 MB) downloads automatically into the plugin directory.
If a newer pandoc version is expected, it upgrades automatically.

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
"${DOCX_TO_MD}" postprocess existing.md cleaned.md
"${DOCX_TO_MD}" postprocess existing.md --stdout
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `pandoc binary not found` | Run `"${DOCX_TO_MD}" bootstrap` to force re-download |
| Want a specific pandoc version | Run `"${DOCX_TO_MD}" bootstrap 3.x.x` |
| Proxy/firewall blocks download | Set `HTTPS_PROXY` env var before running |
| Legacy `.doc` file (not `.docx`) | Pre-convert: `libreoffice --headless --convert-to docx file.doc` |
| Multi-column layout garbled | Flag for human review — pandoc limitation |
| Missing alt text on images | Outputs `[IMAGE: no description]` — add alt text in Word |

---

## Where Things Are Stored

Everything lives in the skill plugin directory — nothing is added to PATH or the user's project:

```
<plugin-dir>/
  docx-to-md          # converter binary (lazy-loaded on first use)
  bin/
    pandoc             # pandoc binary (lazy-loaded on first conversion)
    .pandoc-version    # tracks installed version for auto-upgrade
```

---

## Next Steps

- **Batch convert?** `for f in *.docx; do "${DOCX_TO_MD}" "$f"; done`
- **Reinstall binary?** `rm "${PLUGIN_DIR}/docx-to-md" && bash "${PLUGIN_DIR}/install.sh"`
- **Force pandoc upgrade?** `rm -rf "${PLUGIN_DIR}/bin" && "${DOCX_TO_MD}" bootstrap`
- **Integrate into pipeline?** Use `--stdout` to pipe directly into your ingestion tool
