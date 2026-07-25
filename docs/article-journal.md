# Build Journal — "How I pointed Claude Code at my Garmin"

Running capture for the olegkoval.com/blog article. Append as we go; don't reconstruct later.
Raw material, not prose. Keep the ugly bits — they're the interesting bits.

---

## 2026-07-25 — Day 0: the cold start

### The premise
Fenix 6 Pro on my wrist. Three goals, stated in this order:
1. Learn to build Connect IQ apps and watch faces at all.
2. An army-styled watch face, Catppuccin-ish palette, good data density.
3. An adaptive progressive-overload strength training app that needs zero manual
   editing — it reads my current condition and training history and adjusts.

### Machine state before touching anything
Worth recording because "AI writes the app" articles always skip the boring gate:

- No Connect IQ SDK installed.
- No `monkeyc`, no `monkeydo`, no `connectiq` on PATH.
- `java -version` → *"Unable to locate a Java Runtime."* `openjdk` was brew-installed
  but never linked. The entire Garmin toolchain is Java-based, so this was the actual
  blocker before a single line of Monkey C could compile.
- Zero Garmin projects in `~/projects` — greenfield.
- olegkoval.com lives in `portfolio-website/`; its blog is **DB-backed**
  (`app/api/blog`, `app/admin/blog`, `lib/blog`), not markdown files. So "publish the
  article" is not `git add post.md`. Noted for later.

**Article angle #1:** the unglamorous truth is that step one wasn't prompting, it was
an unlinked JDK.

### Decomposition argument
First real decision, and it was a pushback rather than a yes. The three "phases" are
three independent subsystems; one spec covering all of them would have been a bad spec
for each. Split into:

- **Phase 0** — toolchain + first flash to the real watch. No design decisions.
- **Phase 1** — the army watch face. Self-contained, ships alone.
- **Phase 2** — the adaptive training app. Decomposes further on its own.
- **Phase 3** — this article.

Also rejected my own framing of "Phase 1 = learn the platform." Learning isn't a
spec-able project. You learn Monkey C by building the watch face. Folded it in.

**Article angle #2:** the most valuable thing the agent did on day 0 was refuse to
write one spec for three projects.

### Constraints surfaced on day 0 (before any code)
1. **Catppuccin vs. the panel.** Fenix 6 Pro is a 260×260 transflective MIP display —
   always-on, sunlight-readable, and palette-limited (not 24-bit). Catppuccin's entire
   identity is soft, low-contrast pastels. Dithered onto that panel the Surface/Overlay
   tones collapse into mud and the theme stops reading as the theme. Decision: keep
   Catppuccin's *structure* (base → surface → accent ramp) but re-derive the actual hex
   values against what the hardware can render.

   **Article angle #3 — probably the best one:** a beloved design system meets hardware
   that refuses it, and the fix is to port the *grammar*, not the colors.

2. **Memory is the wall on Phase 2.** Connect IQ gives a fixed per-device allocation.
   An app holding training history *and* running an adjustment algorithm will hit it.
   Implies history lives off-watch or gets aggressively summarized. Design constraint,
   not an implementation detail.

3. **"Hermes integrations" — unresolved.** No such thing exists in Garmin/Connect IQ.
   Parked as an open question rather than guessed at. Resolve before the Phase 2 spec.

### Tooling honesty
Most of my existing skill library doesn't apply. Monkey C isn't TypeScript, there's no
AWS, no `npm run`, and "deploy" means copying a `.prg` onto `GARMIN/APPS` over USB.
What survives: brainstorm → spec → plan → build slices → review. The stack-specific
automation is dead weight here.

**Article angle #4:** a well-stocked agent setup meeting a platform none of it was
built for. What transfers is process, not tooling.

---

## 2026-07-25 — Day 0, later: the design falls out

### "Army-like" was four different watches
Asked to pick a direction and got shown four: field analog (MIL-W-46374, real hands),
tactical HUD (bracketed digital readout), reticle/bezel gauges (rifle-scope logic),
stencil brutalist (ammo-crate stamping). Picked **tactical HUD** — hands eat the centre
of the screen, and I asked for data density.

