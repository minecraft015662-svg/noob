#!/usr/bin/env bash
# SARTHAK34 - Pterodactyl Panel Toolkit
BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$BASE/lib/ui.sh"
for m in "$BASE"/modules/*.sh; do . "$m"; done
need_root
while true; do
  banner
  item 1 "🔄 System Update"
  item 2 "☁️  Cloudflare"
  item 3 "📁 Pterodactyl Panel Setup"
  item 4 "🕸️  Wings Setup"
  item 5 "🖥️  System Spec"
  item 6 "🎨 Blueprint + Themes (Fixed)"
  item 7 "📦 Installed Apps"
  item 8 "💬 Credits"
  item 9 "🗑️  Uninstall"
  printf "  %s❯%s %s10%s 🚀 %sAuto Setup [Panel + Cloudflare + Blueprint + Nebula + Wings]%s\n" "$AQUA" "$R" "$YEL" "$R" "$YEL" "$R"
  printf "  %s❯%s %s11%s 🧩 %sPanel Install Manager [Pterodactyl / Paymenter + Domain]%s\n" "$AQUA" "$R" "$YEL" "$R" "$YEL" "$R"
  item_exit
  prompt
  case $CHOICE in
    1) run_update; pause;;
    2) cf_menu;;
    3) panel_menu; pause;;
    4) wings_menu;;
    5) run_spec; pause;;
    6) blueprint_menu;;
    7) show_apps; pause;;
    8) show_credits; pause;;
    9) uninstall_menu;;
    10) auto_setup; pause;;
    11) panelmgr_menu;;
    0) clear; exit 0;;
  esac
done
