---
name: Global state architecture
description: How auth data and cache are managed in main.dart; known fragility.
---

# Global state architecture

Auth (`userData` Map) and in-memory cache (`cache` Map) are top-level globals in `main.dart`. Events are coordinated via a `StreamController<List>` (`updateStream`) with stringly-typed events like `['signIn', data]`, `['signOut']`, `['loadSkin', uuid, callback]`, etc.

**Why it exists:** Original design; no migration has been done yet.

**Why it's fragile:** Any widget can mutate the Maps directly without notification. Wrong event key names or list indices silently fail. Follow-up tasks #3 covers migrating to typed ChangeNotifiers/Providers.

**How to apply:** When adding new cross-widget state, prefer adding it through the updateStream protocol for now (until the proper refactor happens). Do not add new global top-level variables.
