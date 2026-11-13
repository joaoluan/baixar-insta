#!/usr/bin/env bash
# Instala o baixar-insta + camofox-browser + serviço systemd + atalhos na Área de Trabalho.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CAMOFOX_DIR="${CAMOFOX_DIR:-$HOME/Projetos/camofox-browser}"
BIN_DIR="$HOME/.local/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
APPS_DIR="$HOME/.local/share/applications"
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Área de trabalho")"
[ -d "$DESKTOP_DIR" ] || DESKTOP_DIR="$HOME/Desktop"

echo "==> 1/5 Verificando dependências do sistema (python3, zenity, git, curl, xvfb)..."
MISSING=()
for cmd in python3 zenity git curl xvfb-run; do
  command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "Instalando pacotes ausentes (${MISSING[*]}) via apt..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq python3 zenity git curl xvfb libgtk-3-0 libdbus-glib-1-2 libasound2t64 || \
    sudo apt-get install -y -qq python3 zenity git curl xvfb libgtk-3-0 libdbus-glib-1-2 libasound2
fi

echo "==> 2/5 Localizando Node.js >= 22..."
find_node() {
  if command -v node >/dev/null 2>&1; then
    ver="$(node -v | sed 's/^v//;s/\..*//')"
    [ "${ver:-0}" -ge 22 ] && { command -v node; return 0; }
  fi
  for n in $(ls -1d "$HOME"/.nvm/versions/node/v*/bin/node 2>/dev/null | sort -rV); do
    ver="$("$n" -v | sed 's/^v//;s/\..*//')"
    [ "${ver:-0}" -ge 22 ] && { echo "$n"; return 0; }
  done
  return 1
}

if ! NODE_BIN="$(find_node)"; then
  echo "Node >= 22 não encontrado. Instalando via NVM..."
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install 24
  NODE_BIN="$(find_node)"
fi
NPM_BIN="$(dirname "$NODE_BIN")/npm"
echo "    Node: $NODE_BIN ($("$NODE_BIN" -v))"

echo "==> 3/5 Configurando camofox-browser em $CAMOFOX_DIR..."
mkdir -p "$(dirname "$CAMOFOX_DIR")"
if [ ! -d "$CAMOFOX_DIR/.git" ]; then
  git clone https://github.com/jo-inc/camofox-browser.git "$CAMOFOX_DIR"
fi
if [ ! -d "$CAMOFOX_DIR/node_modules" ]; then
  (cd "$CAMOFOX_DIR" && PATH="$(dirname "$NODE_BIN"):$PATH" "$NPM_BIN" install)
fi

echo "==> 4/5 Instalando script e serviço systemd (camofox.service)..."
mkdir -p "$BIN_DIR" "$SYSTEMD_DIR"
chmod +x "$REPO_DIR/baixar-insta"
ln -sf "$REPO_DIR/baixar-insta" "$BIN_DIR/baixar-insta"

cat > "$SYSTEMD_DIR/camofox.service" <<EOF
[Unit]
Description=camofox-browser

[Service]
WorkingDirectory=$CAMOFOX_DIR
Environment=CAMOFOX_BIND_HOST=127.0.0.1
Environment=CAMOFOX_CRASH_REPORT_ENABLED=false
ExecStart=$NODE_BIN server.js
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now camofox.service

echo "==> 5/5 Criando atalhos na Área de Trabalho e no menu de aplicativos..."
mkdir -p "$APPS_DIR" "$DESKTOP_DIR"

BAIXAR_DESKTOP="[Desktop Entry]
Type=Application
Name=Baixar do Instagram
Comment=Baixa fotos e vídeos de um link do Instagram
Exec=$BIN_DIR/baixar-insta
Icon=folder-download
Terminal=false"

LOGIN_DESKTOP="[Desktop Entry]
Type=Application
Name=Login Instagram (baixador)
Comment=Entra na conta secundária do Instagram usada pelo Baixar do Instagram
Exec=$BIN_DIR/baixar-insta --login
Icon=system-users
Terminal=false"

for dir in "$APPS_DIR" "$DESKTOP_DIR"; do
  printf '%s\n' "$BAIXAR_DESKTOP" > "$dir/baixar-instagram.desktop"
  printf '%s\n' "$LOGIN_DESKTOP" > "$dir/login-instagram.desktop"
  chmod +x "$dir/baixar-instagram.desktop" "$dir/login-instagram.desktop"
  if command -v gio >/dev/null 2>&1; then
    gio set "$dir/baixar-instagram.desktop" metadata::trusted true 2>/dev/null || true
    gio set "$dir/login-instagram.desktop" metadata::trusted true 2>/dev/null || true
  fi
done

echo ""
echo "Pronto! Instalação concluída:"
echo "  - Script:   $BIN_DIR/baixar-insta"
echo "  - Serviço:  systemctl --user status camofox"
echo "  - Atalhos:  $DESKTOP_DIR/{baixar-instagram,login-instagram}.desktop"
