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

## Open threads to resolve
- [x] What "army-like" means → tactical HUD, gym/health subject matter
- [x] Which data fields → recovery/readiness + activity/goals
- [x] What "Hermes" is → my TG bot; likely Phase 2's off-watch store
- [ ] Verify the 4×4×4 palette lattice hypothesis against the SDK profile
- [ ] Exact Fenix 6 Pro memory ceiling from the SDK device profile (don't guess)
- [ ] Whether `SensorHistory` actually exposes Body Battery + stress on this device
- [ ] Whether Training Status / Load / VO2max are reachable at all (Phase 2 blocker)
- [ ] How to publish to a DB-backed blog
- [ ] Disambiguate Hermes-the-bot from Hermes-the-agent-harness

## Running list of article angles
1. Step one wasn't prompting, it was an unlinked JDK
2. The agent refused to write one spec for three projects
3. **(thesis)** Port a design system's grammar, not its hex values
4. A well-stocked agent setup meeting a platform none of it was built for
5. "Army watch face" is four mutually-exclusive watches wearing one adjective
6. The best decision came from me correcting the agent's premise
7. The agent argued *for* less abstraction, using the platform's binding constraint
