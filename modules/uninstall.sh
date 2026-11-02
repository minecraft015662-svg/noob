uninstall_menu(){
  while true; do
    banner; title "Uninstall"
    item 1 "Pterodactyl Panel (files + DB)"; item 2 "Wings"; item 3 "Cloudflared"; item 4 "Paymenter"; item_exit
    prompt
    case $CHOICE in
      1) read -rp "Type YES to delete panel + database: " a; [ "$a" = YES ] && { rm -rf /var/www/pterodactyl /etc/nginx/sites-*/pterodactyl.conf; systemctl disable --now pteroq 2>/dev/null; rm -f /etc/systemd/system/pteroq.service; mariadb -e "DROP DATABASE IF EXISTS panel; DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';"; systemctl reload nginx; ok "Panel removed"; }; pause;;
      2) read -rp "Type YES to remove Wings: " a; [ "$a" = YES ] && { systemctl disable --now wings 2>/dev/null; rm -f /etc/systemd/system/wings.service /usr/local/bin/wings; ok "Wings removed (/etc/pterodactyl & /var/lib/pterodactyl untouched)"; }; pause;;
      3) read -rp "Type YES to remove cloudflared: " a; [ "$a" = YES ] && { cloudflared service uninstall 2>/dev/null; apt-get remove -y cloudflared; ok "Removed"; }; pause;;
      4) read -rp "Type YES to delete Paymenter + DB: " a; [ "$a" = YES ] && { rm -rf /var/www/paymenter /etc/nginx/sites-*/paymenter.conf; mariadb -e "DROP DATABASE IF EXISTS paymenter; DROP USER IF EXISTS 'paymenter'@'127.0.0.1';"; systemctl reload nginx; ok "Paymenter removed"; }; pause;;
      0) return;;
    esac
  done
}
