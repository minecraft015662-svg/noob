#!/usr/bin/env bash
# Sarthak34 Toolkit - UI helpers
export LC_ALL=C.UTF-8
AQUA=$'\e[96m'; TEAL=$'\e[36m'; RED=$'\e[91m'; YEL=$'\e[93m'; GRN=$'\e[92m'; WHT=$'\e[97m'; DIM=$'\e[90m'; R=$'\e[0m'; BOLD=$'\e[1m'
VERSION="1.0"
W=50
CONF=/etc/sarthak34.conf
[ -f "$CONF" ] && . "$CONF"

_rep(){ local s="" i; for ((i=0;i<$2;i++)); do s+="$1"; done; printf '%s' "$s"; }
_cline(){ # text color
  local t="$1" c="$2" l=$(( (W-${#1})/2 ))
  printf "%s║%s%*s%s%s%s%*s%s║%s\n" "$AQUA" "$R" "$l" "" "$c" "$t" "$R" $((W-l-${#1})) "" "$AQUA" "$R"
}
banner(){
  clear
  echo
  printf "%s╔%s╗%s\n" "$AQUA" "$(_rep ═ $W)" "$R"
  _cline "" ""
  _cline "◆ SARTHAK34 ◆" "$AQUA$BOLD"
  _cline "Pterodactyl Panel Toolkit" "$TEAL"
  _cline "by Sarthak34" "$YEL$BOLD"
  _cline "v$VERSION" "$WHT$BOLD"
  _cline "" ""
  printf "%s╚%s╝%s\n\n" "$AQUA" "$(_rep ═ $W)" "$R"
}
title(){ echo -e "${AQUA}▶ ${BOLD}$1${R}"; echo -e "${TEAL}$(_rep ─ $((${#1}+2)))${R}\n"; }
item(){ printf "  %s❯%s %s%s%s %s\n" "$AQUA" "$R" "$TEAL" "$1" "$R" "$2"; }
item_exit(){ printf "  %s❯%s %s0%s Exit\n" "$AQUA" "$R" "$RED" "$R"; }
prompt(){ printf "\n%sSelect an option: %s" "$AQUA" "$R"; read -r CHOICE; }
info(){ echo -e "${TEAL}>>> $*${R}"; }
ok(){ echo -e "${GRN}✔ $*${R}"; }
warn(){ echo -e "${YEL}! $*${R}"; }
err(){ echo -e "${RED}✘ $*${R}"; }
pause(){ echo; read -rp "$(echo -e "${YEL}Press ENTER to return to the menu...${R}")" _; }
need_root(){ [ "$(id -u)" -eq 0 ] || { err "Run as root (sudo sarthak34)"; exit 1; }; }
ask(){ # var "Label" "default" [secret]
  local __v="$1" label="$2" def="$3" sec="$4" val
  echo -e "${AQUA}•${R} ${WHT}${label}${R} ${DIM}[${def}]${R}"
  if [ -n "$sec" ]; then read -rsp "  ╰─> " val; echo; else read -rp "  ╰─> " val; fi
  printf -v "$__v" '%s' "${val:-$def}"
}
confirm(){ local a; read -rp "$(echo -e "${AQUA}🚀 $1 (y/n): ${R}")" a; [[ "$a" =~ ^[Yy]$ ]]; }
rand(){ tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-24}"; }

# Fix: docker repo wrongly pointing to ubuntu on Debian (the "trixie Release 404" error)
fix_docker_repo(){
  . /etc/os-release
  local distro="$ID" code="$VERSION_CODENAME"
  [[ "$distro" == "debian" || "$distro" == "ubuntu" ]] || distro="debian"
  rm -f /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.sources
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/$distro/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  if ! curl -fsI "https://download.docker.com/linux/$distro/dists/$code/Release" >/dev/null 2>&1; then
    warn "Docker repo has no '$code'; falling back to bookworm/jammy"
    [ "$distro" = debian ] && code=bookworm || code=jammy
  fi
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$distro $code stable" > /etc/apt/sources.list.d/docker.list
}

# PHP 8.3 repo (Debian -> sury, Ubuntu -> ondrej ppa)
add_php_repo(){
  . /etc/os-release
  apt-get install -y curl ca-certificates gnupg lsb-release apt-transport-https software-properties-common >/dev/null
  if [ "$ID" = ubuntu ]; then
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
  else
    curl -sSLo /tmp/sury.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && dpkg -i /tmp/sury.deb
    echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $VERSION_CODENAME main" > /etc/apt/sources.list.d/php.list
  fi
  apt-get update -y
}
