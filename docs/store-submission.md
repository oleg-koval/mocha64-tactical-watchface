# Connect IQ Store submission

Everything needed to publish MOCHA-64 Tactical. Copy-paste ready.

**Package:** `bin/mocha64-face.iq` (48.2 kB, signed, 5 device variants)
**Portal:** <https://apps.garmin.com/developer/dashboard>
**App id:** `ccce140e5300403e94121037d9ff3c05`

---

## Steps

1. Sign in at the developer dashboard (free Garmin account; accept the developer
   agreement on first use).
2. **Upload an App** → select `bin/mocha64-face.iq`.
3. Wait for binary validation. Fill in the listing fields below.
4. Attach at least one screenshot per supported device.
5. Submit for review.

**While review is pending you can download the app to your own watch for
testing.** That is the point of doing this — it bypasses the broken USB cable
entirely, over Bluetooth via Garmin Connect.

Rebuild the package any time with `make package`.

---

## Listing copy

### Name

```
MOCHA-64 Tactical
```

### Short description

```
A military instrument panel for your body. Recovery and training load at a glance.
```

### Full description

```
MOCHA-64 Tactical is a dense, high-legibility watch face built around one idea:
your body is the instrument worth reading.

Military framing — brackets, hard rules, mono numerals — pointed at recovery and
training load instead of terrain and weather.

MAIN SCREEN
- 24-hour time in a split hour/minute block
- Body Battery with a fill bar, colour-banded by level
- Current heart rate
- Resting heart rate
- Stress, colour-banded
- Steps against your daily goal, with progress bar
- 4-hour heart-rate sparkline
- Calories
- Date and watch battery

DESIGN
The palette is derived from Catppuccin Mocha, but not copied from it. This
display renders 64 colours, which means every channel snaps to one of four
levels — import a palette built for a 24-bit screen and it does not merely dim,
it shifts hue. Catppuccin's near-white text lands on cyan; its alert red lands
on pale pink and stops reading as a warning at all.

So MOCHA-64 keeps the structure — the base-to-accent ramp, the semantic roles,
the cool dark ground — and re-derives every value to sit exactly on the colours
the panel can actually render. Status colours are saturated so they read at
glyph size; large filled areas keep the softer tints so they do not shout.

Battery thresholds are set for a two-week watch, not a phone: 50% is a week of
headroom, so it reads as healthy, not as a warning.

Any metric your device does not report shows as "--" rather than a zero or a
blank, so you always know the difference between "resting" and "no data".

No settings to configure. No live seconds, deliberately — minute resolution is
both more instrument-like and kinder to battery.

Open source: https://github.com/oleg-koval/mocha64-tactical-watchface
```

### Category

Watch Face

### Devices

fenix 6 Pro (covers fenix 6 Pro / 6 Sapphire / 6 Pro Solar variants — 5 part
numbers built from the one `fenix6pro` profile)

### Permissions to declare

- `SensorHistory` — Body Battery, stress and heart-rate history for the recovery
  column and the sparkline
- `UserProfile` — resting heart rate, which is not exposed via ActivityMonitor
  on every device

### Tags

```
watchface, tactical, military, recovery, body battery, hud, data, catppuccin, mono
```

---

## Images

Assets live in `docs/store/`.

### Hero image — 1440x720 (required)

`docs/store/hero-1440x720.png` — ready to upload. Built entirely from the
MOCHA-64 lattice colours, with the same bracket-and-rule language as the face,
so the listing and the product look like one thing.

Regenerate after a layout change:

```bash
python3 docs/store/make-hero.py     # expects face-tight.png alongside it
```

### Screenshot — 260x260 (device resolution)

`docs/store/mocha64-screenshot-260.png` is a **downscaled crop of the
simulator's rendered watch image**, so it is soft. Good enough as a reference;
replace it with a real one before submitting:

1. `make build`, then run in the simulator.
2. Simulator: **File → Save Screenshot** — writes exact device resolution, no
   cropping, no resampling.

Two or three showing different states (fresh Body Battery vs depleted, goal met
vs in progress) makes a better listing than one.

---

## Before you submit

- [ ] Hero image 1440x720 attached (docs/store/hero-1440x720.png)
- [ ] Screenshot attached — regenerate a crisp one from the simulator first
- [ ] Description proof-read
- [ ] Developer key backed up — **losing it means you can never publish an update
      to this app under the same identity, and there is no recovery path**
      (`~/.Garmin/ConnectIQ/developer_key.der`)
- [ ] Review Garmin's [App Review Guidelines](https://developer.garmin.com/connect-iq/app-review-guidelines/)

## After approval

Update the store badge in `README.md` — it currently reads
"not yet published" and links to the store root.
