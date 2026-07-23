#!/usr/bin/env bash
# Phases 6 and 7: render the report with WeasyPrint, then rasterize every page so
# the layout can be inspected like a publisher would.
#
#   bash render.sh check                       # preflight the toolchain
#   bash render.sh render report.html out.pdf  # render (fails loudly, never silently)
#   bash render.sh verify out.pdf [dpi]        # → verify/page-01.png, page-02.png, …
#   bash render.sh all report.html out.pdf     # render + verify
set -uo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

weasy() {
  if have weasyprint; then weasyprint "$@"
  elif python3 -c 'import weasyprint' 2>/dev/null; then python3 -m weasyprint "$@"
  else return 127; fi
}

check() {
  local missing=0
  printf '%-14s' "weasyprint"
  if have weasyprint || python3 -c 'import weasyprint' 2>/dev/null; then echo "ok"; else
    echo "MISSING   → pipx install weasyprint   (or: pip install --user weasyprint)"; missing=1; fi

  printf '%-14s' "pdftoppm"
  if have pdftoppm; then echo "ok"; else
    echo "MISSING   → apt install poppler-utils  /  brew install poppler"; missing=1; fi

  printf '%-14s' "python3+PIL"
  if python3 -c 'import PIL' 2>/dev/null; then echo "ok"; else
    echo "MISSING   → pip install --user pillow"; missing=1; fi

  printf '%-14s' "npx"
  if have npx; then echo "ok"; else
    echo "MISSING   → Node 18+ (screenshot fallback; Playwright MCP also works)"; fi

  printf '%-14s' "curl"
  if have curl; then echo "ok"; else echo "MISSING   → install curl"; missing=1; fi

  [ "$missing" -eq 0 ] && echo "toolchain ready" || echo "install the MISSING items before Phase 6"
  return "$missing"
}

render() {
  local html="${1:?usage: render.sh render <html> <pdf>}" pdf="${2:?usage: render.sh render <html> <pdf>}"
  [ -f "$html" ] || { echo "no such file: $html" >&2; exit 1; }
  weasy "$html" "$pdf"
  local rc=$?
  if [ "$rc" -eq 127 ]; then
    echo "WeasyPrint is not installed. Run: bash render.sh check" >&2
    echo "Do not silently swap the renderer: the style spec is tuned for WeasyPrint." >&2
    exit 127
  fi
  [ "$rc" -eq 0 ] || { echo "render failed (exit $rc)" >&2; exit "$rc"; }
  echo "✓ $pdf  ($(du -h "$pdf" | cut -f1), $(pdftoppm -v 2>&1 >/dev/null; pdfinfo "$pdf" 2>/dev/null | awk '/^Pages/{print $2" pages"}'))"
}

verify() {
  local pdf="${1:?usage: render.sh verify <pdf> [dpi]}" dpi="${2:-110}"
  local dir; dir="$(dirname "$pdf")/verify"
  have pdftoppm || { echo "pdftoppm missing — run: bash render.sh check" >&2; exit 127; }
  rm -f "$dir"/page-*.png 2>/dev/null
  mkdir -p "$dir"
  pdftoppm -r "$dpi" -png "$pdf" "$dir/page" || exit 1
  local n; n="$(ls -1 "$dir"/page-*.png 2>/dev/null | wc -l | tr -d ' ')"
  echo "✓ $n page image(s) → $dir/"
  echo "  Now READ every one of them. Look for: orphaned boxes, near-empty pages,"
  echo "  figures pushed onto their own page, badly split tables. Fix, re-render, re-verify."
}

case "${1:-check}" in
  check)  check ;;
  render) shift; render "$@" ;;
  verify) shift; verify "$@" ;;
  all)    shift; render "$1" "$2" && verify "$2" ;;
  *)      echo "usage: render.sh check|render <html> <pdf>|verify <pdf> [dpi]|all <html> <pdf>" >&2; exit 2 ;;
esac
