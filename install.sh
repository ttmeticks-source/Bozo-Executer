#!/usr/bin/env bash
set -e

REPO="https://raw.githubusercontent.com/ttmeticks-source/Bozo-Executer/main"
APP_DIR="$HOME/Applications"
TEMP=$(mktemp -d)

G=$'\033[32m'; C=$'\033[36m'; R=$'\033[0m'; B=$'\033[1m'

clear
echo -e "${C}${B}"
echo "  ██████╗  ██████╗ ███████╗ ██████╗ "
echo "  ██╔══██╗██╔═══██╗╚══███╔╝██╔═══██╗"
echo "  ██████╔╝██║   ██║  ███╔╝ ██║   ██║"
echo "  ██╔══██╗██║   ██║ ███╔╝  ██║   ██║"
echo "  ██████╔╝╚██████╔╝███████╗╚██████╔╝"
echo "  ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝ "
echo -e "${R}"
echo -e "${C}Made By: C0oled!${R}\n"

loader() {
    printf "  ${C}➜${R} %s " "$1"
    for i in {1..15}; do printf "${C}.${R}"; sleep 0.04; done
    printf " ${G}✔${R}\n"
}

mkdir -p "$APP_DIR"

loader "Installing Bozo Executer App"
curl -fsSL "$REPO/bin/BozoExecuter.zip" -o "$TEMP/app.zip"
unzip -oq "$TEMP/app.zip" -d "$TEMP"
mv -f "$TEMP/BozoExecuter.app" "$APP_DIR/BozoExecuter.app"

loader "Fetching Roblox Client"
curl -sL "https://setup.rbxcdn.com/mac/version-b09c93298b5d4cd1-RobloxPlayer.zip" -o "$TEMP/rbx.zip"
unzip -oq "$TEMP/rbx.zip" -d "$TEMP"
mv -f "$TEMP/RobloxPlayer.app" "$APP_DIR/Roblox.app"
xattr -cr "$APP_DIR/Roblox.app"

loader "Injecting and Signing"
curl -fsSL "$REPO/bin/libBozoExecuter.dylib" -o "$TEMP/lib.dylib"
curl -fsSL "$REPO/bin/insert_dylib" -o "$TEMP/insert_dylib"
chmod +x "$TEMP/insert_dylib"

cp "$TEMP/lib.dylib" "$APP_DIR/Roblox.app/Contents/Resources/"
codesign --remove-signature "$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer" >/dev/null 2>&1

"$TEMP/insert_dylib" --strip-codesig --all-yes \
  "@executable_path/../Resources/libBozoExecuter.dylib" \
  "$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer" \
  "$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer_patched" >/dev/null 2>&1

mv "$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer"
codesign --force --deep --sign - "$APP_DIR/Roblox.app" >/dev/null 2>&1
codesign --force --deep --sign - "$APP_DIR/BozoExecuter.app" >/dev/null 2>&1

echo -e "\n  ${G}${B}Installation complete. Opening Apps...${R}"
sleep 1
open "$APP_DIR/Roblox.app"
open "$APP_DIR/BozoExecuter.app"
rm -rf "$TEMP"
