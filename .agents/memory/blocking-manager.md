---
name: BlockingManager singleton cache scoping
description: How BlockingManager's in-memory cache is scoped per user UUID and invalidated on sign-out.
---

# BlockingManager singleton cache scoping

BlockingManager is a singleton (`BlockingManager._instance`) with an in-memory `Set<String>? _cache` and a `String? _cachedForUuid` tracker.

**Why:** Without per-user scoping the cache would survive sign-out/sign-in, leaking blocked-user data between accounts.

**How to apply:**
- On sign-out, `main.dart` calls `BlockingManager().invalidate()` before `clearUserData()`.
- `_getCache()` checks `_cachedForUuid != _currentUuid` on every call and resets `_cache` if the user changed.
- The storage key is `blocked-<uuid>` in SharedPreferences.
