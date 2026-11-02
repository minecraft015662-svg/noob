PTERO=/var/www/pterodactyl
blueprint_install(){
  [ -d "$PTERO" ] || { err "Pehle Pterodactyl panel install karo (menu 3)"; return 1; }
  info "Installing Node 20 + yarn + deps..."
  apt-get install -y ca-certificates curl gnupg zip unzip git wget
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
  apt-get update -y && apt-get install -y nodejs
  npm i -g yarn
  cd "$PTERO" || return 1
  yarn install
  info "Downloading Blueprint framework..."
  local url; url=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep -oP '"browser_download_url": "\K[^"]+release\.zip' | head -1)
  [ -n "$url" ] || { err "Blueprint release URL nahi mila"; return 1; }
  wget -q "$url" -O release.zip && unzip -o -q release.zip && rm release.zip
  cat > .blueprintrc <<RC
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
RC
  chmod +x blueprint.sh && bash blueprint.sh && ok "Blueprint installed"
}

# generic: install a .blueprint file from local path or URL
bp_install_file(){ # name path_or_url
  cd "$PTERO" || return 1
  local f="$PTERO/$1.blueprint"
  if [[ "$2" =~ ^https?:// ]]; then curl -fL -o "$f" "$2" || return 1; else cp "$2" "$f" || return 1; fi
  blueprint -install "$1"
}

themes_menu(){
  while true; do
    banner; title "Themes & Extensions Installer"
    item 1 "Nebula (Auto Install)"; item 2 "Euphoria (Auto Install)"
    item 3 "Aric Theme (Auto Install - requires LICENSE)"; item 4 "Uninstall"
    item 5 "Extensions Library (all extensions)"; item_exit
    prompt
    case $CHOICE in
      1) theme_install nebula "${NEBULA_SRC:-}"; pause;;
      2) theme_install euphoria "${EUPHORIA_SRC:-}"; pause;;
      3) read -rp "License key: " LIC; theme_install aric "${ARIC_SRC:-}" "$LIC"; pause;;
      4) read -rp "Extension/theme id to remove: " X; (cd $PTERO && blueprint -remove "$X"); pause;;
      5) ext_library;;
      0) return;;
    esac
  done
}
theme_install(){ # id src [license]
  local id="$1" src="$2"
  [ -z "$src" ] && src="/opt/sarthak34/extensions/$id.blueprint"
  if [ ! -f "$src" ] && [[ ! "$src" =~ ^https?:// ]]; then
    err "$id ka .blueprint file nahi mila."
    warn "File yahan rakho: /opt/sarthak34/extensions/$id.blueprint  ya  /etc/sarthak34.conf me ${id^^}_SRC=URL set karo"
    return 1
  fi
  [ -n "$3" ] && echo "$3" > "$PTERO/.${id}_license"
  bp_install_file "$id" "$src" && ok "$id installed"
}

blueprint_menu(){
  while true; do
    banner; title "Blueprint & Themes"
    item 1 "Blueprint install (fixed)"; item 2 "Themes + Extensions Installer"; item_exit
    prompt
    case $CHOICE in 1) blueprint_install; pause;; 2) themes_menu;; 0) return;; esac
  done
}
