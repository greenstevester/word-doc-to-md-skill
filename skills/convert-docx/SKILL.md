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

- **Lazy loading:** Nothing is downloaded at install time. The `docx-to-md` binary (~2.5 MB) downloads on first use, and pandoc (~30 MB) downloads on first conversion.
- **Stored in the plugin directory:** Both binaries live next to `install.sh` inside this plugin's directory — nothing is added to PATH or the user's project.
- **Auto-upgrades pandoc:** When a newer pandoc version is expected, the tool detects and upgrades it automatically.

### Target: ${ARGUMENTS:-current directory}

---

## Step 1: Locate or Install the Binary

Use the Glob tool to find `docx-to-md` in the plugin cache:

```
Glob pattern: ~/.claude/**/docx-to-md
```

If found, use that path as `DOCX_TO_MD`. If not found, search for `install.sh`:

```
Glob pattern: ~/.claude/**/word-doc-to-md-skill/install.sh
```

Then run the installer:

```bash
bash /path/to/install.sh
```

The installer auto-detects the platform and downloads the correct binary into the same directory.

---

## Step 2: Convert

```bash
# Basic conversion (output goes next to the input file)
/path/to/docx-to-md document.docx

# Explicit output path
/path/to/docx-to-md document.docx output/clean.md

# Pipe to another tool
/path/to/docx-to-md document.docx --stdout | your-ingestion-tool
```

On the first conversion, pandoc (~30 MB) downloads automatically into the plugin directory.
If a newer pandoc version is expected, it upgrades automatically with a message like:
`Pandoc update available: 3.9.0.2 -> 3.x.x — Upgrading...`

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
/path/to/docx-to-md postprocess existing.md cleaned.md
/path/to/docx-to-md postprocess existing.md --stdout
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `pandoc binary not found` | Run `/path/to/docx-to-md bootstrap` to force re-download |
| Want a specific pandoc version | Run `/path/to/docx-to-md bootstrap 3.x.x` |
| Proxy/firewall blocks download | Set `HTTPS_PROXY` env var before running |
| Legacy `.doc` file (not `.docx`) | Pre-convert: `libreoffice --headless --convert-to docx file.doc` |
| Multi-column layout garbled | Flag for human review — pandoc limitation |
| Missing alt text on images | Outputs `[IMAGE: no description]` — add alt text in Word |

---

## Where Things Are Stored

Everything lives in the skill plugin directory — nothing is added to PATH or the user's project:

```
<plugin-dir>/
  install.sh           # platform-aware installer
  docx-to-md           # converter binary (lazy-loaded on first use)
  bin/
    pandoc             # pandoc binary (lazy-loaded on first conversion)
    .pandoc-version    # tracks installed version for auto-upgrade
```

---

## Next Steps

- **Batch convert?** `for f in *.docx; do /path/to/docx-to-md "$f"; done`
- **Reinstall binary?** Delete `docx-to-md` and re-run `install.sh`
- **Force pandoc upgrade?** Delete the `bin/` directory next to `docx-to-md`, then run any conversion
- **Integrate into pipeline?** Use `--stdout` to pipe directly into your ingestion tool
