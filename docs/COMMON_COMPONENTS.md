# Common Components

## Verified

VERIFIED 2026-11-26 (`PHASE_006`): `ProfileStrengthCard` removed (no percentage); `StepProgressHeader` has no Skip; `pickProfileOption` (country / time zone sheet) is shared by teacher and student setup (top-level function in `teacher_setup_screen.dart`). Theme tokens `AppRadius.strengthCard` and the strength-card text style are now unused (kept; removal needs approval).

VERIFIED 2026-11-24 (`PHASE_005`): `AppAvatar` shows `Profile.photoUrl` (or an unsaved `preview`) clipped to a circle, with the initials while loading and on error; `showPhoto: false` keeps initials (student photos in discover lists). `PhotoSourceSheet` (Take a photo / Choose from gallery on `AppBottomSheet`). Feature widgets: `PhotoPickerTile` (`preview`, `loading`), `UploadTile` (`loading`), `CertificateRow` (original file name, `onTap` opens the viewer; reused by teacher setup), `PersonRow.showPhoto`.

VERIFIED 2026-11-24 (`PHASE_004` fix): `AppButton.loading` (spinner left of the label, variant colours kept, taps ignored) and `ConfirmSheet.loading` (spinner on confirm, Cancel disabled). Every button that starts a call passes its cubit's busy flag.

VERIFIED 2026-11-23 (`PHASE_003`) — new in `lib/core/widgets/`: `AppSegmentedControl`, `AppOptionTile`, `AppSwitch`, `AppInfoNote` (promoted from part 1 screens; `InfoNote` removed), `SearchField` (list and pill styles), `CountBadge` (gold filter count / red unread), `InfoRow`, `ProfileHeader`, `TeacherCardSkeleton`, `ChatRowSkeleton`, `SettingsTile`, `AppSwitchTile`, `ConfirmSheet`. Feature widgets: `TeacherCard`, `StudentCard`, `FilterChipsBar`, `FeeRangeSlider`, `PersonRow` (discover); `RequestTile` (connections); `ConversationTile`, `ChatBubble`, `ChatImageBubble`, `DayDivider`, `MessageComposer`, `ChatHeader` (chat); `NotificationTile`, `RequestNotificationTile` (notifications); `CertificateRow` (profile). A 24 px detail chip is still private in 4 screens (candidate for a shared widget, needs approval).

VERIFIED 2026-11-19 (`PHASE_002`) — `lib/core/widgets/`: `AppIcon` (design SVG icons, stroke/fill variants), `AppButton` (primary/secondary/danger, 48 px / 36 px), `AppTextField`, `AppTextArea` (counter), `AppChip`, `TagChip`, `AppAvatar` (initials + verified), `VerifiedBadge`, `AppCheckbox`, `SectionLabel`, `BackHeader`, `AppBottomSheet`, `StepProgressHeader`, `NumberedStepper`, `OtpInput`, `ProfileStrengthCard`, `PostCard`, `EmptyStateView`, `SkeletonBox`, `PostCardSkeleton`. Feature widgets: `RoleCard`, `InfoNote` (auth); `WelcomeSlide`, `PageDots` (onboarding); `WeekdayPicker`, `PhotoPickerTile`, `UploadTile` (profile_setup); `HomeTopBar`, `CommentTile`, `CommentComposer` (feed). Private, screen-local for now (promote in part 2 with approval): segmented control, radio option tile, age-group card, design switch.

VERIFIED 2026-11-19 (`PHASE_001`):

| Component | Location | Used by |
|---|---|---|
| Theme tokens: `AppColors` (light/dark, read via `Theme.of(context).extension<AppColors>()!`), `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows` | `lib/core/theme/` | All |
| `AppTheme.light()` / `AppTheme.dark()` | `lib/core/theme/app_theme.dart` | `AsatizaApp` |
| `MainShell` bottom bar with raised centre "+" | `lib/core/widgets/main_shell.dart` | Router shell |

## Decided Shared Components (`lib/core/`)

| Component | Location | Used by |
|---|---|---|
| Theme (colors, text styles, spacing) | `lib/core/theme/` | All |
| Primary / secondary buttons | `lib/core/widgets/` | All |
| Text input with validation | `lib/core/widgets/` | Auth, profile, post, chat |
| 6-digit OTP input (auto-submit, resend after 60 s) | `lib/core/widgets/` | Sign-up, forgot password |
| Avatar (with placeholder) | `lib/core/widgets/` | Feed, discover, chat, profile |
| Post card | `lib/core/widgets/` or `features/feed` | Feed, profile |
| Person card with Connect | `lib/core/widgets/` | Discover, connections |
| Empty / loading / error views | `lib/core/widgets/` | All lists |
| Report / Block bottom sheet | `lib/core/widgets/` | Post, profile, chat |
| Profile-strength card (widget; % from `ProfileStrengthCalculator` in `lib/core/logic/`) | `features/profile_setup` | Home, profile |
| Validators (email, password 8+, lengths) | `lib/core/utils/` | Forms |
| `ImageCompressor` service (posts ~200 KB, avatars ~60 KB) | `lib/core/services/` | Profile, post, chat |
| `ImagePickerService`, `PushNotificationService`, `ErrorReporter` | `lib/core/services/` | Profile, post, chat, notifications, app root |

Update this table when a component is created (mark VERIFIED with its real path).

## Reuse Rule

Search `lib/core/` and the affected feature before creating new UI or helpers. When an existing component is not suitable, document why in the phase file. Adding a shared widget requires approval unless listed in the approved phase.
