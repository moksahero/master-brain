#!/usr/bin/env python3
"""Wrap reports/arithmetic-floor.html into a standalone A4 print document.

The source is authored for the Artifact host, which supplies doctype, head and
body. For local Chrome rendering we add those, pin the charset so the Japanese
runs correctly, force the light palette (headless Chrome may otherwise resolve
prefers-color-scheme: dark), open the collapsed sources block, and add
page-break rules so tables and dated rows are not split mid-row.
"""
import pathlib
import re
import sys

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
body = src.read_text(encoding="utf-8")

# Pull the authored <title> and <style> out of the fragment so they can sit in <head>.
m_title = re.search(r"<title>(.*?)</title>", body, re.S)
title = m_title.group(1).strip() if m_title else src.stem
body = re.sub(r"<title>.*?</title>", "", body, count=1, flags=re.S)

m_style = re.search(r"<style>(.*?)</style>", body, re.S)
authored_css = m_style.group(1) if m_style else ""
body = re.sub(r"<style>.*?</style>", "", body, count=1, flags=re.S)

# Strip the dark-theme blocks entirely rather than trying to out-specify them.
authored_css = re.sub(
    r"@media \(prefers-color-scheme: dark\) \{.*?\n  \}\n\}", "", authored_css, flags=re.S
)
authored_css = re.sub(
    r':root\[data-theme="dark"\] \{.*?\n  \}', "", authored_css, flags=re.S
)

# Render the sources block expanded.
body = body.replace("<details class=\"sources\">", "<details class=\"sources\" open>")

PRINT_CSS = """
@page { size: A4; margin: 16mm 15mm 18mm; }

html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }

body {
  font-family: "Noto Sans CJK JP", -apple-system, "Segoe UI", sans-serif;
  font-size: 10.2pt;
  line-height: 1.6;
  padding: 0;
  background: #FFFFFF;
}

:root {
  --serif: "Noto Serif CJK JP", "Iowan Old Style", Palatino, Georgia, serif;
  --sans: "Noto Sans CJK JP", -apple-system, "Segoe UI", sans-serif;
  --paper: #FFFFFF;
}

.wrap, .wide { max-width: 100%; }

header.masthead { padding-top: 0; }
h1 { font-size: 30pt; }
.standfirst { font-size: 12pt; }
.verdict p { font-size: 15pt; }
.verdict .sub { font-size: 10.2pt; }
h2 { font-size: 16pt; }
h3 { font-size: 11pt; }

section { margin-top: 0; padding-top: 15mm; break-before: auto; }
h2, h3 { break-after: avoid; }
h2 + p, h3 + p { break-before: avoid; }
.sec-label { break-after: avoid; }

/* The two full-width sections are the ones a reader jumps to. Start them fresh. */
section.wide { break-before: page; padding-top: 0; }

table { font-size: 9pt; }
.tablewrap { overflow-x: visible; break-inside: avoid; }
thead { display: table-header-group; }
tr { break-inside: avoid; }

/* The constraint table is taller than a page. Let it flow so its heading is not
   orphaned on a page of its own, and rely on the repeating thead for context. */
section.wide .tablewrap { break-inside: auto; }
section.wide tbody th, section.wide thead th:first-child { width: 9em; }
section.wide caption { break-before: avoid; }

.note, .tick, .move { break-inside: avoid; }
details.sources { break-inside: auto; }
details.sources summary { list-style: none; }
details.sources .inner { font-size: 8.6pt; }

a { color: #234A73; text-decoration: none; }

footer { break-inside: avoid; }
"""

html = f"""<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>
{authored_css}
</style>
<style>
{PRINT_CSS}
</style>
</head>
<body>
{body.strip()}
</body>
</html>
"""

dst.write_text(html, encoding="utf-8")
print(f"wrote {dst} ({len(html):,} bytes), title={title!r}")
