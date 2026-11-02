# Sarthak34 – Pterodactyl Panel Toolkit

One-command toolkit (menu UI, aqua box) for Debian/Ubuntu.

## Install
```bash
git clone https://github.com/<your-user>/sarthak34-toolkit.git
cd sarthak34-toolkit && sudo bash install.sh
sudo sarthak34
```

## Menu
1 System Update · 2 Cloudflare · 3 Panel Setup · 4 Wings · 5 System Spec · 6 Blueprint + Themes ·
7 Installed Apps · 8 Credits · 9 Uninstall · 10 Auto Setup · **11 Panel Install Manager** (domain / email / password)

## Extensions
- Edit `extensions/extensions.list` (one id per line).
- Put `<id>.blueprint` files in `/opt/sarthak34/extensions/` OR set `EXT_BASE_URL` in `/etc/sarthak34.conf`.
- Commands: `23`, `1,2,4`, `r23`, `all`, `r all`, `template`, `best`, `keep`, `repair`.
- Themes (Nebula/Euphoria/Aric): set `NEBULA_SRC` etc. in `/etc/sarthak34.conf`. Paid themes need your own valid license/files.
