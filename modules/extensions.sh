# Extensions library: list in extensions/extensions.list (one id per line)
EXT_DIR=/opt/sarthak34/extensions
PAGE_SIZE=15
ext_installed(){ [ -d "$PTERO/.blueprint/extensions/$1" ]; }
ext_get(){ # id -> installs
  local id="$1" f="$EXT_DIR/$1.blueprint"
  if [ ! -f "$f" ]; then
    if [ -n "${EXT_BASE_URL:-}" ]; then curl -fL -o "$f" "$EXT_BASE_URL/$id.blueprint" || { err "$id download fail"; return 1; }
    else err "$id.blueprint nahi mila ($EXT_DIR) aur EXT_BASE_URL set nahi"; return 1; fi
  fi
  bp_install_file "$id" "$f" && ok "$id installed"
}
ext_remove(){ (cd "$PTERO" && blueprint -remove "$1") && ok "$1 removed"; }
ext_repair(){
  info "Fixing 500 error..."
  cd "$PTERO" || return 1
  php artisan view:clear; php artisan config:clear; php artisan cache:clear
  chown -R www-data:www-data "$PTERO"/*; chmod -R 755 storage/* bootstrap/cache
  command -v blueprint >/dev/null && blueprint -rerun-install 2>/dev/null
  systemctl restart pteroq php8.3-fpm nginx 2>/dev/null
  ok "Done. Agar abhi bhi 500 aaye to: tail -n 50 $PTERO/storage/logs/laravel-*.log"
}
ext_list_file(){ mapfile -t EXTS < <(grep -v '^\s*#' "$1" | grep -v '^\s*$'); }
ext_do_list(){ # action file
  local f="$1" act="$2" x
  while read -r x; do [ -z "$x" ] && continue; case $act in i) ext_installed "$x" || ext_get "$x";; r) ext_installed "$x" && ext_remove "$x";; esac; done < "$f"
}
ext_library(){
  mkdir -p "$EXT_DIR"
  local ALL="$EXT_DIR/extensions.list" page=1 n x i start
  [ -f "$ALL" ] || { err "extensions.list missing"; pause; return; }
  while true; do
    ext_list_file "$ALL"; n=${#EXTS[@]}
    local pages=$(( (n+PAGE_SIZE-1)/PAGE_SIZE )); [ $pages -lt 1 ] && pages=1
    banner; title "Extensions Library (all $n extensions)"
    start=$(( (page-1)*PAGE_SIZE ))
    for ((i=start;i<start+PAGE_SIZE && i<n;i++)); do
      x="${EXTS[$i]}"
      if ext_installed "$x"; then m="${GRN}●${R}"; else m="${RED}○${R}"; fi
      printf "  %s❯%s %s%-3s%s %b %s\n" "$AQUA" "$R" "$TEAL" "$((i+1))" "$R" "$m" "$x"
    done
    echo -e "\n  ${GRN}●${R} installed   ${RED}○${R} not installed"
    echo -e "  Page $page/$pages   ${YEL}n${R})Next   ${YEL}p${R})Prev   ${RED}0${R})Back"
    echo -e "  Install: type a number (e.g. 23)   Remove: r + number (e.g. r23)"
    echo -e "  Install several: 1,2,4,7,9   Remove several: r1,2,4,7,9"
    echo -e "  Install ALL: ${TEAL}all${R}   Remove ALL: ${RED}r all${R}"
    echo -e "  Best-for-hosting bundle: ${TEAL}template${R}   Remove it: ${RED}r template${R}"
    echo -e "  Install curated list (best.list): ${TEAL}best${R}"
    echo -e "  Keep only keep.list, remove rest: ${RED}keep${R}"
    echo -e "  Fix a 500 error from a broken extension: ${RED}repair${R}"
    printf "\n%sSelect: %s" "$AQUA" "$R"; read -r c
    case "$c" in
      n) [ $page -lt $pages ] && page=$((page+1));;
      p) [ $page -gt 1 ] && page=$((page-1));;
      0) return;;
      all) for x in "${EXTS[@]}"; do ext_installed "$x" || ext_get "$x"; done; pause;;
      "r all") for x in "${EXTS[@]}"; do ext_installed "$x" && ext_remove "$x"; done; pause;;
      template) ext_do_list "$EXT_DIR/template.list" i; pause;;
      "r template") ext_do_list "$EXT_DIR/template.list" r; pause;;
      best) ext_do_list "$EXT_DIR/best.list" i; pause;;
      keep) for x in "${EXTS[@]}"; do grep -qx "$x" "$EXT_DIR/keep.list" 2>/dev/null || { ext_installed "$x" && ext_remove "$x"; }; done; pause;;
      repair) ext_repair; pause;;
      r*) IFS=',' read -ra L <<< "${c#r}"; for i in "${L[@]}"; do i=$(echo "$i"|xargs); [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le "$n" ] && ext_remove "${EXTS[$((i-1))]}"; done; pause;;
      *) IFS=',' read -ra L <<< "$c"; for i in "${L[@]}"; do i=$(echo "$i"|xargs); [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le "$n" ] && ext_get "${EXTS[$((i-1))]}"; done; pause;;
    esac
  done
}
