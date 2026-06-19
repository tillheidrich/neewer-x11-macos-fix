# Installation Guide — pick your path

First, find out which situation you're in. The key question is: **do you already
have the (old) Neewer/MacroSilicon driver installed?**

Quick check in Terminal:

```bash
ls -ld /Applications/MSDisplayManager.app /usr/local/bin/MacUsbDisplay 2>/dev/null && echo "DRIVER PRESENT" || echo "NO DRIVER INSTALLED"
```

Or just run the read‑only diagnostic:

```bash
chmod +x scripts/*.sh
./scripts/diagnose.sh
```

> ⚠️ The driver has **no self‑update**. An old build will never upgrade itself —
> it must be removed and replaced. That's why both paths below end at the same
> current build.

---

## Path A — You already installed the old Neewer driver (it's not working)

This is most people. The 2023 build is present but broken on Tahoe.

1. **Remove the old driver completely:**
   ```bash
   ./scripts/uninstall.sh
   ```
2. **Restart** your Mac (recommended — clears the old LaunchAgent + TCC state).
3. **Install the current build:**
   ```bash
   ./scripts/install-latest.sh
   ```
4. **Restart** again when the installer asks.
5. **Grant Screen Recording** + reload:
   ```bash
   ./scripts/fix-permissions.sh
   ```
   Then enable **MSDisplayManager** under
   *System Settings → Privacy & Security → Screen & System Audio Recording*,
   and **log out & back in**.
6. Plug in / power the X11 → check **System Settings → Displays** → set to *Extended*.

> Don't skip step 1. Installing the new pkg over a half‑working old one is the
> classic way to end up with a stuck LaunchAgent and a black screen.

---

## Path B — Fresh Mac, no driver yet

1. **Install the current build:**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/install-latest.sh
   ```
2. **Restart** when prompted.
3. **Grant Screen Recording** + reload:
   ```bash
   ./scripts/fix-permissions.sh
   ```
   Enable **MSDisplayManager** in
   *System Settings → Privacy & Security → Screen & System Audio Recording*,
   then **log out & back in**.
4. Plug in / power the X11 → **System Settings → Displays** → *Extended*.

---

## Path C — You're not sure / you tried several things already

1. Run `./scripts/diagnose.sh` and read the **Verdict hints** at the bottom.
2. Whatever it says, the safe reset is: `./scripts/uninstall.sh` → restart →
   `./scripts/install-latest.sh` → restart → `./scripts/fix-permissions.sh`.
3. Also uninstall **DisplayLink Manager** if you installed it — it does nothing for
   this device (the X11 is MacroSilicon, not DisplayLink) and can confuse the USB
   display stack.

---

## Still black after all of this?

Run `./scripts/diagnose.sh` and check:

| diagnose.sh shows | meaning | do |
|---|---|---|
| No MacroSilicon USB device | cable/power/port | use a **direct** port (no hub); the USB‑A splitter is power‑hungry — try separate HDMI + USB‑C 20 Gbps cables |
| Device present, screen black | permission/restart | redo Screen Recording grant + log out/in |
| Agent won't launch / Gatekeeper rejected | you're still on the old build | `uninstall.sh` then `install-latest.sh` |

Cold‑start trick that fixes a lot: **shut down → plug in & power the X11 → power on
the Mac.** DisplayLink‑style devices want the handshake at boot.