**Article angle #5:** "make me an army watch face" is not a spec. It's four
mutually-exclusive watches wearing the same adjective. The useful move was refusing to
pick for me.

### The reframe that actually mattered
Offered two data bundles: recovery/readiness, or outdoor field instrument (altitude,
barometer, sunrise). I took recovery + activity and said: *military by function, but
more gym/healthcare in nature.*

That landed better than the original framing. The face isn't a field instrument for
terrain — it's **an instrument panel for the body**. Same hard military legibility,
pointed at recovery and load instead of altitude and weather. Which also means Phase 1
and Phase 2 stop being two unrelated builds and become one product.

**Article angle #6 — the good one:** the best design decision of the session came from
me correcting the agent's premise, not from the agent's suggestions. It proposed the
menu; I picked something that wasn't on it.

### MOCHA-64: doing the arithmetic on the colour problem
Day-zero hunch was that Catppuccin would look muddy on this panel. Turned out the claim
is checkable, not vibes.

Fenix 6 renders **64 colours**. 64 = 4³ → four levels per channel → every channel snaps
to `00`, `55`, `AA`, `FF`. So you can compute exactly what Catppuccin *becomes*:

| Mocha token | Hex | Quantised | What happens |
|---|---|---|---|
| `text` | `#cdd6f4` | `#AAFFFF` | warm off-white → **cyan** |
| `base` | `#1e1e2e` | `#000055` | survives |
| `surface0` | `#313244` | `#555555` | blue tint gone, flat grey |
| `red` | `#f38ba8` | `#FFAAAA` | **pale pink** — can't signal an alert |
| `green` | `#a6e3a1` | `#AAFFAA` | pale mint, survives usefully |

It doesn't dim. It **shifts hue**. Body text goes cyan; the alert colour goes pastel
pink. The theme's whole job — calm, hue-distinct, low-contrast harmony — inverts.

Fix: pick colours that *already sit on the lattice*, so nothing moves under
quantisation, but keep Catppuccin's structural relationships (cool dark base, mid-grey
surfaces, near-white text, hue-distinct accents). Named it **MOCHA-64**.

One deliberate break from Catppuccin: status glyphs get *saturated* lattice points
(`#55FF55`, `#FF5555`, `#FFAA00`) because pastels can't signal urgency at glyph size,
while the pale Catppuccin-derived tints (`#AAFFAA`, `#FFAAAA`) are kept for large bar
fills where saturation would shout.

**Article angle #3, now upgraded to the thesis:** you cannot port a design system to
constrained hardware by porting its hex values. You port its *grammar* — the ramp, the
relationships, the semantic roles — and re-derive the values against what the panel can
physically render. The hunch was cheap; the arithmetic is what made it a design.

Caveat recorded honestly: the 4×4×4 lattice is a *hypothesis* from `64 = 4³`, to be
verified against the SDK device profile in Phase 0. If Garmin uses an arbitrary 64-entry
lookup table instead, read the real table and snap to nearest. Method survives either
way. **Not asserting it as fact yet.**

### Rejecting my own abstraction
Wanted a `{label, getter, formatter, slot}` field abstraction — clean, iterable,
reusable in Phase 2. Rejected it, on the grounds that a table of objects and closures
on a memory-capped watch face spends the scarcest resource to buy flexibility already
available from editing a constants table. Revisit only if the simulator's memory
profiler shows headroom.

**Article angle #7:** the agent talked me out of the more elegant architecture using the
platform's actual binding constraint. Worth noting how rare it is for the tooling to
argue *for* less abstraction.

### Also decided
- No live seconds. Low-power mode gives one `onUpdate`/minute; seconds need
  `onPartialUpdate` + clip region + power budget. Minute resolution is more
  instrument-like anyway.
- Built-in fonts first. Custom bitmap stencil font = TTF conversion + memory cost. Own
  slice, later.
- Pure functions for all logic, because Monkey C *does* have a unit-test harness
  (`(:test)` + `monkeydo -t`) and drawing is the only untestable part.

