# Option 11 - Panel Install Manager (domain/email/password prompts)
panelmgr_menu(){
  while true; do
    banner; title "Panel Install Manager"
    item 1 "Pterodactyl   :: (Fresh Install)"
    item 2 "Paymenter     :: (Billing Panel)"
    item 3 "Domain/SSL    :: (certbot for a domain)"
    item 4 "Update        :: (Panel latest release)"
    item_exit
    prompt
    case $CHOICE in
      1) panel_menu; pause;;
      2) banner; title "Paymenter Install"
         local D E P; ask D "Panel Domain" "billing.example.com"; ask E "Admin Email" "admin@example.com"; ask P "Admin Password" "$(rand 12)" secret
         echo -e "\n${YEL}[ REVIEW CONFIGURATION ]${R}\n  Domain: $D\n  Email:  $E"
         confirm "Start Installation?" && install_paymenter "$D" "$E" "$P"; pause;;
      3) read -rp "Domain: " D; read -rp "Email: " E; apt-get install -y certbot python3-certbot-nginx && certbot --nginx -d "$D" -m "$E" --agree-tos -n; pause;;
      4) cd /var/www/pterodactyl 2>/dev/null || { err "Panel nahi mila"; pause; continue; }
         php artisan down; curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
         chmod -R 755 storage/* bootstrap/cache; COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction
         php artisan view:clear; php artisan config:clear; php artisan migrate --seed --force
         chown -R www-data:www-data /var/www/pterodactyl/*; php artisan queue:restart; php artisan up; ok "Updated"; pause;;
      0) return;;
    esac
  done
}
