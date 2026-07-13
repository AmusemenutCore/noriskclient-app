---
name: Mutable static-getter color palette for theme toggle
description: How a dark/light toggle was retrofitted onto a widely-referenced static-const color class without touching ~160 call sites.
---

When a color/token class is referenced as `SomeColors.foo` across dozens of files and a runtime theme switch is needed, converting the fields from `static const Color` to `static Color get foo => ...` (backed by a private mutable mode + palette lookup) keeps every existing call site compiling unchanged.

**Why:** Rewriting ~160 call sites across ~30 files to a Theme-based or context-dependent API was not worth it for one feature; the getter approach is a drop-in swap at the declaration site only.

**How to apply:** The only breakage is at call sites that used the values inside a `const` constructor (`const TextStyle(color: SomeColors.foo)`) — these no longer compile since the getter isn't a compile-time constant, and the `const` keyword must be removed (mechanically, not the whole expression). Pair this with a `ChangeNotifier` provider that mutates the mode and calls `notifyListeners()`, then have the root `MaterialApp`/`CupertinoApp` builder subscribe to that provider (even without using its value) purely to force a rebuild that re-reads the getters.
