wings_install(){
  info "Installing Docker (with repo fix)..."
  apt-get update -y; apt-get install -y curl ca-certificates gnupg
  fix_docker_repo; apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable --now docker
  info "Installing Wings..."
  mkdir -p /etc/pterodactyl
  local arch=amd64; [ "$(uname -m)" = aarch64 ] && arch=arm64
  curl -fL -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$arch"
  chmod u+x /usr/local/bin/wings
  ok "Wings installed"
}
wings_config(){
  echo -e "${WHT}Panel -> Admin -> Nodes -> (node) -> Configuration -> 'Generate Token' ka command paste karo:${R}"
  read -rp "> " CMD
  if [[ "$CMD" == *"wings configure"* ]]; then eval "$CMD"; else err "Invalid command"; fi
}
wings_service(){
  cat > /etc/systemd/system/wings.service <<'UNIT'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service
[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s
[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload; systemctl enable --now wings && ok "Wings service running"
}
wings_menu(){
  while true; do
    banner; title "Wings Setup"
    item 1 "Wings install + docker + fix"; item 2 "Wings config setup"; item 3 "Run Wings (foreground)"
    item 4 "Wings Background Service"; item 5 "Wings Auto ${YEL}[BETA - auto-detect local Panel]${R}"; item_exit
    prompt
    case $CHOICE in
      1) wings_install; pause;;
      2) wings_config; pause;;
      3) /usr/local/bin/wings --debug; pause;;
      4) wings_service; pause;;
      5) if [ -d /var/www/pterodactyl ]; then ok "Local panel mila"; wings_install; wings_config; wings_service; else err "Local panel nahi mila"; fi; pause;;
      0) return;;
    esac
  done
}
