#!/usr/bin/env bash
# Double-click to remove the Neewer X11 / MacroSilicon UsbDisplay driver.
# Shows a native confirmation dialog first — nothing happens until you agree.
set -uo pipefail

APP=/Applications/MSDisplayManager.app
BIN=/usr/local/bin/MacUsbDisplay
UNINST=/usr/local/bin/usbdisplay_uninstall
PLIST=/Library/LaunchAgents/com.macrosilicon.usbdisplay.plist
LABEL=com.macrosilicon.usbdisplay

ok=$(/usr/bin/osascript -e 'button returned of (display dialog "Remove the Neewer X11 display driver?\n\nThis will:\n• stop the background display agent\n• delete MSDisplayManager.app\n• delete its LaunchAgent\n\nYour Mac and other apps are not affected." buttons {"Cancel","Remove"} default button "Cancel" with title "Uninstall Neewer X11 Driver" with icon caution)')
[ "$ok" = "Remove" ] || { echo "Cancelled."; exit 0; }

echo "Removing driver (you'll be asked for your password)…"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
pkill -f MSDisplayManager 2>/dev/null || true
pkill -f MacUsbDisplay 2>/dev/null || true
[ -x "$UNINST" ] && sudo "$UNINST" 2>/dev/null || true
sudo rm -rf "$APP" /usr/local/bin/MSUsbDisplay.app /usr/local/bin/usbdisplay_uninstall.app
sudo rm -f "$BIN" "$UNINST" "$PLIST"
sudo pkgutil --forget "$LABEL" 2>/dev/null || true

/usr/bin/osascript -e 'display dialog "Driver removed.\n\nA restart is recommended before reinstalling." buttons {"OK"} default button "OK" with title "Uninstall Neewer X11 Driver" with icon note' >/dev/null 2>&1 || true
echo "Done."
