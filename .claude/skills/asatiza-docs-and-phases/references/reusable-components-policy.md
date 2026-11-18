# Reusable Components Policy

Search before creating new UI or helpers.

Look for:

- Shared widgets in `lib/core/widgets/` (buttons, text fields, avatar, post card, person card, OTP input, empty/loading/error views, bottom sheets, dialogs).
- Theme, colors, text styles, spacing and constants in `lib/core/theme/` and `lib/core/constants/`.
- Validators, formatters and date/time-zone helpers in `lib/core/utils/`.
- Shared business rules in `lib/core/logic/` and feature rules in `lib/features/<feature>/logic/` (e.g. profile strength, visibility thresholds).
- Plugin wrappers in `lib/core/services/` (`ImageCompressor`, `ImagePickerService`, `PushNotificationService`, `ErrorReporter`).
- Failure types and error mapping in `lib/core/errors/`.
- Feature widgets in `lib/features/<feature>/presentation/widgets/` before creating a similar one in another feature.
- Existing models in `lib/data/models/` and repository methods in `lib/data/repositories/` before adding new ones.
- Existing assets listed in `pubspec.yaml` before adding new assets.

The list in `docs/COMMON_COMPONENTS.md` is authoritative; update it whenever a shared component is added.

When reuse is not suitable, document the reason in the phase and implementation report.
