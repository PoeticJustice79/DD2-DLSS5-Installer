# DD2 DLSS 5 Installer

One-click installer for DLSS 5 Neural Rendering in **Dragon's Dogma 2 `3.2.0.0`**, using the
OptiScaler DLSS-NR route. Korean and English UI.

This repository contains the installer only. It fetches the components from their original
projects at run time and never redistributes them.

```
Auto-detect  ->  0. Get files  ->  1. Check  ->  2. Install
```

---

## Requirements

| | |
|---|---|
| Game | Dragon's Dogma 2 `3.2.0.0` |
| GPU | RTX card. The bundled model `310.8.SF` is documented as covering RTX 20/30/40/50; the upstream guide targets 40/50; this was verified on an RTX 5090 |
| Driver | NVIDIA `616.56` or newer |

The **Check** step verifies the game version, GPU and driver, and refuses to install if the
driver is too old.

---

## Install

1. Close the game.
2. Run `Install.cmd`.
3. Press **[Auto-detect]**, then **[0. Get files]**, **[1. Check]**, **[2. Install]**.

`[0. Get files]` downloads everything except the DLSS-NR model:

| File | Source |
|---|---|
| `dxgi.dll` | OptiScaler DLSS-NR release (`OptiScaler.dll`, renamed) |
| `nvngx.dll_dlssnr.dll`, `OptiScaler/` | same release |
| `dinput8.dll`, `OptiScaler.ini` | `GameFiles/` of dmitrysobolev/DD2-DLSS5 |

**You supply `nvngx_dlssnr.dll` yourself** and place it in `payload\`. It is an NVIDIA file and
is not redistributed here. The **DLSS-NR model** is available from the RenoDX Discord; `310.8.SF`
is the build that covers RTX 20 through 50.

---

## In game

1. Graphics settings → upscaler = **NVIDIA DLSS**
2. Press **Insert** to open the OptiScaler overlay (`Alt+Insert` if that does nothing).
   This is not ReShade, so `Home` will not work.
3. Expand **DLSS Neural Rendering** → tick **Enable Neural Rendering**
4. A green **Running - N ms per frame** means it is working.
5. Press **Save Settings** (bottom right) so it survives a restart.

Turn **ray-traced GI on**. Neural Rendering cleans up the noise ray tracing produces, and
`3.2.0.0` is the update that added RT GI. With it off the effect is hard to see.

### If the frame rate suffers

`DLSS Neural Rendering → Cost → Model resolution` (default 100%) scales the cost directly.
At 4K on an RTX 5090 it costs roughly 8 ms per frame at 100%. Walk it down to 80% or 60% to
find your balance.

---

## What lands in the game folder

```
dxgi.dll               OptiScaler
dinput8.dll            REFramework, cut down for DD2 3.2.0
nvngx_dlssnr.dll       DLSS-NR model
nvngx.dll_dlssnr.dll
OptiScaler.ini
OptiScaler/
```

No original game file is modified.

`dinput8.dll` keeps REFramework's DD2 integrity bypass and drops its renderer and UI hooks, so
**REFramework mods do not work alongside it** — and neither do ReShade or RenoDX. If any of
those are present, the installer moves them into the backup folder first.

Backups go to `Desktop\DD2-DLSS5-backup_<timestamp>`, deliberately **outside** the game folder:
a copy left inside it gets picked up as a second instance of the same DLL.

---

## Uninstall

Open the installer and press **[Restore]**. It removes what it installed and puts the backup
back. By hand, delete the six entries listed above from the game folder.

---

## Notes

- Experimental. Not an official NVIDIA release.
- Tied to game build `3.2.0.0`. The `3.2.0.0` update broke the previous ReShade + RenoDX route
  outright — the game crashes at boot with ReShade present, at any injection point, on both the
  stable and nightly builds. A future update may break this route in the same way.
- Single-player only. Do not use it with anti-cheat.
- The visible difference shows up most in cutscenes and character close-ups.

---

## Credits

| | |
|---|---|
| Install method | [dmitrysobolev/DD2-DLSS5](https://github.com/dmitrysobolev/DD2-DLSS5) |
| OptiScaler DLSS-NR | [Dagherbou/OptiScaler_DLSSNR](https://github.com/Dagherbou/OptiScaler_DLSSNR) |
| REFramework | [praydog/REFramework](https://github.com/praydog/REFramework) (MIT) |

This installer only automates their instructions.

한국어 안내는 [`GUIDE.ko.txt`](GUIDE.ko.txt) 를 보세요.
