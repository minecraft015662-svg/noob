install_paymenter(){ # domain email password
  local DOMAIN="$1" EMAIL="$2" PASS="$3" DBPASS; DBPASS=$(rand 24)
  apt-get update -y; add_php_repo
  DEBIAN_FRONTEND=noninteractive apt-get install -y nginx mariadb-server redis-server tar unzip git cron \
    php8.3 php8.3-{cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,intl,redis}
  systemctl enable --now mariadb nginx php8.3-fpm
  command -v composer >/dev/null || curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  mkdir -p /var/www/paymenter && cd /var/www/paymenter || return 1
  curl -fLo paymenter.tar.gz https://github.com/paymenter/paymenter/releases/latest/download/paymenter.tar.gz
  tar -xzf paymenter.tar.gz && rm paymenter.tar.gz
  chmod -R 755 storage/* bootstrap/cache/
  mariadb -e "CREATE USER IF NOT EXISTS 'paymenter'@'127.0.0.1' IDENTIFIED BY '$DBPASS'; CREATE DATABASE IF NOT EXISTS paymenter; GRANT ALL PRIVILEGES ON paymenter.* TO 'paymenter'@'127.0.0.1'; FLUSH PRIVILEGES;"
  cp .env.example .env
  COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction
  php artisan key:generate --force
  php artisan storage:link
  sed -i "s|^APP_URL=.*|APP_URL=https://$DOMAIN|; s|^DB_DATABASE=.*|DB_DATABASE=paymenter|; s|^DB_USERNAME=.*|DB_USERNAME=paymenter|; s|^DB_PASSWORD=.*|DB_PASSWORD=$DBPASS|; s|^DB_HOST=.*|DB_HOST=127.0.0.1|" .env
  php artisan migrate --force --seed
  php artisan app:init
  warn "Admin user create hoga - email: $EMAIL, password wahi daalo jo upar diya."
  php artisan app:user:create
  chown -R www-data:www-data /var/www/paymenter/*
  (crontab -l 2>/dev/null | grep -v 'paymenter/artisan'; echo "* * * * * php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab -
  cat > /etc/systemd/system/paymenter.service <<UNIT
[Unit]
Description=Paymenter Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/paymenter/artisan queue:work
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s
[Install]
WantedBy=multi-user.target
UNIT
  systemctl enable --now paymenter
  cat > /etc/nginx/sites-available/paymenter.conf <<NGX
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/paymenter/public;
    index index.php;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
    location ~ /\.ht { deny all; }
}
NGX
  ln -sf /etc/nginx/sites-available/paymenter.conf /etc/nginx/sites-enabled/paymenter.conf
  nginx -t && systemctl reload nginx && ok "Paymenter ready -> http://$DOMAIN"
}
