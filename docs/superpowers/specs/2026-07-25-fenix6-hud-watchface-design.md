# Fenix 6 Pro — Tactical HUD Watch Face

**Date:** 2026-07-25
**Status:** Approved
**Scope:** Phase 0 (toolchain) + Phase 1 (watch face)
**Device:** Garmin Fenix 6 Pro — 260×260 transflective MIP, 64 colours, always-on

---

## 1. Concept

A military instrument panel for the body.

Tactical HUD chrome — brackets, mono type, hard rules, corner ticks — reporting
recovery and output rather than terrain and weather. Military in *function and form*;
gym and health in *subject matter*.

Phase 2 (adaptive strength training app) reuses this visual language, so the two ship
as one coherent product rather than two unrelated builds.

### Non-goals

Phase 1 does not include: live seconds, custom bitmap fonts, a settings menu, multiple
colour themes, Hermes connectivity, or any training-app functionality.

---

## 2. Phase 0 — Toolchain

Four sequential steps, each independently verifiable.

| # | Step | Done when |
|---|------|-----------|
| 0.1 | Link the brew-installed `openjdk` into `/Library/Java/JavaVirtualMachines` | `java -version` reports a version instead of erroring |
| 0.2 | Install Connect IQ SDK Manager; pull an SDK + the **fenix 6 Pro device profile** | `monkeyc` on PATH; device profile present |
| 0.3 | Compile a stub watch face and run it in the simulator | Stub renders in the simulator |
| 0.4 | Sideload to the physical watch | Face is selectable and displaying on the Fenix |

**Phase 0's exit gate is the physical watch, not the simulator.**

Sideloading is USB mass-storage: copy the `.prg` into `GARMIN/APPS`, eject, select the
face on-device. No developer account is required for personal use.

### Facts to extract from the device profile in 0.2

These were deliberately not guessed at during design and must be read from the SDK:

- Exact memory ceiling for a watch face on fenix 6 Pro
- Maximum supported Connect IQ API level
- Whether the 64-colour palette is a 4×4×4 lattice or an arbitrary lookup table
- Which `SensorHistory` metrics the device actually exposes (see §8)

---

## 3. Palette — "MOCHA-64"

### The problem

Catppuccin Mocha is built on soft, low-contrast pastels. The Fenix 6 renders 64
colours. 64 = 4³, so the palette is almost certainly **four levels per channel** —
every channel snapping to `00`, `55`, `AA`, or `FF`.

Under that quantisation Catppuccin does not merely dim, it **shifts hue**:

| Catppuccin Mocha | Hex | Quantised | Outcome |
|---|---|---|---|
| `text` | `#cdd6f4` | `#AAFFFF` | warm off-white becomes **cyan** |
| `base` | `#1e1e2e` | `#000055` | blue-black — survives |
| `surface0` | `#313244` | `#555555` | loses blue tint, flattens to grey |
| `red` | `#f38ba8` | `#FFAAAA` | pale pink — too weak to signal alert |
| `green` | `#a6e3a1` | `#AAFFAA` | pale mint — survives, usefully |

Body text turning cyan and alert red turning pastel-pink both break the theme's intent.

### The approach

Choose colours that **already sit on the lattice**, so nothing moves under
quantisation, while preserving Catppuccin's structural *relationships* (cool dark base,
mid-grey surfaces, near-white text, hue-distinct accents).

Port the grammar, not the hex values.

### Structural ramp

```
BG      #000000   ← crust      page black
PANEL   #000055   ← base       bracket interiors; retains the cool cast
RULE    #555555   ← surface1   divider rules, empty bar track
LABEL   #AAAAAA   ← subtext0   field labels
VALUE   #FFFFFF   ← text       primary numerals
```

### Accents, split by job

A deliberate departure from Catppuccin: status semantics need punch that pastels
cannot deliver at glyph size.

```
READY   #55FF55   strong green   status: good / recovered
CAUTION #FFAA00   amber          status: caution
STRAIN  #FF5555   strong red     status: strain / alert
DATA    #55AAFF   blue           neutral metrics (HR)

FILL_OK #AAFFAA   pale mint      large bar fills, where saturation would shout
FILL_HI #FFAAAA   pale pink      large bar fills
```

Rule of thumb: **saturated lattice points for small status glyphs, Catppuccin-derived
pastels for large filled areas.**

### Fallback

If 0.2 reveals the 64 colours are an arbitrary lookup table rather than a lattice, read
the actual table from the SDK and snap each intended colour to its nearest entry. The
method is unchanged; only the target set moves.

---

## 4. Layout

Asymmetric split — time block left, labelled recovery column right, divided by a
vertical rule. Aligned label/value pairs in a column is how real equipment panels read.

```
╭─ SAT 25 JUL ─────── ▮78% ─╮   status bar: date, watch battery, glyphs
│  ▛▀▖ ▟   │  BB   74 ▊▊▊   │
│  ▙▄▘ ▐▌  │  HR   62       │   time block (left)
│  ▄▄  ▟▄  │  RHR  48       │   recovery column (right)
│  ▄▄▘ ▐▌  │  STR  22       │
│  ──────────────────────   │
│  STEP ▊▊▊▊▊▊░░░ 8241      │   activity, full width
╰─ ▁▂▃▅▇▅▃▂ HR 4h ─ 2140k ──╯   sparkline + calories
```

Trade-off accepted: a narrower time block means smaller numerals than a
time-dominant layout would allow.

### Fields

