#!/usr/bin/env bash
# build_summaries.sh  –  compile every USI course summary

set -euo pipefail
shopt -s nullglob        # *.tex expands to nothing if no match

SUMMARY_DIR="summaries"  # where the .tex files live
cd "$(dirname "$0")"     # make sure we’re at repo root

# Map the one file that needs LuaLaTeX
need_lua="usi-optimization-methods-summary.tex"

compile () {
  local tex="$1"
  local engine="pdflatex"
  [[ $(basename "$tex") == "$need_lua" ]] && engine="lualatex"

  echo "▶ building $(basename "$tex") with $engine …"
  if [[ $engine == lualatex ]]; then
    latexmk -pdf -lualatex -pdflatex="lualatex -interaction=nonstopmode" \
            -silent -cd "$tex"
  else
    latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" \
            -silent -cd "$tex"
  fi
  echo "✔  done → ${tex%.tex}.pdf"
}

# -------- compile every *.tex in summaries/ --------
for tex in "$SUMMARY_DIR"/*.tex; do
  compile "$tex"
done

# ---------- clean up aux / log / synctex files --------
echo -n "🧹 cleaning aux files … "
for tex in "$SUMMARY_DIR"/*.tex; do
  latexmk -c -cd "$tex" >/dev/null
done
rm -f "$SUMMARY_DIR"/*.synctex.gz

# ⬇ remove *everything* that isn't source or final PDF
find "$SUMMARY_DIR" -type f ! \( -name '*.tex' -o -name '*.pdf' \) -delete
echo "done."