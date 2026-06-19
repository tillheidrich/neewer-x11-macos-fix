#!/usr/bin/env bash
# diagnose.sh — read-only health check for the Neewer X11 / MacroSilicon UsbDisplay driver.
# Safe to run anytime. Makes no changes.
set -uo pipefail

APP=/Applications/MSDisplayManager.app                 # new layout (V3.2+)
BIN_NEW=/Applications/MSDisplayManager.app/Contents/Resources/MacUsbDisplay
BIN_OLD=/usr/local/bin/MacUsbDisplay                   # legacy layout (≤V3.0.x)
PLIST=/Library/LaunchAgents/com.macrosilicon.usbdisplay.plist
LABEL=com.macrosilicon.usbdisplay
APP_ID=com.macrosilicon.displaymanager

line(){ printf '\n\033[1m### %s\033[0m\n' "$1"; }

line "macOS version"
sw_vers

line "Apple Silicon?"
uname -m

line "Driver files present?"
ls -ld "$APP" 2>&1 || true
ls -l "$BIN_OLD" 2>&1 || true
ls -l "$PLIST" 2>&1 || true
if [ -e "$BIN_OLD" ] && [ ! -e "$APP" ]; then
  echo ">> LEGACY layout detected (old /usr/local/bin build). Update to the current app."
fi

line "Installed package version (pkg receipt)"
pkgutil --pkg-info "$LABEL" 2>&1 || echo "No pkg receipt found."

line "LaunchAgent loaded?"
launchctl list 2>/dev/null | grep -i macrosilicon || echo "NOT loaded"

line "Process running?"
pgrep -fl "MSDisplayManager|MacUsbDisplay" || echo "Neither MSDisplayManager nor MacUsbDisplay is running"

line "Code signature / notarization"
TARGET="$APP"; [ -e "$TARGET" ] || TARGET="$BIN_OLD"
if [ -e "$TARGET" ]; then
  codesign -dv --verbose=4 "$TARGET" 2>&1 | grep -Ei "Authority|TeamIdentifier|Identifier=|flags|Timestamp" || true
  echo "--- Gatekeeper assessment (notarization) ---"
  spctl -a -vv "$TARGET" 2>&1 || true
  echo "GOOD = 'Developer ID Application: Macrosilicon Technology Co., Ltd. (48FFBULTM4)' + accepted"
  echo "BAD  = 'Apple Development: …' (old 2023 dev-signed build) -> update"
else
  echo "Driver not installed."
fi

line "Is the MacroSilicon chip on the USB bus? (vendor 0x534D)"
system_profiler SPUSBDataType 2>/dev/null \
  | grep -iE -A3 "MacroSilicon|0x534d|USB Display|MS9[0-9]|teleprompt|prompter" \
  || echo "No MacroSilicon USB device detected — check cable / power / port (try a direct port, not a hub)."

line "Screen Recording (TCC) — is the driver allowed?"
echo "Check manually under System Settings > Privacy & Security >"
echo "Screen & System Audio Recording > enable 'MSDisplayManager'."

line "Recent driver log (last 10 min)"
log show --last 10m --predicate 'process == "MSDisplayManager" OR process == "MacUsbDisplay"' 2>/dev/null | tail -40 \
  || echo "No logs (process may never have started)."

line "Permission / capture errors in the log"
log show --last 10m --predicate 'process == "MSDisplayManager" OR process == "MacUsbDisplay"' 2>/dev/null \
  | grep -iE "permission|screen|denied|nil|fail|virtual|capture" | tail -20 \
  || echo "None found in the last 10 min."

line "Verdict hints"
cat <<'EOF'
- Files missing            -> run install-latest.sh
- Files present, NOT loaded -> run fix-permissions.sh
- Loaded but no USB device  -> cable/power/port issue
- USB device but black      -> grant Screen Recording, then log out/in or restart
- Gatekeeper "rejected"     -> stale 2023 build; install the current one
EOF