### Hermes, resolved
It's my Telegram bot. Bigger implication than expected: it means the watch can be a
*client* in Phase 2, with training history living off-watch in Hermes. That sidesteps
the memory wall entirely rather than fighting it. Filed as the leading Phase 2
architecture.

Side note for accuracy: grep also turned up `.hermes/plans/` and `adapters/hermes/`
across my own repos, so "Hermes" is doing double duty as an agent harness in my setup.
Untangle before the Phase 2 spec.

### Spec written
`docs/superpowers/specs/2026-07-25-fenix6-hud-watchface-design.md`. Phase 0+1 only.
Not committed — no git repo here yet, and I commit when I say so, not automatically.

---

## 2026-07-25 — Day 0, part 3: two repos, and a bug in my own house style

### What shipped
- `oleg-koval/connectiq-starter` — marked as a GitHub template, so it auto-appears in the
  `starters` index (that repo's `discover.sh` scrapes template-flagged repos).
- `oleg-koval/mocha64-tactical-watchface` — generated from it, specialised into the real face.

Both green on first CI run.

### The find: my existing starters have a broken pre-commit config
While copying the house-style `.pre-commit-config.yaml` from `go-starter`, the YAML
wouldn't parse. Checked the source — and **`go-starter` and `py-starter` both ship
`.pre-commit-config.yaml` files that are invalid YAML.**

Cause: the file-length hook embeds shell inline —

```yaml
entry: bash -c 'echo "ERROR: $f has $lines lines"'
```

That's a *plain* (unquoted) YAML scalar, and `: ` inside one terminates it. The single
quotes are literal characters to YAML, not quoting. So the config has never loaded, which
means **the 300-line hook mandated by RULES.md §2.2 has never actually run in either
repo.** A rule that is documented as "mechanically enforced" was enforcing nothing.

Fix here: shell goes in `scripts/*.sh`, YAML only references file paths. CI calls the same
scripts, so the local gate and the CI gate cannot drift. Verified both directions —
passes on real files, correctly rejects a 350-line file.

**Article angle #8 — strong:** the agent found a latent bug in *my own conventions* by
trying to follow them. Not by reviewing them; by inheriting them. Silent failure in the
enforcement layer is the worst kind, because the green badge says the opposite.

### Things I refused to fake
Two places where the honest answer was "can't":

1. **The marketplace link.** Asked for one. It cannot exist — a store listing needs a
   signed `.iq`, a Garmin developer account, and manual review that takes days. So the
   README ships a `not yet published` placeholder badge plus the real submission
   procedure. Documented instead of invented.
2. **The CI compile job.** The Connect IQ SDK is licence-gated with no stable public
   download URL, so `monkeyc` can't run on a GitHub runner out of the box. The build job
   is gated behind a `CONNECTIQ_SDK_URL` repo variable and **skips** rather than
   pretending. The SDK-free gates (file length, XML wellformedness, app id validity, no
   committed signing key) always run and are genuinely green.

**Article angle #9:** the interesting engineering was deciding what *not* to automate. A
CI job that fakes a compile is worse than no CI job.

### RULES.md §2.4 needed a documented exemption
§2.4 mandates a format gate. **No formatter exists for Monkey C** — no `gofmt`, no
`prettier`, and Garmin ships nothing. §1 says exemptions must be documented in the
starter's own `AGENTS.md`, so that's where it went, with compensating controls
(`.editorconfig`, whitespace hooks, and strict type checking at `-l 3`, which is a
stronger correctness gate than formatting anyway).

Also adapted §2.3 (E2E over unit tests): a watch face has no callable public interface, so
"E2E" means the simulator and the physical watch, neither automatable. Unit tests cover
the pure functions §2.3 permits; the E2E layer is a documented manual check.

### A gate worth having
Added a hook and a CI check that both refuse a committed `.der`/`.pem`/`developer_key`.
A Garmin developer key can't be revoked — leak it and you lose the ability to publish
updates under your own app identity, permanently. Cheap gate, unbounded downside.

### The palette became executable
`Palette.mc` ships `quantize()` and `isLatticeExact()`, and `PaletteTest.mc` asserts every
palette colour is lattice-exact. The day-zero design argument is now a test that fails the
build if someone reintroduces a colour the panel can't render.

The two Catppuccin quantisations are also pinned as tests: `#CDD6F4 → #AAFFFF` and
`#F38BA8 → #FFAAAA`. The claim is now checkable rather than assertable.

**Article angle #10:** the design rationale stopped being prose in a spec and became a
failing test. That's the difference between a documented decision and an enforced one.

---

## Open threads to resolve
- [x] What "army-like" means → tactical HUD, gym/health subject matter
- [x] Which data fields → recovery/readiness + activity/goals
- [x] What "Hermes" is → my TG bot; likely Phase 2's off-watch store
- [ ] Verify the 4×4×4 palette lattice hypothesis against the SDK profile
- [ ] Confirm BODY/STRESS populate on the wrist after the SensorHistory fix
- [x] Fenix 6 Pro memory ceiling → **107.8 kB**; the HUD uses 13.5 kB (~12%)
- [~] `SensorHistory` on hardware: all reads returned nothing. Suspected cause is
      null data in the newest bucket; fix shipped, **unverified until the next photo**
- [ ] Whether Training Status / Load / VO2max are reachable at all (Phase 2 blocker)
- [ ] How to publish to a DB-backed blog
- [ ] Disambiguate Hermes-the-bot from Hermes-the-agent-harness

## 2026-07-25 — Day 0, part 4: it compiles, it ships, the hardware disagrees

### The toolchain fell in about twenty minutes
The blocker I'd framed as "you must install the SDK" turned out to be mostly
automatable:

- `openjdk` was already installed, just keg-only. No sudo, no reinstall — it only
  needed to be on PATH. My "unlinked JDK" framing was right about the symptom and
  wrong about the fix.
- The SDK manifest is **public**: `developer.garmin.com/downloads/connect-iq/sdks/sdks.json`.
  Pulled 9.2.0 (240 MB .dmg) straight down, mounted, installed.
- Generated the developer key with `openssl`.
- Only the **device profile** genuinely needed a human: it comes through the SDK
  Manager GUI behind a Garmin account login. The old public endpoint,
  `monkeynet.garmin.com`, is dead — NXDOMAIN, doesn't even resolve.

**Article angle #11:** the boundary between "the agent can do this" and "you must do
this" wasn't where either of us guessed. It wasn't the 240 MB download; it was one
OAuth login.

### Two Makefile bugs that only a real toolchain reveals
1. `monkeyc` lives under `~/Library/Application Support/...` — a path **with a space**.
   Make's direct-exec path lookup mishandles it, so PATH alone silently fails with
   "No such file or directory" while `command -v` says it's fine. Fixed by invoking
   absolute quoted paths.
2. `make lint` used `-o /dev/null`. The compiler caches bitmap resources next to the
   output path and dies when that isn't a real file. Lint now writes to `bin/.lint.prg`.

Neither is guessable from docs. Both cost minutes once you can actually run the thing.

### The compiler taught me the API
First compile: one hard error, ten warnings — all real.

- `Symbol`-based dispatch in `Sensors.mc` (`SensorHistory has method`) wouldn't
  type-check. Rewrote it explicit per-metric. My "risky" flag on it was correct.
- `restingHeartRate` isn't on `ActivityMonitor.Info` for every device. Needed a
  `UserProfile` fallback — **which required a new manifest permission the compiler
  refused to build without.** I would not have found that by reading.

**Article angle #12:** three hours of careful reasoning about an API, then thirty
seconds of real compiler output correcting it. The type checker was a better teacher
than the documentation.

### The number I'd refused to guess
Simulator status bar: **13.5 / 107.8 kB**. The fenix 6 Pro watch-face memory ceiling
is ~108 kB and the full HUD uses about 12%.

Which means the argument I used to talk myself out of the field abstraction — "memory
is the binding constraint" — **was wrong**. There's ~94 kB free. The abstraction was
affordable all along.

**Article angle #13 — the honest one:** the agent's most confident architectural
argument was based on an unmeasured assumption, and it held for hours because it
*sounded* like engineering judgement. Measuring took one glance at a status bar.

### Then the photo arrived, and the simulator turned out to be a liar
Got it on the watch via the Connect IQ Store (apps under review are downloadable by
their own author — that's the loophole that beat a dead USB cable). Photographed it in
daylight. Four things the simulator had hidden:

1. **`BODY --` and `STRESS --`.** Both showed values in the sim. On hardware, every
   `SensorHistory` read failed — including the sparkline, which just wasn't there.
   `HR` and `REST` worked, and those come from `Activity` and `UserProfile`. Cause:
   I asked for a single sample, and the newest bucket can exist with **null data**
   when the device hasn't computed it yet. The sim never reproduces that.
2. **`KCA2339`** — a 4-digit calorie value right-aligned straight through its own
   `KCAL` label. Invisible in the sim because sim calories were `0`.
3. **"what is BB?"** — asked by me, the person who commissioned the thing. A label
   needing decoding has already failed at a glance.
4. **Everything grey-on-grey.**

### The MIP insight — this is the best thing in the whole project
Why "the brightness is not that good" was a *design* bug, not a settings problem:

A transflective MIP panel has **no backlight**. Brightness is reflected ambient light,
and a coloured pixel reflects only its own channel — a green pixel returns roughly a
third of what white does.

So colouring a value makes **the thing you read the dimmest thing on screen.** The face
had green `88`, blue `92`, amber `35` sitting next to *brighter* grey labels. Exactly
inverted. On a backlit simulator this is invisible; colour costs nothing there.

Proved it rather than asserting it: rendered current vs proposed, then ran both through
a simulated panel (convert to luminance, compress the range). The comparison is
unambiguous and is going in the article.

Fix: **luminance carries the data, colour carries the status.** Values white and a size
larger; status moved to a small chip beside the label. Same information, none of the
legibility cost.

**Article angle #14 — the second thesis:** on a display without a backlight, colour is
decoration you get for free, not a channel you can put information in. Every design
instinct built on emissive screens inverts.

Corollary caught in the same pass: a green "50%" battery. Colour spent on a healthy
state teaches the eye to ignore colour. It's grey now, and only takes colour when
something is actually wrong.

### Pattern across the whole day
Simulator said fine, hardware disagreed — **three separate times** (fonts,
`restingHeartRate`, `SensorHistory` nulls). Every genuine design correction today came
from a photo of a real wrist, not from iteration in a simulator.

**Article angle #15:** the loop that mattered wasn't prompt → code → simulator. It was
prompt → code → **wrist → photo → prompt**. The human's eyes were the test suite the
project actually needed.

### Where I wasted time (keeping this in)
Burned three failed attempts screenshotting the simulator programmatically — window
bounds, occlusion, focus races — when the app has File → Save Screenshot and I was
sitting at the machine. The agent kept optimising a task it should have handed back
after the first failure.

**Article angle #16:** knowing when to hand a 5-second task back to the human is a
skill the agent conspicuously lacked.

---

## Running list of article angles
1. Step one wasn't prompting, it was an unlinked JDK
2. The agent refused to write one spec for three projects
3. **(thesis)** Port a design system's grammar, not its hex values
4. A well-stocked agent setup meeting a platform none of it was built for
5. "Army watch face" is four mutually-exclusive watches wearing one adjective
6. The best decision came from me correcting the agent's premise
7. The agent argued *for* less abstraction, using the platform's binding constraint
8. Following my own conventions surfaced a silent bug in them — the enforcement
   layer had never run, and the green badge said otherwise
9. The real engineering was deciding what *not* to automate (faked CI is worse than none)
10. Design rationale that becomes a failing test stops being documentation
11. The automatable/manual boundary wasn't where either of us guessed — not the
    240 MB download, but one OAuth login
12. Thirty seconds of real compiler output beat three hours of reasoning about the API
13. The agent's most confident architectural argument rested on an unmeasured
    assumption (memory), and sounded like judgement until someone measured
14. **(second thesis)** On a backlit-free panel, colour is decoration you get free,
    not a channel you can put information in — every emissive-screen instinct inverts
15. The loop that mattered was prompt → code → **wrist → photo** → prompt
16. The agent couldn't tell when to hand a 5-second task back to the human
