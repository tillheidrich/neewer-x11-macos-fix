# Embedded driver goes here

This folder is where the **official MacroSilicon driver** lands so the installer can
bundle it (fully offline install, nothing downloaded at install time).

**How to fill it:** double-click `installer/fetch-driver.command`. It downloads the
current official build straight from MacroSilicon into this folder. Then run
`installer/build-pkg.command` — it auto-embeds whatever `.pkg` is here.

**Why it's not committed to git:** the driver is MacroSilicon's proprietary
software. We link to it and install it, but we don't redistribute it (see
`.gitignore` and `SOURCES.md`). Each person fetches their own copy from the vendor.

> Want a fully self-contained `.dmg` to hand to a friend? Fetch the driver, build
> the pkg/dmg locally, and share that file privately. Just don't publish the
> vendor's binary in a public repo.
