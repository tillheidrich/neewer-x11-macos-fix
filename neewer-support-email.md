# Cheeky-but-polite email to Neewer support

**To:** support@neewer.com
**Subject:** I fixed your X11 macOS Tahoe driver for you — finder's fee? 😄

---

Hi Neewer team,

I'm a happy X11 owner — great teleprompter for the price. Less great: on **macOS
Tahoe (26)** the X11 stopped working as an external display. The driver in your
download section (and in the box) is **UsbDisplay V3.0.6.29 from December 2023**,
which predates Tahoe and no longer runs properly on Apple Silicon.

So I dug in. The X11's driver is a rebranded **MacroSilicon UsbDisplay** package.
The good news: MacroSilicon themselves never stopped updating it. Their current
build **V3.3.2.59 (March 2026)** officially supports macOS **up to 26.2** — your
customers just never get pointed to it.

To save your support team the repeated tickets, I put together a small open-source
fix (uninstall the stale build → install the current official MacroSilicon one →
fix the Screen Recording permission), with a proper installer and uninstaller:

  👉 <https://github.com/tillheidrich/neewer-x11-macos-fix>  *(replace with real URL)*

Two friendly asks:

1. **Please update the X11 download page** to ship the current MacroSilicon build
   (or at least link customers to it). It's a one-line fix on your side that kills
   a whole category of "X11 not detected on Mac" complaints.
2. And — only half-joking — if this saved you some support hours, I wouldn't say no
   to a **thank-you**. Pick whatever feels right on your side:
   - *Smallest:* a discount code on my next Neewer order.
   - *Fair:* a piece of gear (the X11's matched accessories would be fitting 😄).
   - *Win-win:* link my repo from your X11 support page so Tahoe users find the fix —
     costs you nothing and cuts your ticket volume.

   Honestly, the repo shout-out is the one I'd value most — but I won't pretend a
   gear box wouldn't make my week.

Happy to share my full teardown notes if your engineers want them.

Best regards,
Till Heidrich
mail@tillheidrich.de

---

*P.S. — Honestly, the simplest long-term fix for everyone: bump the bundled driver
and add one sentence to the manual telling Mac users to grant Screen Recording.
That's the whole bug.*
