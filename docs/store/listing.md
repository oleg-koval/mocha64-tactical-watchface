# Connect IQ store listing — MOCHA-64 Tactical

Upload is a single file: `bin/mocha64-face.iq` from `make package`. Nothing else
is attached; screenshots and the hero are pasted into the listing form.

**Portal:** <https://apps.garmin.com/developer/dashboard>

Two things the description validator rejects, and both only surface after the
whole form is filled: angle brackets (`Illegal characters found`) and emoji — in
which it counts U+2699 GEAR, exactly the character you reach for when writing
"tap the gear icon". Run `ciq-release` before opening the portal.

## Name

```
MOCHA-64 Tactical
```

## Short description

```
An instrument panel for the body. Four readings you choose, in military type.
```

## Description

```
Military legibility, pointed at recovery instead of terrain.

Brackets, mono type and hard rules — the visual language of an instrument
panel — reading out how recovered you are rather than where you are. Not a
field instrument for the outdoors. An instrument panel for the body.

The time sits large on the left, stacked over two lines, because it is the
one thing you read without deciding to. A column of readings sits to its
right, behind a divider. Steps and calories run along the bottom under a
rule, with the step goal as an inline bar.

FOUR READINGS, YOURS TO CHOOSE
The column takes any of sixteen values in each of its four rows: heart rate,
steps, stairs climbed, Body Battery, stress, resting heart rate, battery
percent, battery days, calories, distance, active minutes, notifications,
altitude, sleep score, the date, or nothing at all.

Out of the box the column is Body Battery, heart rate, resting heart rate and
stress — recovery at a glance, which is what the face was built for.

Colour is used where it earns its place and nowhere else. Body Battery and
stress are states worth reading instantly, so they are coloured against their
own range. Resting heart rate is a reference line, not a state, so it stays
plain white. A field that is permanently coloured teaches the eye to ignore
colour by the time it means something.

Sleep score needs a watch with Garmin's newer software. It simply will not
appear in the list on a watch that cannot supply it.

SETTINGS, ON THE WATCH
Hold the menu button on the watch face. All four rows are there, and the
panel changes as you choose.

You can also use your phone if you prefer: Garmin Connect app, then your
device, Connect IQ Apps, Watch Faces, MOCHA-64 Tactical, settings. Both
routes write the same setting.

TWENTY-FOUR HOUR, ALWAYS
The time ignores your watch's 12/24 hour setting, deliberately. An instrument
panel that renders 2:05 PM is a different design, and this one is not it.

BUILT FOR A REFLECTIVE DISPLAY
Your watch has no backlight, so a colour's brightness is simply the light it
gives back. The time is the brightest thing on the panel for that reason, and
the labels are deliberately dimmer. The glance order is built out of
contrast, not size. Every colour lands exactly on the display's own palette,
so nothing is approximated.

Free, with no ads and no tracking.
```

## What's new

```
First release.
```

## What to attach

| Asset | File | Notes |
| --- | --- | --- |
| Screenshot 1 | `docs/store/mocha64-screenshot-260.png` | the default column |
| Hero / banner | `docs/store/hero-1440x720.png` | 1440×720, the size the store requires |

Regenerate both from the build being uploaded, and **look at them** — every
layout bug this project has had was found by looking, not by testing:

```bash
python3 docs/store/make-icon.py     # launcher icon, 40x40
python3 docs/store/make-hero.py     # hero
```

Screenshots come from a real build pushed to the simulator. Note that the
simulator persists app settings and ignores `properties.xml`, so a shot taken
after any on-watch fiddling shows whatever row you last poked rather than what
a new install renders — force the defaults in source before capturing, and
check the result actually changed.

## IP notes

The store's IP clause covers listing text and images, not just code, and Garmin
will not adjudicate — they accept a listing and can suspend the *account* with
no notice if a rights holder complains.

- The name is invented and the aesthetic is a genre, not a product. **No
  military, brand or model name appears anywhere.**
- No device family names in the copy — those are Garmin marks. Compatibility is
  already expressed by the products the manifest declares.
- The launcher icon is drawn by `make-icon.py` from the face's own palette and
  bracket motif. It deliberately replaces the `connectiq-starter` template icon
  this project shipped with, which was byte-identical to every other scaffolded
  project's.

## Pre-upload checklist

- [x] `make test` passes, and the harness provably compiles tests (48 tests)
- [x] `make lint` clean at level 3
- [x] `make package` builds every declared device
- [x] Developer key not committed (`.gitignore` covers `*.der` / `*.pem`)
- [x] Launcher icon is this project's own, not the scaffold template
- [x] Listing states settings work on the watch as well as the phone
- [x] No third-party marks in name, icon, screenshots or copy
- [ ] Screenshots regenerated from the build being uploaded, and looked at
- [ ] **Verified on real hardware in daylight, not just the simulator**
- [ ] After submitting, re-read the PUBLIC page — the portal's step 2 can save
      nothing and report nothing, leaving the previous description live
