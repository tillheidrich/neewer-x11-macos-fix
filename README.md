# Neewer X11 on macOS Tahoe (26) — Display Fix Toolkit

![status](https://img.shields.io/badge/status-confirmed%20working-brightgreen)
![macOS](https://img.shields.io/badge/macOS-Tahoe%2026-blue)
![silicon](https://img.shields.io/badge/Apple%20Silicon-M1%E2%80%93M5-black)
![license](https://img.shields.io/badge/license-MIT-green)

Get the **Neewer X11 teleprompter** working again as an external/third display on **macOS Tahoe (26)** and Apple Silicon (M1–M5).

> ✅ **Confirmed working on macOS Tahoe 26 + MacBook M1 Pro** (X11 as a 3rd display).
> Unofficial, community-made — not affiliated with Neewer or MacroSilicon.

> **This is not a custom driver, and it doesn't need to be.** The X11's "driver"
> is a rebranded **MacroSilicon UsbDisplay** package. Neewer ships an outdated
> **2023** build (`V3.0.6.29`) that breaks on modern macOS. MacroSilicon itself
> has kept the driver updated all the way to **V3.3.2.59 (March 2026)**, which
> officially supports macOS up to **26.2**. This toolkit removes the stale build,
> installs the current upstream one, fixes the permission that breaks across OS
> upgrades, and gives you a one-shot diagnostic.

---

## TL;DR — just fix it

```bash
chmod +x scripts/*.sh
./scripts/diagnose.sh          # see what's actually wrong on your Mac
./scripts/install-latest.sh    # remove old build, install official V3.3.2.59
# restart, then:
./scripts/fix-permissions.sh   # reload agent + Screen Recording guidance
```

After the restart, grant **Screen Recording** to `MacUsbDisplay` (see step 3 below)
and the X11 shows up under **System Settings → Displays** as an extra screen.

---

## The problem

On macOS Tahoe the X11 (connected via the bundled USB‑A → HDMI + USB‑C data
cable) is **no longer detected as a display**. USB‑C↔USB‑C works for the
prompter UI, but the DisplayLink-style "extra monitor" function is dead. Neewer's
driver download (dated 11/2025) doesn't help. Installing DisplayLink doesn't help
either — **because the X11 is not a DisplayLink device.**

## Root cause (what's actually inside the package)

Forensic teardown of `UsbDisplay.pkg` (the file Neewer ships):

| Fact | Evidence |
|------|----------|
| Vendor is **MacroSilicon**, not DisplayLink/Synaptics | pkg id `com.macrosilicon.usbdisplay`, build paths `/Users/ms/…`, `…sza/` (Shenzhen) |
| It's a **userspace app**, no kext / DriverKit | installs `/usr/local/bin/MacUsbDisplay` + a **LaunchAgent** `com.macrosilicon.usbdisplay` |
| It's a **DisplayLink clone built in‑house** (to dodge licensing) | uses Apple's *private* `CGVirtualDisplay*` classes to fake a 3rd screen, then screen‑grabs it |
| Capture path is **deprecated** | calls `CGWindowListCreateImage` / `CGDisplayCreateImage` — deprecated since macOS 14, broken/`nil` on 15/26 |
| Pixels pushed over USB via **libusb + libyuv** | classic homegrown USB‑display engine |
| Binary is only **Development‑signed, not notarized** | signature: `Apple Development: Yuankang Li (6KQU23K5UP)` — meant for the dev's own machine |
| Build is **from Dec 2023** | `UsbDisplay_macOS_V3.0.6.29_20231208`, SDK 13.1, min‑OS 11.0 |

So it breaks on Tahoe for three compounding reasons: a **deprecated capture API**,
a **non‑notarized dev‑signed binary** under Apple Silicon's stricter launch policy,
and a **stale Screen Recording (TCC) grant** that gets dropped on OS upgrade.

## The fix

MacroSilicon never stopped updating. Per their official `readme.txt`:

| Driver line | Supported macOS |
|-------------|-----------------|
| `3.1.x.x`   | 10.15 → 15.6 |
| `3.2.x.x`   | 10.15 → **26.0** |
| `3.3.x.x`   | 12.3 → **26.2** |

**Latest:** `MacroSilicon_UsbDisplay_V3.3.2.59_20260320_1655.pkg` (20 Mar 2026).

`install-latest.sh` removes the old 2023 build and installs this one.

### Verified: why the current build actually fixes it

We tore down `V3.3.2.59` the same way as the old one. Every 2023 failure cause is
gone:

| | old `V3.0.6.29` (2023) | current `V3.3.2.59` (2026) |
|---|---|---|
| Signature | `Apple Development: Yuankang Li` (dev‑only cert) | **`Developer ID Application: Macrosilicon Technology Co., Ltd. (48FFBULTM4)`** → notarizable, Gatekeeper‑clean |
| Packaging | bare binary in `/usr/local/bin` | proper **`/Applications/MSDisplayManager.app`** (stable bundle id → clean Screen Recording entry) |
| Capture API | deprecated `CGWindowListCreateImage` only | **ScreenCaptureKit** (`SCStream`) with `isUsingScreenCaptureKit()` |
| Built against | SDK 13.1, 2023 | app min‑OS 12.4, 2026; ships its own preinstall cleanup |

So the trustworthiness problem you felt with the old installer is largely solved by
the vendor itself: the current driver is a signed, notarized, properly‑bundled app.

## Manual steps (if you prefer not to run the scripts)

1. **Uninstall the old driver**
   ```bash
   sudo /usr/local/bin/usbdisplay_uninstall            # if present
   launchctl bootout gui/$(id -u)/com.macrosilicon.usbdisplay 2>/dev/null
   sudo rm -f /usr/local/bin/MacUsbDisplay /Library/LaunchAgents/com.macrosilicon.usbdisplay.plist
   sudo pkgutil --forget com.macrosilicon.usbdisplay
   ```
2. **Install the current build** — download from
   `http://www.macrosilicon.com:9080/download/USBDisplay/macOS/Installer/`
   and run the `.pkg`. **Restart** when prompted.
3. **Grant Screen Recording** — this is what makes the picture appear:
   *System Settings → Privacy & Security → Screen & System Audio Recording* →
   enable **MSDisplayManager**. With the current driver it's a normal named app in
   the list (no manual binary‑adding). Then log out & back in.
4. **Cold‑start in order** — shut down fully → plug in & power the X11 → power on
   the Mac. DisplayLink‑style devices need the handshake at boot.
5. Check **System Settings → Displays** → set the new screen to *Extended*.

## Scripts

| Script | What it does |
|--------|--------------|
| `scripts/diagnose.sh` | Reads macOS version, driver files, LaunchAgent state, code signature/notarization, whether the MacroSilicon chip enumerates on USB (vendor `0x534D`), and the last 10 min of `MacUsbDisplay` logs. Read‑only. |
| `scripts/install-latest.sh` | Downloads the official **V3.3.2.59** pkg, removes the old build, installs it. Needs admin + a restart. |
| `scripts/fix-permissions.sh` | Reloads the LaunchAgent and walks you through the Screen Recording grant. |
| `scripts/uninstall.sh` | Cleanly removes the driver (agent, binary, plist, pkg receipt). |

## One double-click install (.pkg / .dmg)

Prefer a real installer over running scripts? Build one with Apple's own tools — no
third-party packaging, fully inspectable:

```bash
installer/fetch-driver.command  # (optional) double-click → pulls the official driver in to EMBED it
installer/build-pkg.command     # double-click → Neewer-X11-…-Installer.pkg
installer/build-dmg.command     # double-click → …-Driver.dmg (wraps the pkg)
```

If you ran `fetch-driver.command` first, the driver is **embedded** and the
installer works fully offline. If not, the installer downloads it from MacroSilicon
at install time. Either way we never commit the vendor binary to the repo (see
`.gitignore` / `SOURCES.md`).

The `.pkg` installs the toolkit and, in its `postinstall`, removes the old driver
and installs the **current official MacroSilicon build** — then shows a native
dialog with the next steps. To remove everything later, double-click
**`Uninstall Neewer X11 Driver.command`** (it asks for confirmation in a normal
macOS dialog first — no scary terminal).

**Make it Gatekeeper-clean** (recommended if you redistribute it): sign + notarize.
```bash
SIGN_ID="Developer ID Installer: Your Name (TEAMID)" installer/build-pkg.command
xcrun notarytool submit <pkg> --keychain-profile <profile> --wait
xcrun stapler staple <pkg>
```

## Why you can trust this

The original installer *did* feel like malware — unsigned, a background `curl`, a
permission grab with no explanation. This toolkit fixes that:

- **Open source, MIT.** Every line is readable; nothing is obfuscated.
- **Downloads only from MacroSilicon's official server** — the exact URL is printed
  before anything runs, and logged to `/tmp/neewer-x11-fix.log`.
- **No telemetry, no analytics, no background daemons of our own.**
- **Native confirmation dialogs** for install/uninstall — you approve before action.
- **Signable & notarizable** with your Apple ID so the "unidentified developer"
  warning disappears entirely.
- We **don't redistribute** the driver — you always get it straight from the vendor.

## Hardware alternative: skip the driver entirely with USB‑C

The whole driver saga exists **only because of the USB‑A port**: USB‑A (USB 3.0
Type‑A) can't carry video, so MacroSilicon's chip is needed to push pixels over
plain USB. Over **USB‑C**, your Mac drives a display natively (DisplayPort Alt
Mode) — **no driver, no Tahoe problem.** Use the bundled **USB‑C ↔ USB‑C** cable
where possible.

The catch on Apple Silicon: native USB‑C displays are limited by the chip — an
**M1 Pro supports 2 external displays**, M1 Max 4, base M1/M2 only 1. If the X11 is
your **3rd** screen beyond that limit, USB‑C native won't add it, and you need a
USB‑graphics adapter regardless.

In that case, the most robust option is a **USB‑C DisplayLink adapter** (not this
MacroSilicon path), because DisplayLink has a properly **notarized, Tahoe‑26
driver** (DisplayLink Manager 16.0): feed the X11's HDMI into one of these —
Plugable `USBC‑6950M`, OWC USB‑C Dual HDMI, Sonnet, or Acasis. More reliable than
the rebadged 2023 driver, and maintained.

## If it still doesn't work

- **`diagnose.sh` shows no MacroSilicon USB device** → cable/power/port problem
  (the USB‑A splitter is power‑hungry; use a direct port, or replace the splitter
  with separate HDMI + USB‑C 20 Gbps cables).
- **Device enumerates but screen stays black** → almost always the Screen Recording
  grant (step 3) or a missing restart.
- **Agent won't launch / Gatekeeper blocks it** → `diagnose.sh` will show the
  `spctl`/`codesign` verdict; report it upstream (see Credits).

## Honest scope / what this is not

- ❌ Not a from‑scratch driver. The USB protocol to the MacroSilicon chip is
  proprietary and undocumented, and no third party can Apple‑notarize a kernel/
  DriverKit driver for it. Tools like BetterDisplay can create a virtual display
  but cannot push pixels to *this* chip.
- ✅ A clean, documented way to get the **official, current, Tahoe‑capable**
  MacroSilicon build installed and permissioned — which is what actually fixes it.

## Community / found via

Threads that surfaced the problem (and that this fix answers):
- r/videography — X11 not detected on Mac Studio M4 / MacBook M1: <https://www.reddit.com/r/videography/comments/1riz87s/>
- r/MacOS — Elgato Prompter + DisplayLink on macOS 26 (same symptom, different chip): <https://www.reddit.com/r/MacOS/comments/1skb931/>
- r/neewer — X11 cable / driver availability: <https://www.reddit.com/r/neewer/comments/1qg70ru/>

Full attribution in [`SOURCES.md`](SOURCES.md).

## Publish to GitHub

```bash
cd neewer-x11-macos-fix
git init -b main
git add .                 # .gitignore already excludes the vendor binary + build outputs
git commit -m "Neewer X11 macOS Tahoe fix v1.0.0"
git remote add origin git@github.com:<you>/neewer-x11-macos-fix.git
git push -u origin main
```

Then drop the repo URL into the placeholders in `REDDIT.md` and
`neewer-support-email.md`. Don't commit `installer/driver/*.pkg` — it's the vendor's
binary (the `.gitignore` keeps it out automatically).

## Credits / upstream

- **Driver:** MacroSilicon — <http://www.macrosilicon.com:9080/download/USBDisplay/>
- **Community mirror & docs:** <https://github.com/MindShow/USBDisplay>
- Teardown & toolkit: this repo.

## License

MIT — see [LICENSE](LICENSE). The MacroSilicon driver itself is **not** covered by
this license; it remains the property of MacroSilicon and is only linked to, not
redistributed here.
