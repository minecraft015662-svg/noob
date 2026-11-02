_st(){ if eval "$2" >/dev/null 2>&1; then printf "  ${GRN}●${R} %s\n" "$1"; else printf "  ${RED}○${R} %s\n" "$1"; fi; }
show_apps(){
  banner; title "Installed Apps"
  _st "Pterodactyl Panel" "[ -d /var/www/pterodactyl ]"
  _st "Blueprint" "command -v blueprint"
  _st "Wings" "[ -x /usr/local/bin/wings ]"
  _st "Docker" "command -v docker"
  _st "Cloudflared" "command -v cloudflared"
  _st "Paymenter" "[ -d /var/www/paymenter ]"
  _st "Nginx" "command -v nginx"
  _st "MariaDB" "command -v mariadb"
  _st "Redis" "command -v redis-server"
}
show_credits(){
  banner; title "Credits"
  echo -e "  ${AQUA}Sarthak34${R} - Toolkit author"
  echo -e "  Pterodactyl, Blueprint Framework, Paymenter, Cloudflare - respective owners"
}
