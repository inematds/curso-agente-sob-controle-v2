#!/usr/bin/env bash
# Lint do curso v2: manifesto identico, topicos x manifesto, links, SVG, linhas, head identico.
cd "$(dirname "$0")/.." || exit 1
fail=0
ref=$(grep -A1 'data-inema-manifest' curso/trilha1/modulo-1-1.html | tail -1)
headref=$(sed -n '1,/<\/style>/p' curso/trilha1/modulo-1-1.html | grep -v '<title>')
for f in index.html curso/trilha*/index.html curso/trilha*/modulo-*.html; do
  m=$(grep -A1 'data-inema-manifest' "$f" | tail -1)
  [ "$m" = "$ref" ] || { echo "MANIFESTO difere: $f"; fail=1; }
  grep -q 'https://inema.pro' "$f" || { echo "sem PRO: $f"; fail=1; }
  grep -q 'text-sky-400[^"]*">INEMA.CLUB' "$f" || { echo "sem INEMA.CLUB: $f"; fail=1; }
  grep -qi 'justify-center space-x' "$f" && { echo "justify-center em botoes: $f"; fail=1; }
  grep -qiE 'nate|herk' "$f" && { echo "cita terceiro: $f"; fail=1; }
  a=$(grep -n 'ANTI-FOUC' "$f" | head -1 | cut -d: -f1); t=$(grep -n 'cdn.tailwindcss.com' "$f" | head -1 | cut -d: -f1)
  [ -n "$a" ] && [ "$a" -lt "$t" ] || { echo "anti-FOUC fora de ordem: $f"; fail=1; }
  if [ "$f" != index.html ]; then
    h=$(sed -n '1,/<\/style>/p' "$f" | grep -v '<title>')
    [ "$h" = "$headref" ] || { echo "HEAD difere do modelo: $f"; fail=1; }
  fi
done
for f in curso/trilha*/modulo-*.html; do
  id=$(basename "$f" .html | sed 's/modulo-//')
  n=$(grep -c "data-inema-topic=\"modulo-$id#topico-" "$f")
  man=$(echo "$ref" | grep -o "\"id\":\"$id\",\"title\":\"[^\"]*\",\"topics\":[0-9]*" | grep -o '[0-9]*$')
  l=$(wc -l < "$f"); s=$(grep -c 'role="img"' "$f"); c=$(grep -c 'Como verificar' "$f"); q=$(grep -c 'registerCheck(' "$f")
  printf '%-34s linhas=%-4s topicos=%s/%s svg=%s copyrun=%s check=%s\n' "$f" "$l" "$n" "$man" "$s" "$c" "$q"
  [ "$n" = "$man" ] || { echo "  TOPICOS != manifesto"; fail=1; }
  [ "$l" -ge 500 ] && [ "$l" -le 850 ] || { echo "  linhas fora de 500-850"; fail=1; }
  [ "$s" -ge 1 ] || { echo "  sem SVG"; fail=1; }
done
for f in curso/trilha*/index.html; do
  grep -q '>Mapa da trilha<' "$f" || { echo "sem Mapa da trilha: $f"; fail=1; }
  mods=$(grep -c '^    <div id="modulo-' "$f"); vc=$(grep -c '>Ver Completo<' "$f"); tp=$(grep -c 'class="topic-item"' "$f")
  echo "$f modulos=$mods ver_completo=$vc topicos=$tp svg=$(grep -c 'role="img"' "$f")"
  [ "$mods" = "$vc" ] || { echo "  Ver Completo faltando"; fail=1; }
  [ "$tp" = $((mods*6)) ] || { echo "  topicos expansiveis != 6 por modulo"; fail=1; }
done
# links relativos quebrados
for f in index.html curso/trilha*/*.html; do
  d=$(dirname "$f")
  grep -o 'href="[^"#:]*\.html' "$f" | sed 's/href="//' | sort -u | while read -r h; do
    [ -f "$d/$h" ] || echo "LINK quebrado em $f -> $h"
  done
done
[ $fail = 0 ] && echo "LINT OK" || echo "LINT FALHOU"
