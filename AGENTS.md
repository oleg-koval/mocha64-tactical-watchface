# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex, Cursor, Copilot).

This repo obeys [oleg-koval/starters RULES.md](https://github.com/oleg-koval/starters/blob/main/RULES.md).
Load that file first. Documented exemptions are in "Rule exemptions" below.

## Setup

Connect IQ is a Java-based toolchain. Both parts are required:

```bash
brew install --cask temurin        # any JDK 17+; the SDK will not run without one
java -version                      # must print a version, not an error
```

Then install the **Connect IQ SDK Manager** from
<https://developer.garmin.com/connect-iq/sdk/>, use it to download an SDK and the
device profile you are targeting, and put the SDK's `bin/` on `PATH`.

Generate a signing key once (it is what `monkeyc` signs builds with):

```bash
make key      # writes ~/.Garmin/ConnectIQ/developer_key.der
```

Verify the whole chain:

```bash
make doctor
```

`make doctor` reports java, `monkeyc`, `monkeydo`, and the key. All four must resolve
before anything else works.

## Commands

- Build: `make build`
- Strict type check (this repo's "lint"): `make lint`
- Unit tests: `make test`
- Run in simulator: `make sim`
- Sideload to a mounted watch: `make deploy`
- Build a Connect IQ Store package: `make package`
- Environment check: `make doctor`

`make lint` and `make test` must pass. CI runs the SDK-free gates on every push; the
compile job runs only when `CONNECTIQ_SDK_URL` is set as a repo variable.

## Pre-commit hooks

```bash
make hooks
```

Hooks block a commit on: a staged signing key, any `.mc` file over 300 lines,
`make lint`, and `make test`. `git commit --no-verify` is rejected in code review.

## Conventions

- Monkey C with **strict type checking** (`-l 3`). Annotate types on every function
  signature. `make lint` fails on a missing or wrong annotation.
- `import Toybox.Lang;` in every file — it is what makes `Number`, `String`, `Float`
  and `Boolean` resolvable.
- **Pure logic goes in modules, drawing goes in views.** `Fields.mc` and `Palette.mc`
  contain no `Dc` calls, which is what makes them unit-testable. A `View`'s `onUpdate`
  composes primitives and computes nothing.
- Layout constants live in `Layout.mc` as a flat table. Do not build a field-object
  abstraction without profiling first — see "Memory" below.
- Colours live in `Palette.mc`. Never inline a hex value at a call site.
- Tests are `(:test)` functions returning `Boolean`, in `tests/`, excluded from
  release builds by `base.excludeAnnotations = test` in `monkey.jungle`.

## Memory

Connect IQ enforces a per-device memory ceiling, and it is the binding constraint on
almost every design decision — tighter than CPU, tighter than battery.

Consequences that override normal good taste:

- Prefer a flat constants table to a table of objects or closures.
- Prefer computing a value twice to caching it in a member field.
- Check the simulator's memory profiler before adding any abstraction layer.

If you are about to introduce indirection for elegance, don't. Profile, then decide.

## Rule exemptions

**RULES.md §2.4 (format gate) — exempt, no substitute available.**
No formatter exists for Monkey C: there is no `gofmt`, `prettier` or `ruff format`
equivalent, and Garmin ships none. The mandated format hook therefore cannot be
implemented. Compensating controls in its place:

- `.editorconfig` fixes indentation (4 spaces for `.mc`)
- `trailing-whitespace` and `end-of-file-fixer` pre-commit hooks
- `make lint` at strict type-check level, which is a stronger correctness gate than
  formatting

**RULES.md §2.3 (E2E over unit tests) — adapted, not exempt.**
A watch face has no callable public interface, so "E2E" here means the simulator and
the physical device, neither of which is automatable. Unit tests therefore cover the
pure functions §2.3 permits (formatters, colour banding, quantisation, goal maths), and
the E2E layer is a documented manual check: simulator for layout, then the real watch
**in daylight** — a transflective MIP panel is a materially different display from the
simulator, and contrast decisions cannot be judged anywhere else.

## Don't

- Don't commit `developer_key.der`, any `.pem`, or any `.der`. A hook and a CI gate
  both block it. If one is ever pushed, rotate it.
- Don't hardcode screen coordinates in a view. Put them in `Layout.mc`.
- Don't add live seconds to a watch face without measuring battery cost. In low-power
  mode a face gets one `onUpdate` per minute; seconds require `onPartialUpdate` with a
  clip region and a hard power budget.
- Don't write WHAT-comments (RULES.md §2.6). Name things properly instead.
- Don't assume a device capability. Read it from the SDK device profile.
