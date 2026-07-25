# connectiq-starter

> Opinionated Garmin Connect IQ starter — Monkey C, strict type checking, unit tests, pre-commit hooks, Make targets.

[![CI](https://github.com/oleg-koval/connectiq-starter/actions/workflows/ci.yml/badge.svg)](https://github.com/oleg-koval/connectiq-starter/actions/workflows/ci.yml)
[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-3.1%2B-007cc3)](https://developer.garmin.com/connect-iq/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A working watch face you can build, test, simulate and sideload in one sitting — plus the
gates that stop a Monkey C project rotting: strict type checking, unit-testable pure
modules, a 300-line file cap, and a hook that refuses to let you commit your signing key.

## Install (for users of an app built from this template)

Three paths. Pick by whether the app is published.

### 1. Connect IQ Store — the normal route

[![Get it on Connect IQ](https://img.shields.io/badge/Connect%20IQ-Store-007cc3?logo=garmin&logoColor=white)](https://apps.garmin.com/)

1. Open the store link above on the device you use for Garmin Connect.
2. Tap **Download** — it queues against your Garmin account.
3. Open **Garmin Connect Mobile** and let it sync, or connect to Wi-Fi/USB.
4. On the watch: **Settings → Watch Face** (or **Activities & Apps**) and select it.

> Replace the badge URL above with your app's store page once published. See
> [Publishing](#publishing-to-the-connect-iq-store) for how to get one.

### 2. Cloud install without the store — Garmin Express or a shared `.iq`

For a build that is not (or not yet) publicly listed:

```bash
make package          # produces bin/starter-face.iq
```

- **Private store distribution:** upload the `.iq` in the Garmin developer portal and
  keep the listing unlisted. Testers install it from the direct URL exactly as above —
  it still syncs through their Garmin account, so no cable is needed.
- **Garmin Express (desktop):** connect the watch, open Express → your device →
  **Connect IQ Apps**, and it syncs whatever your account has queued.

### 3. Local sideload — no account, no store, no review

The fastest path, and the only one that works offline.

```bash
make build            # produces bin/starter-face.prg
make deploy           # copies it onto a mounted watch
```

Or by hand:

1. Connect the watch by USB. It mounts as mass storage (`/Volumes/GARMIN` on macOS).
2. Copy the `.prg` into `GARMIN/APPS/` on the device.
3. **Eject the volume properly**, then unplug.
4. On the watch: **Settings → Watch Face** and pick it.

No developer account is required for personal sideloading. `make deploy` fails loudly if
the watch is not mounted rather than silently doing nothing.

## Development

Connect IQ is a Java toolchain, so a JDK comes first:

```bash
brew install --cask temurin
java -version                 # must print a version, not an error
```

Then install the [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/),
download an SDK plus your target device profile, and put the SDK's `bin/` on `PATH`.

Generate your signing key once:

```bash
make key                      # → ~/.Garmin/ConnectIQ/developer_key.der
```

Check everything resolved:

```bash
make doctor
# java     openjdk version "17.0.11"
# monkeyc  /Users/you/connectiq-sdk/bin/monkeyc
# monkeydo /Users/you/connectiq-sdk/bin/monkeydo
# key      /Users/you/.Garmin/ConnectIQ/developer_key.der
```

Then:

```bash
make hooks    # install pre-commit hooks (once)
make lint     # monkeyc strict type check (-l 3)
make test     # unit tests in the simulator
make sim      # launch the simulator and run the face
make build    # → bin/starter-face.prg
make deploy   # sideload to a mounted watch
make package  # → bin/starter-face.iq for the store
```

Target a different device with `DEVICE=`:

```bash
make build DEVICE=fenix7
```

## Layout

```
manifest.xml          app id, type, target products, permissions
monkey.jungle         build config; wires tests/ in and excludes them from release
source/
  *App.mc             AppBase — lifecycle only
  *View.mc            WatchFace — drawing only, computes nothing
  Fields.mc           pure: value → formatted string, value → colour band
  Layout.mc           flat coordinate constants
  Palette.mc          colour constants + 64-colour quantisation helper
resources/
  drawables/          launcher icon
  strings/            localised strings
tests/                (:test) functions, excluded from release builds
```

The split is the point: **pure modules hold the logic, views hold the drawing.**
`Fields.mc` and `Palette.mc` make no `Dc` calls, so they are unit-testable. Views are
layout scripts.

## The 64-colour problem

Most Garmin wearables use a transflective MIP panel rendering **64 colours** — and
64 = 4³, meaning every channel snaps to `00`, `55`, `AA` or `FF`. Import a palette
designed for a 24-bit screen and it does not merely dim, it **shifts hue**:

```
Catppuccin text  #CDD6F4  →  #AAFFFF   warm off-white becomes cyan
Catppuccin red   #F38BA8  →  #FFAAAA   alert red becomes pastel pink
```

`Palette.mc` ships the quantisation helper and `isLatticeExact()` so you can assert your
palette survives the panel — see `tests/PaletteTest.mc` for the pattern. Pick colours
already on the lattice and nothing shifts.

> Verify the lattice assumption against your target's device profile. If a device uses
> an arbitrary 64-entry lookup table instead, read the real table and snap to nearest —
> the method is unchanged.

## Publishing to the Connect IQ Store

Not automatable — Garmin requires a manual submission and reviews it.

1. Register as a developer at <https://developer.garmin.com/connect-iq/>.
2. `make package` → `bin/*.iq`, signed with your developer key.
3. Upload at <https://apps.garmin.com/developer/dashboard>, with: app name,
   description, category, at least one screenshot per supported device, and an icon.
4. Submit for review. Turnaround is typically days, not hours.
5. Once live, put the store URL in this README's badge.

**Back up your developer key.** Losing it means you can no longer publish updates to
your own app under the same identity, and there is no recovery path.

## CI

| Check | Runs |
|-------|------|
| 300-line file cap (RULES.md §2.2) | always |
| Manifest + resource XML well-formed | always |
| Application id present and valid | always |
| No signing key committed | always |
| `make lint` + `make test` | only when `CONNECTIQ_SDK_URL` repo variable is set |

The compile job is opt-in because the Connect IQ SDK is licence-gated with no stable
public download URL. It is skipped rather than faked.

## Conventions

Governed by [oleg-koval/starters RULES.md](https://github.com/oleg-koval/starters/blob/main/RULES.md).
Documented exemption: RULES.md §2.4's format gate cannot be met — no formatter exists
for Monkey C. See [AGENTS.md](./AGENTS.md#rule-exemptions) for the compensating controls.

## Contributing

PRs welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) and [AGENTS.md](./AGENTS.md).

## Other starters

Part of a set with shared conventions (AGENTS.md, Conventional Commits, MIT, GitHub Actions CI, Dependabot):

- [`ts-npm-starter`](https://github.com/oleg-koval/ts-npm-starter) - TypeScript / Node
- [`py-starter`](https://github.com/oleg-koval/py-starter) - Python (uv + ruff + ty)
- [`go-starter`](https://github.com/oleg-koval/go-starter) - Go (standard layout + golangci-lint)
- [`connectiq-starter`](https://github.com/oleg-koval/connectiq-starter) - Garmin Connect IQ / Monkey C - this repo

## License

MIT - see [LICENSE](./LICENSE).
