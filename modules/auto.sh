auto_setup(){
  banner; title "Auto Setup [Panel + Cloudflare + Blueprint + Nebula + Wings]"
  local D E U P; ask D "Panel Domain" "panel.example.com"; ask E "Admin Email" "admin@example.com"
  ask U "Admin Username" "admin"; ask P "Admin Password" "$(rand 12)" secret
  confirm "Start full auto setup?" || return
  run_update
  cf_install
  install_ptero_panel "$D" "$E" "$U" "$P"
  blueprint_install
  theme_install nebula "${NEBULA_SRC:-}"
  wings_install; wings_service
  ok "Auto setup complete. Panel: https://$D"
}
