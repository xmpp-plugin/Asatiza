# File Catalog

Every project-owned file under `lib/`, `supabase/`, `test/` and `integration_test/`. Generated and tool files are not catalogued. Update only for new, changed, moved or removed files.

Last audit: 2026-11-18.

| Path | Purpose | Layer | Public classes / functions | Dependencies | Side effects |
|---|---|---|---|---|---|
| `lib/main.dart` | Flutter starter counter app (to be replaced by the composition root in `PHASE_001`) | App entry | `main()`, `MyApp`, `MyHomePage`, `_MyHomePageState` | `package:flutter/material.dart` | `runApp` |
| `test/widget_test.dart` | Starter smoke test for the counter | Test | `main()` | `flutter_test`, `package:asatiza/main.dart` | None |

`supabase/` and `integration_test/` do not exist yet.
