cf_install(){
  info "Installing cloudflared..."
  mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' > /etc/apt/sources.list.d/cloudflared.list
  apt-get update -y && apt-get install -y cloudflared && ok "cloudflared installed"
}
cf_menu(){
  while true; do
    banner; title "Cloudflare"
    item 1 "Install Cloudflare"; item 2 "Run in terminal (foreground)"
    item 3 "Run in background (systemd)"; item 4 "Cloudflare Background Service"; item_exit
    prompt
    case $CHOICE in
      1) cf_install; pause;;
      2) read -rp "Tunnel token: " T; cloudflared tunnel run --token "$T"; pause;;
      3) read -rp "Tunnel token: " T; cloudflared service install "$T" && ok "Service installed"; pause;;
      4) systemctl status cloudflared --no-pager; echo; read -rp "start/stop/restart/(enter=back): " A; [ -n "$A" ] && systemctl "$A" cloudflared; pause;;
      0) return;;
    esac
  done
}
