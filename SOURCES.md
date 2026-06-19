# Sources & Credits

We want to be fair: this toolkit is built entirely on other people's work. The
actual driver is **not ours** — it's MacroSilicon's. All we did is reverse‑engineer
what Neewer ships, find the current upstream build, and wrap it in scripts + docs.

## The driver itself
- **MacroSilicon (Nanjing) Co., Ltd.** — original author of the UsbDisplay driver
  used inside the Neewer X11.
  - Official download index: <http://www.macrosilicon.com:9080/download/USBDisplay/>
  - macOS installers: <http://www.macrosilicon.com:9080/download/USBDisplay/macOS/Installer/>
  - Compatibility note (`readme.txt`): `3.2.x = macOS 10.15–26.0`, `3.3.x = macOS 12.3–26.2`
- **Neewer** — ships a rebrand of the above for the X11 (the version we found in the
  box was the outdated `V3.0.6.29`, Dec 2023).

## Community work we relied on
- **MindShow/USBDisplay** — community mirror & documentation for MacroSilicon drivers
  across Windows/macOS/Android/Linux, incl. the "Screen Recording" black‑screen FAQ.
  <https://github.com/MindShow/USBDisplay>
  - Issue #98 (newer MacroSilicon drivers need porting): <https://github.com/MindShow/USBDisplay/issues/98>
- **`ms912x` Linux driver** — open reverse‑engineering of the same chip family
  (USB device `534d:6021`), useful confirmation of the MacroSilicon vendor id `0x534D`.
  Discussion: <https://forum.manjaro.org/t/compile-and-install-linux-ms912x-driver-for-device-534d-6021-usb-3-0-to-hdmi-adapter/150061>
- **Technical support by UltraSemi** (listed by MacroSilicon): <http://www.ultrasemi.com>

## Apple / platform references
- DisplayLink (for context — the X11 is *not* DisplayLink, but the failure mode is
  identical): Screen Recording permission requirement —
  <https://support.displaylink.com/knowledgebase/articles/2008685-macos-screen-recording-permission>
- macOS Tahoe external‑display detection issues (community):
  <https://iboysoft.com/tips/external-monitor-not-detected-on-macos-tahoe.html>

## Reports that confirmed the problem
- Reddit r/neewer, r/videography, r/MacOS — multiple users reporting the X11 /
  Elgato Prompter no longer detected on macOS 26 / DisplayLink 16. (Symptom match;
  the Elgato Prompter is genuine DisplayLink, the X11 is MacroSilicon.)

## What this repo adds
- Forensic teardown of the shipped `UsbDisplay.pkg` (vendor, mechanism, signing,
  API usage), the mapping to the correct current upstream build, and the
  install/diagnose/permission scripts.

---
*Unofficial project. Not affiliated with, authorized by, or endorsed by Neewer or
MacroSilicon. All trademarks belong to their respective owners.*
