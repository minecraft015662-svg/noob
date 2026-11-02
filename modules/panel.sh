install_ptero_panel(){ # domain email username password
  local DOMAIN="$1" EMAIL="$2" USERN="$3" PASS="$4"
  local DBPASS; DBPASS=$(rand 24)
  info "Installing dependencies..."
  apt-get update -y; add_php_repo
  DEBIAN_FRONTEND=noninteractive apt-get install -y nginx mariadb-server redis-server tar unzip git cron \
    php8.3 php8.3-{cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,intl,redis}
  systemctl enable --now mariadb redis-server nginx php8.3-fpm
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

  info "Downloading panel..."
  mkdir -p /var/www/pterodactyl && cd /var/www/pterodactyl || return 1
  curl -fLo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
  tar -xzf panel.tar.gz && rm panel.tar.gz
  chmod -R 755 storage/* bootstrap/cache/

  info "Creating database..."
  mariadb -e "CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DBPASS'; CREATE DATABASE IF NOT EXISTS panel; GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;"

  cp .env.example .env
  COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction
  php artisan key:generate --force
  php artisan p:environment:setup --author="$EMAIL" --url="https://$DOMAIN" --timezone=Asia/Kolkata \
    --cache=redis --session=redis --queue=redis --redis-host=127.0.0.1 --redis-pass= --redis-port=6379 \
    --settings-ui=true --telemetry=false --no-interaction
  php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=pterodactyl --password="$DBPASS" --no-interaction
  php artisan migrate --seed --force
  php artisan p:user:make --email="$EMAIL" --username="$USERN" --name-first=Admin --name-last=User --password="$PASS" --admin=1 --no-interaction

  chown -R www-data:www-data /var/www/pterodactyl/*
  (crontab -l 2>/dev/null | grep -v 'pterodactyl/artisan'; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
  cat > /etc/systemd/system/pteroq.service <<UNIT
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s
[Install]
WantedBy=multi-user.target
UNIT
  systemctl enable --now pteroq.service

  rm -f /etc/nginx/sites-enabled/default
  cat > /etc/nginx/sites-available/pterodactyl.conf <<NGX
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/pterodactyl/public;
    index index.php;
    client_max_body_size 100m;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
    }
    location ~ /\.ht { deny all; }
}
NGX
  ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
  nginx -t && systemctl reload nginx
  ok "Pterodactyl installed -> http://$DOMAIN  (admin: $EMAIL)"
  warn "HTTPS ke liye: Cloudflare Tunnel (menu 2) ya 'certbot --nginx -d $DOMAIN'. Panel URL https:// set hai."
}
panel_menu(){
  banner; title "Pterodactyl Panel Setup"
  local D E U P
  ask D "Panel Domain" "panel.example.com"
  ask E "Admin Email" "admin@example.com"
  ask U "Admin Username" "admin"
  ask P "Admin Password" "$(rand 12)" secret
  echo -e "\n${YEL}[ REVIEW ]${R} Domain: $D | Email: $E | User: $U"
  confirm "Start Installation?" && install_ptero_panel "$D" "$E" "$U" "$P"
}
