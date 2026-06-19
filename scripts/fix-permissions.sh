#!/usr/bin/env bash
# fix-permissions.sh — reload the LaunchAgent and walk through the Screen Recording
# grant that makes the X11 picture actually appear. Run this after install + restart.
set -uo pipefail

PLIST=/Library/LaunchAgents/com.macrosilicon.usbdisplay.plist
LABEL=com.macrosilicon.usbdisplay

if [ ! -e "$PLIST" ]; then
  echo "Driver not installed (no LaunchAgent). Run ./install-latest.sh first."
  exit 1
fi

echo "==> Reloading the LaunchAgent ..."
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null \
  || launchctl load "$PLIST" 2>/dev/null || true
sleep 1
if pgrep -fl "MSDisplayManager|MacUsbDisplay" >/dev/null; then
  echo "    Display agent is running."
else
  echo "    WARNING: the display agent did not start — see ./diagnose.sh"
fi

cat <<'EOF'

==> ACTION REQUIRED (manual, ~30 seconds):

  System Settings > Privacy & Security > Screen & System Audio Recording
    -> turn ON "MSDisplayManager"

  With the current driver this is a normal, named app entry (it's a proper,
  Developer-ID-signed app), so it just appears in the list — no "+ add a binary"
  trickery. Then LOG OUT and back in (or restart). The screen stays black until
  this permission is granted — it's the #1 cause of "device detected but no picture".

  (Legacy 2023 build only: the entry was a bare binary "MacUsbDisplay" you had to
   add by hand via Cmd+Shift+G > /usr/local/bin/MacUsbDisplay. Update to avoid that.)

EOF

echo "Optional (heavy-handed): if the permission seems stuck, you can clear the whole"
echo "Screen Recording cache and re-grant all apps with:"
echo "    sudo tccutil reset ScreenCapture com.macrosilicon.displaymanager"
