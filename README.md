# Dad's laptop: senior-friendly Silverblue

This rebuilds the same system as this machine (uBlue Silverblue, Windows-style taskbar and Start menu)
from a recipe instead of cloning the disk. **No personal data goes into the ISO.** Your home folder,
SSH keys, Wi-Fi passwords, browser profiles and logins are never copied.

## What's in it
| | |
|---|---|
| Base | `silverblue-main` (or `silverblue-nvidia` with `NVIDIA=1`) |
| Look | Dash-to-Panel taskbar (56 px, large icons) + ArcMenu "Redmond" Start menu |
| Taskbar | Chrome, Files, Writer, Calendar, Photos |
| Apps (installed on first boot, needs internet) | Chrome, LibreOffice, Calculator, Calendar, Contacts, Clocks, Weather, Maps, Image Viewer, PDF reader (Papers), Text Editor, Camera |
| Left out on purpose | Sunshine (remote streaming), Extension Manager, Logs, Media Writer, other tools |

## Senior-friendly defaults (files/etc/dconf/db/local.d/00-senior-friendly)
- Text 125%, mouse pointer 48 px, press **Ctrl** to locate the pointer
- Slower double-click (600 ms), tap-to-click, Windows-style scroll direction
- No hot corner (no surprise Activities view), no window snapping when dragging to the edge
- Clock shows weekday and date; battery shows %
- Screen blanks after 15 min, locks 5 min later
- Updates download and install silently: OS updates are staged automatically and apply on the next restart

## Build
Run on the **host** terminal, not in a toolbox:
```bash
cd ~/dad-laptop
./build.sh                    # Intel/AMD graphics
NVIDIA=1 ./build.sh           # NVIDIA laptop
```
The ISO lands in `output/bootiso/`. Write it to USB with Fedora Media Writer.

**Test first:** boot the ISO in GNOME Boxes before wiping the laptop.

## Updates: do this, or Dad's laptop stops updating
An ISO built from a `localhost/` image has no registry to pull updates from. Pick one:
1. **Recommended:** push the image to GitHub's registry. Use the uBlue `image-template` repo:
   copy this Containerfile and `files/` into it, and GitHub Actions rebuilds it daily on top of new uBlue images.
   Then build with `IMAGE_REF=ghcr.io/<you>/dad-silverblue:latest ./build.sh`. The installer
   points the laptop at that image.
2. **Simplest:** after installing, run `sudo bootc switch ghcr.io/ublue-os/silverblue-main:latest`.
   The laptop gets updates, but the next update removes the taskbar and Start menu. You'd then
   have to run `rpm-ostree install gnome-shell-extension-dash-to-panel` and install ArcMenu
   from Extension Manager. The settings in `/etc` are kept.

## Before handing it over (manual)
- [ ] Create Dad's account in the installer. Consider **auto-login** (Settings → Users) if the laptop stays home
- [ ] Sign in to Chrome with **his** Google account. Import his bookmarks from Windows first
- [ ] Copy his Documents and Photos from the old Windows disk **before** the install wipes it
- [ ] Printer: Settings → Printers (most network printers are found automatically)
- [ ] Remote help: turn on Settings → System → Remote Desktop, or install RustDesk. With Tailscale on both machines you can help him from anywhere
- [ ] Leave a printed one-page "how to" next to the laptop: power, Wi-Fi, Chrome, where photos go
- [ ] Optional: Settings → Accessibility → Large Text / High Contrast if his eyesight needs more
