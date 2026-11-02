#!/usr/bin/env bash
set -e
[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }
SRC="$(cd "$(dirname "$0")" && pwd)"
mkdir -p /opt/sarthak34
cp -r "$SRC"/. /opt/sarthak34/
chmod +x /opt/sarthak34/sarthak34.sh
ln -sf /opt/sarthak34/sarthak34.sh /usr/local/bin/sarthak34
[ -f /etc/sarthak34.conf ] || cat > /etc/sarthak34.conf <<'CONF'
# Sarthak34 Toolkit config
# Where to download <id>.blueprint files from (your own hosting / GitHub releases / raw):
EXT_BASE_URL=""
# Theme sources (local path or URL to .blueprint)
NEBULA_SRC=""
EUPHORIA_SRC=""
ARIC_SRC=""
CONF
echo "Installed. Run:  sarthak34"
