#!/usr/bin/env bash
# 포트폴리오 합본 PDF 생성
#
# 사용법:
#   scripts/build-pdf.sh                           # projects/*.md 전부 (최신순)
#   scripts/build-pdf.sh attendance-dx ir-center   # 지정한 프로젝트만 (날짜 접두어 생략 가능)
#
# 환경변수:
#   OUT=portfolio.pdf   출력 파일명
#   NAME="김민우"        표지 이름
#   GITHUB_URL=...      표지에 넣을 GitHub 주소

set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${OUT:-portfolio.pdf}"
NAME="${NAME:-김민우}"
GITHUB_URL="${GITHUB_URL:-https://github.com/klop7007}"
DATE="$(date +%Y.%m)"

# 1) 포함할 프로젝트 파일 목록 (파일명 역순 = 날짜 접두어 기준 최신순)
resolve() {
  local p="${1%.md}"
  if [ -f "projects/$p.md" ]; then echo "projects/$p.md"; return; fi
  local m
  m=$(ls projects/*-"$p".md 2>/dev/null | sort -r | head -1)
  if [ -n "$m" ]; then echo "$m"; return; fi
  echo "not found: $p" >&2; exit 1
}

if [ $# -gt 0 ]; then
  FILES=()
  for p in "$@"; do FILES+=("$(resolve "$p")"); done
else
  mapfile -t FILES < <(ls projects/*.md | sort -r)
fi

# 2) 표지 + 목차용 임시 마크다운
TMP="$(mktemp -d)"
COVER="$TMP/00-cover.md"
{
  echo '<div class="cover">'
  echo "<h1>$NAME</h1>"
  echo '<p class="subtitle">Developer Portfolio</p>'
  echo "<p class=\"meta\">$GITHUB_URL<br>$DATE</p>"
  echo '</div>'
} > "$COVER"

# README 의 프로젝트 표를 "목차" 페이지로 재사용 (링크 제거)
TOC="$TMP/01-toc.md"
{
  echo '<div class="page-break"></div>'
  echo
  echo '# 프로젝트 목록'
  echo
  awk '/^\|/{print} /^\|/{seen=1} !/^\|/{if(seen) exit}' README.md \
    | sed -E 's/\[([^]]+)\]\([^)]+\)/\1/g'
} > "$TOC"

# 3) 각 프로젝트 앞에 페이지 나눔 삽입
BODY=()
for f in "${FILES[@]}"; do
  b="$TMP/$(basename "$f")"
  { echo '<div class="page-break"></div>'; echo; cat "$f"; } > "$b"
  BODY+=("$b")
done

# 4) pandoc → weasyprint
pandoc "$COVER" "$TOC" "${BODY[@]}" \
  --from gfm+raw_html \
  --to html5 --standalone \
  --css scripts/pdf.css \
  --pdf-engine=weasyprint \
  --metadata title="$NAME Portfolio" \
  -o "$OUT"

rm -rf "$TMP"
echo "built: $OUT (${#FILES[@]} projects)"
