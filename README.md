# MOCHA-64 Tactical

> A military instrument panel for your body. Tactical HUD watch face for the Garmin Fenix 6 Pro.

[![CI](https://github.com/oleg-koval/mocha64-tactical-watchface/actions/workflows/ci.yml/badge.svg)](https://github.com/oleg-koval/mocha64-tactical-watchface/actions/workflows/ci.yml)
[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-3.1%2B-007cc3)](https://developer.garmin.com/connect-iq/)
[![Device](https://img.shields.io/badge/device-fenix%206%20Pro-333)](https://www.garmin.com/en-US/p/641479)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

Military legibility — brackets, mono type, hard rules — pointed at recovery and training
load instead of terrain and weather. Not a field instrument for the outdoors; an
instrument panel for the body.

```
╭─ SAT 25 JUL ─────── ▮78% ─╮   date · watch battery
│  ▛▀▖ ▟   │  BB   74 ▊▊▊   │
│  ▙▄▘ ▐▌  │  HR   62       │   time block (left)
│  ▄▄  ▟▄  │  RHR  48       │   recovery column (right)
│  ▄▄▘ ▐▌  │  STR  22       │
│  ──────────────────────   │
│  STEP ▊▊▊▊▊▊░░░ 8241      │   activity, full width
╰─ ▁▂▃▅▇▅▃▂ HR 4h ─ 2140k ──╯   sparkline · calories
```

Time is always 24-hour and ignores the system 12/24h setting — deliberately. A military
instrument that renders `2:05 PM` is a different design.

> **Status: in development.** The layout above is the design target. The palette and pure
> logic modules are implemented and unit-tested; the full HUD layout is not yet built, and
> nothing has been compiled against the SDK yet. Not published to the Connect IQ Store.
> See [the spec](./docs/superpowers/specs/2026-07-25-fenix6-hud-watchface-design.md).

## Install

Three paths, depending on whether you want to wait for the store.

### 1. Connect IQ Store

*Not yet published.* Once it is, this badge becomes the install link:

[![Connect IQ Store](https://img.shields.io/badge/Connect%20IQ-not%20yet%20published-lightgrey?logo=garmin&logoColor=white)](https://apps.garmin.com/)

When live:

1. Open the store page on the phone running Garmin Connect.
2. Tap **Download** — it queues against your Garmin account.
3. Open **Garmin Connect Mobile** and let the watch sync.
4. On the watch: **Settings → Watch Face → MOCHA-64 Tactical**.

### 2. Cloud install without the store

For a build that isn't publicly listed — no cable needed, still syncs via your account:

```bash
make package          # → bin/mocha64-face.iq
```

- **Unlisted store entry:** upload the `.iq` in the Garmin developer portal and keep the
  listing unlisted. Testers install from the direct URL exactly as above.
- **Garmin Express (desktop):** connect the watch, open Express → your device →
  **Connect IQ Apps**; it syncs whatever your account has queued.

### 3. Local sideload — no account, no store, no review

Fastest path, works entirely offline.

```bash
make build            # → bin/mocha64-face.prg
make deploy           # copies it to a mounted watch
```

By hand:

1. Connect the Fenix by USB — it mounts as mass storage (`/Volumes/GARMIN` on macOS).
2. Copy `bin/mocha64-face.prg` into `GARMIN/APPS/`.
3. **Eject the volume properly**, then unplug.
4. On the watch: **Settings → Watch Face** and select it.

No developer account is needed for personal sideloading. `make deploy` fails loudly if
the watch isn't mounted rather than silently doing nothing.

## The MOCHA-64 palette

The design brief was "Catppuccin-ish". That doesn't survive contact with the hardware, and
the reason is arithmetic rather than taste.

The Fenix 6 Pro renders **64 colours**. 64 = 4³ — four levels per channel — so every
channel snaps to `00`, `55`, `AA` or `FF`. You can therefore compute exactly what
Catppuccin Mocha *becomes*:

| Mocha token | Hex | Quantised | Outcome |
|---|---|---|---|
| `text` | `#CDD6F4` | `#AAFFFF` | warm off-white → **cyan** |
| `base` | `#1E1E2E` | `#000055` | survives |
| `surface0` | `#313244` | `#555555` | blue tint lost, flat grey |
| `red` | `#F38BA8` | `#FFAAAA` | **pale pink** — cannot signal an alert |
| `green` | `#A6E3A1` | `#AAFFAA` | pale mint, survives usefully |

It doesn't merely dim — it **shifts hue**. Body text goes cyan and the alert colour goes
pastel pink, which inverts the theme's entire job.

So MOCHA-64 keeps Catppuccin's *grammar* — the base → surface → accent ramp, the semantic
roles, the cool dark ground — and re-derives the values to sit **exactly on the lattice**,
where quantisation is a no-op:

```
BG      #000000   crust      page black
PANEL   #000055   base       bracket interiors, keeps the cool cast
RULE    #555555   surface1   divider rules, empty bar track
LABEL   #AAAAAA   subtext0   field labels
VALUE   #FFFFFF   text       primary numerals
```

One deliberate break from Catppuccin: status glyphs get *saturated* lattice points
(`READY #55FF55`, `CAUTION #FFAA00`, `STRAIN #FF5555`, `DATA #55AAFF`) because pastels
can't convey urgency at glyph size. The pale Catppuccin-derived tints are kept for large
bar fills (`FILL_OK #AAFFAA`, `FILL_HI #FFAAAA`) where saturation would shout.

`tests/PaletteTest.mc` asserts every palette colour is lattice-exact, so a future edit
that reintroduces a colour the panel can't render fails the build.

> The 4×4×4 lattice is inferred from `64 = 4³` and is **pending verification** against the
> SDK device profile. If the Fenix uses an arbitrary 64-entry lookup table instead, the fix
> is to read the real table and snap to nearest — the method is unchanged.

## Development

Connect IQ is a Java toolchain, so a JDK comes first:

```bash
brew install --cask temurin
java -version                 # must print a version, not an error
```

Then install the [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/),
download an SDK plus the **fenix 6 Pro** device profile, and put the SDK's `bin/` on `PATH`.

```bash
make key                      # generate signing key → ~/.Garmin/ConnectIQ/
make doctor                   # verify java, monkeyc, monkeydo, key
make hooks                    # install pre-commit hooks (once)
make lint                     # strict type check (-l 3)
make test                     # unit tests in the simulator
make sim                      # run the face in the simulator
make build                    # → bin/mocha64-face.prg
make deploy                   # sideload to a mounted watch
```

## Layout

```
source/
  MochaFaceApp.mc     AppBase — lifecycle only
  MochaFaceView.mc    WatchFace — drawing only, computes nothing
  Fields.mc           pure: value → formatted string, value → colour band
  Layout.mc           flat coordinate constants
  Palette.mc          MOCHA-64 constants + 64-colour quantisation
tests/                (:test) functions, excluded from release builds
docs/
  superpowers/specs/  the design spec
  article-journal.md  build journal for the write-up
```

Pure modules hold the logic; views hold the drawing. `Fields.mc` and `Palette.mc` make no
`Dc` calls, which is what makes them unit-testable.

**Memory is the binding constraint** — tighter than CPU or battery. That is why layout
lives in a flat constants table rather than a field-object abstraction: on a memory-capped
watch face, a table of objects and closures spends the scarcest resource to buy
flexibility already available from editing constants. Profile before adding indirection.

## Roadmap

- **Phase 0** — toolchain, first flash to hardware (scaffolded; JDK + SDK still to install)
- **Phase 1** — this watch face (in progress)
- **Phase 2** — adaptive progressive-overload strength training app; own spec. Training
  history likely lives off-watch to sidestep the memory ceiling.

## Built from

[`connectiq-starter`](https://github.com/oleg-koval/connectiq-starter) — Garmin Connect IQ
template with strict type checking, unit tests, and pre-commit gates.

## License

MIT - see [LICENSE](./LICENSE).
