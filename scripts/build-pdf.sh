#!/usr/bin/env bash
# 포트폴리오 합본 PDF 생성
#
# 사용법:
#   scripts/build-pdf.sh                          # projects/*.md 전부
#   scripts/build-pdf.sh ir-center nex-platform   # 지정한 프로젝트만 (파일명, .md 제외)
#
# 환경변수:
#   OUT=portfolio.pdf   출력 파일명
#   NAME="김민우"        표지 이름
#   GITHUB_URL=...      표지에 넣을 GitHub 주소
#
# 필요: pandoc, weasyprint, 한글 폰트(Noto Sans CJK 또는 Pretendard)

set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${OUT:-portfolio.pdf}"
NAME="${NAME:-김민우}"
GITHUB_URL="${GITHUB_URL:-https://github.com/klop7007}"
DATE="$(date +%Y.%m)"

# 1) 포함할 프로젝트 파일 목록
if [ $# -gt 0 ]; then
  FILES=()
  for p in "$@"; do
    f="projects/${p%.md}.md"
    [ -f "$f" ] || { echo "not found: $f" >&2; exit 1; }
    FILES+=("$f")
  done
else
  mapfile -t FILES < <(ls projects/*.md | sort)
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

# README 의 프로젝트 표를 "목차" 페이지로 재사용
TOC="$TMP/01-toc.md"
{
  echo '<div class="page-break"></div>'
  echo
  echo '# 프로젝트 목록'
  echo
  # README 에서 첫 표만 추출, 링크는 제거(PDF 안에서는 의미 없음)
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