| Slot | Metric | Source | Colour |
|---|---|---|---|
| Status bar | Date, watch battery | `System.getSystemStats`, `Time` | `LABEL` / `VALUE` |
| Time | `HH:MM`, forced 24h (see below) | `System.getClockTime` | `VALUE` |
| Recovery 1 | Body Battery + bar | `SensorHistory.getBodyBatteryHistory` | `READY`/`CAUTION`/`STRAIN` by band |
| Recovery 2 | Current HR | `ActivityMonitor` / `Sensor` | `DATA` |
| Recovery 3 | Resting HR | `ActivityMonitor.getInfo` | `LABEL` — deliberately de-emphasised; it is a baseline, not a live reading |
| Recovery 4 | Stress | `SensorHistory.getStressHistory` | banded |
| Activity | Steps + goal bar | `ActivityMonitor.getInfo` | `FILL_OK` on `RULE` track |
| Footer L | 4-hour HR sparkline | `SensorHistory.getHeartRateHistory` | `DATA` |
| Footer R | Calories | `ActivityMonitor.getInfo` | `LABEL` — de-emphasised, same rationale |

**Time format:** always 24-hour, zero-padded, **ignoring the system 12/24h setting.**
This is an aesthetic decision, not an oversight — 24-hour time is intrinsic to the
military-instrument concept, and a face that renders `2:05 PM` is a different design.
Revisit only if it proves annoying in daily use.

Round-screen constraint: both ends of every full-width row are clipped by the bezel
curve. Horizontal extents must be computed against the circular boundary, not the
260×260 square.

---

## 5. Rendering approach

**Pure programmatic `Graphics.Dc` drawing.** All layout coordinates in a flat
constants table.

Rejected alternatives:

- **Layout XML + drawables** — Garmin's declarative path. Idiomatic, but rigid about
  conditional rendering, and every bracket, rule and grid line needs custom drawing
  regardless. Net loss.
- **A "field" abstraction** (`{label, getter, formatter, slot}` objects walked by a
  generic renderer) — better for iteration and Phase 2 reuse, but on a memory-capped
  watch face a table of objects and closures spends precisely the scarcest resource to
  buy flexibility already available from editing a constants table. **Revisit only if
  the simulator's memory profiler shows headroom.**

### Supporting decisions

- **No live seconds.** In low-power mode a watch face receives one `onUpdate` per
  minute; seconds require `onPartialUpdate` with a clip region and a hard power budget.
  Not worth the battery or complexity — and minute resolution is more instrument-like.
- **Built-in fonts first.** Custom stencil/mono type means generating bitmap font
  resources from a TTF: real work, real memory cost. Ship on Garmin's built-in numeric
  fonts; evaluate a custom face as a separate later slice.
- **Logic in pure functions.** Drawing is untestable; formatting, banding and maths are
  not. Structure for that from the start.

---

## 6. Code structure

```
source/
  MochaFaceApp.mc      AppBase, lifecycle
  MochaFaceView.mc     WatchFace; onUpdate is a layout script only
  Layout.mc            flat coordinate + slot constants
  Palette.mc           MOCHA-64 constants + quantisation helper
  Fields.mc            pure: sensor value → formatted string, value → colour band
  Hud.mc               drawing primitives: bracket, rule, bar, sparkline
resources/
  drawables/, strings/    (no custom fonts in Phase 1 — see §5)
tests/
```

`Palette.mc` and `Fields.mc` contain no drawing code — that is what makes them
testable. `MochaFaceView.onUpdate` composes primitives and does no computation.

---

## 7. Verification

1. **Unit tests** — `(:test)` annotations run via `monkeydo -t`, covering every pure
   function: time/date formatting, goal-percentage maths, sparkline bucketing, colour
   banding thresholds, palette quantisation.
2. **Simulator** — layout correctness, plus the **memory profiler**. That figure decides
   whether the field abstraction returns and whether Phase 2 needs Hermes to hold
   history off-watch.
3. **Physical watch, in daylight** — a MIP panel in direct sun is a materially different
   display from the simulator. Contrast and palette decisions can only be judged there.

A slice is not complete until its tests pass and it has been seen on the watch.

---

## 8. Risks

| Risk | Impact | Handling |
|---|---|---|
| Body Battery / stress not exposed to Connect IQ | Undermines Phase 2's readiness model | Phase 1 *is* the experiment. Prove it in week one, before Phase 2 depends on it. |
| Memory ceiling tighter than the design assumes | Features get cut | Sparkline is first to go — most expensive element per pixel. |
| 64 colours is not a clean 4×4×4 lattice | Palette values shift | Read the real table from the SDK, snap to nearest. §3 fallback. |
| Built-in fonts too rounded for the aesthetic | Aesthetic compromise | Ship anyway; custom font becomes its own slice. |
| Round-screen clipping breaks full-width rows | Layout bugs | Compute extents against the circular boundary; verify on-device. |

### Open question deferred to Phase 2

Garmin's own Training Status, Training Load, VO2 Max and Recovery Time are believed
**not** exposed to third-party apps. If confirmed, Phase 2 must *derive* readiness from
Body Battery, resting-HR drift, sleep and stress history rather than reading Garmin's
own figure. Phase 1's field plumbing establishes what is actually readable.

---

## 9. Context: why this is Phase 0+1 only

The original request covered three phases. They are independent subsystems, and one
spec covering all three would have been a poor spec for each:

- **Phase 0** — toolchain. No design decisions. *This spec.*
- **Phase 1** — watch face. Self-contained, ships alone. *This spec.*
- **Phase 2** — adaptive strength training app. Own spec; will decompose further.
  Deliberately deferred so it can be designed with real knowledge of the device's
  memory and sensor limits.
- **Phase 3** — the blog article. Captured continuously in
  `docs/article-journal.md` from day zero.

"Learn the platform" was folded into 0+1 rather than treated as a standalone phase.
Monkey C is learned by building the watch face.
