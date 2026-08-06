#!/usr/bin/env bash
# 日本語レポートのPDF化と目視検証。
#
#   bash render-ja.sh check                       # ツールチェーンの確認
#   bash render-ja.sh render report.html out.pdf  # レンダリング（黙って失敗しない）
#   bash render-ja.sh verify out.pdf [dpi]        # verify/page-01.png ... を出す
#   bash render-ja.sh all report.html out.pdf     # render + verify
#
# WeasyPrint は環境によって置き場所が違うので、次の順で探す：
#   1) $MB_WEASY_PYTHON （明示指定）
#   2) ~/.venvs/weasy/bin/python  （このマシンの導入場所）
#   3) PATH 上の weasyprint コマンド
#   4) システムpython3 の weasyprint モジュール
set -uo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

weasy_cmd() {
  if [ -n "${MB_WEASY_PYTHON:-}" ] && "$MB_WEASY_PYTHON" -c 'import weasyprint' 2>/dev/null; then
    printf '%s -m weasyprint' "$MB_WEASY_PYTHON"; return 0
  fi
  if [ -x "$HOME/.venvs/weasy/bin/python" ] && "$HOME/.venvs/weasy/bin/python" -c 'import weasyprint' 2>/dev/null; then
    printf '%s -m weasyprint' "$HOME/.venvs/weasy/bin/python"; return 0
  fi
  if have weasyprint; then printf 'weasyprint'; return 0; fi
  if python3 -c 'import weasyprint' 2>/dev/null; then printf 'python3 -m weasyprint'; return 0; fi
  return 1
}

check() {
  local missing=0 cmd
  printf '%-18s' "weasyprint"
  if cmd="$(weasy_cmd)"; then echo "ok  ($cmd)"; else
    echo "MISSING   → python3 -m venv ~/.venvs/weasy && ~/.venvs/weasy/bin/pip install weasyprint"
    missing=1
  fi

  printf '%-18s' "pdftoppm"
  if have pdftoppm; then echo "ok"; else
    echo "MISSING   → apt install poppler-utils"; missing=1; fi

  printf '%-18s' "JP font (gothic)"
  if fc-list :lang=ja family 2>/dev/null | grep -q "Noto Sans CJK JP"; then
    echo "ok  (Noto Sans CJK JP)"
  else
    echo "MISSING   → apt install fonts-noto-cjk fonts-noto-cjk-extra"
    echo "                     ※和文フォントが無いと本文が全て豆腐（□）になる"
    missing=1
  fi

  printf '%-18s' "Noto Serif CJK JP"
  if fc-list :lang=ja family 2>/dev/null | grep -q "Noto Serif CJK JP"; then echo "ok"; else
    echo "警告      → 明朝が無いのでゴシックにフォールバックする（致命的ではない）"; fi

  [ "$missing" -eq 0 ] && echo "ツールチェーン準備完了" || echo "MISSING の項目を入れてから再実行"
  return "$missing"
}

render() {
  local html="${1:?usage: render-ja.sh render <html> <pdf>}"
  local pdf="${2:?usage: render-ja.sh render <html> <pdf>}"
  [ -f "$html" ] || { echo "ファイルが無い: $html" >&2; exit 1; }

  local cmd
  cmd="$(weasy_cmd)" || {
    echo "WeasyPrint が見つからない。まず: bash render-ja.sh check" >&2
    echo "レンダラを黙って差し替えないこと。このCSSは WeasyPrint 前提で組んである。" >&2
    exit 127
  }

  # shellcheck disable=SC2086
  $cmd "$html" "$pdf"
  local rc=$?
  [ "$rc" -eq 0 ] || { echo "レンダリング失敗 (exit $rc)" >&2; exit "$rc"; }

  local pages
  pages="$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages/{print $2}')"
  echo "OK  $pdf  ($(du -h "$pdf" | cut -f1), ${pages:-?} ページ)"
}

verify() {
  local pdf="${1:?usage: render-ja.sh verify <pdf> [dpi]}" dpi="${2:-110}"
  local dir; dir="$(dirname "$pdf")/verify"
  have pdftoppm || { echo "pdftoppm が無い。apt install poppler-utils" >&2; exit 127; }
  rm -rf "$dir"; mkdir -p "$dir"
  pdftoppm -png -r "$dpi" "$pdf" "$dir/page" || exit 1
  echo "OK  $(ls "$dir"/page-*.png 2>/dev/null | wc -l) ページを $dir に展開"
  echo "全ページを Read で開いて目視確認すること。豆腐（□）、はみ出し、空白ページ、"
  echo "表の切れを1ページずつ見る。見ずに完了と言わない。"
}

case "${1:-}" in
  check)  check ;;
  render) shift; render "$@" ;;
  verify) shift; verify "$@" ;;
  all)    shift; render "$1" "$2" && verify "$2" ;;
  *) sed -n '2,12p' "$0"; exit 2 ;;
esac
