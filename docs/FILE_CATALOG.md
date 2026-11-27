# File Catalog

Every project-owned file under `lib/` and `test/`. Generated and tool files are not catalogued (`lib/l10n/app_localizations*.dart` come from `flutter gen-l10n`). Assets: `assets/fonts/` (PHASE_001), `assets/icons/` (42 design icons), `assets/illustrations/` (6), `assets/images/` (2 logos) — PHASE_002.

Last audit: 2026-11-19 (`PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA`); rows added 2026-11-23 (`PHASE_004`) and 2026-11-24 (`PHASE_005`). Outside `lib/` and `test/`: `supabase/migrations/*.sql`, `supabase/tests/profiles_rls_checks.sql`, `supabase/tests/storage_policies_checks.sql` (`PHASE_005`), `env/supabase.example.json` (`PHASE_004`; template for the git-ignored, bundled `env/supabase.json`). Rows updated 2026-11-26 (`PHASE_006` scope change: percentage removed, profile status). Rows updated 2026-11-26 (`PHASE_007`: blocks, mocks of real features moved to `test/fakes/`). Rows updated 2026-11-26 (`PHASE_008`: connections). Rows updated 2026-11-27 (`PHASE_009`: chat, mocks of chat / connections / profiles moved to `test/fakes/`).

| Path | Purpose | Layer | Public types / functions |
|---|---|---|---|
| `lib/app.dart` | Root widget: light/dark theme from the design tokens (following the phone setting), English localization and the session-aware router.… | App | `AsatizaApp` |
| `lib/core/config/app_config.dart` | Run-time settings (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) from defines or the bundled `env/supabase.json` (only those two keys allowed); both are required. | Core config | `AppConfig` |
| `lib/core/errors/failures.dart` | Base type for every error a repository may throw. No raw exception (Postgrest, Auth, Dio…) leaves a repository. | Core errors | `Failure`, `ValidationFailure`, `ValidationReason`, `NotFoundFailure`, `NetworkFailure`, `UnexpectedFailure` |
| `lib/core/logic/certificate_file_rules.dart` | Certificate rules: PDF only (`%PDF-` header), 3 MB, one per teacher, safe file name and display name. Pure. | Core logic | `CertificateFileRules` |
| `lib/core/logic/discover_visibility_rules.dart` | Who appears on the Teachers / Students tabs and who may send a request: every active profile (`Profile.isActive`). | Core logic | `DiscoverVisibilityRules` |
| `lib/core/logic/profile_completeness_rules.dart` | Required fields of an active profile and their setup step; mirrors `private.profile_is_complete` (PHASE_006). | Core logic | `RequiredField`, `ProfileCompletenessRules` |
| `lib/core/router/app_router.dart` | Builds the app's route table, redirecting on the [session]: - signed out → only Splash and the sign-in screens; - signed in right after… | Core router | `createAppRouter` |
| `lib/core/router/app_routes.dart` | — | Core router | `AppRoutes` |
| `lib/core/services/document_picker_service.dart` | Lets the user choose a PDF (wraps `file_picker`). | Core service interface | `DocumentPickerService` |
| `lib/core/services/file_picker_document_picker_service.dart` | `DocumentPickerService` on `file_picker` (`.pdf` filter; larger files are not read). | Core service | `FilePickerDocumentPickerService` |
| `lib/core/services/flutter_image_compress_image_compressor.dart` | `ImageCompressor` on `flutter_image_compress` (JPEG, 512 px, quality 80). | Core service | `FlutterImageCompressImageCompressor` |
| `lib/core/services/image_compressor.dart` | Shrinks a picked photo to an avatar JPEG. | Core service interface | `ImageCompressor` |
| `lib/core/services/image_picker_image_picker_service.dart` | `ImagePickerService` on `image_picker` (camera / gallery, 1600 px max). | Core service | `ImagePickerImagePickerService` |
| `lib/core/services/image_picker_service.dart` | Lets the user take or choose a photo. | Core service interface | `ImagePickerService` |
| `lib/core/services/image_source_kind.dart` | Camera or gallery. | Core service | `ImageSourceKind` |
| `lib/core/session/session_cubit.dart` | App-wide session. Starts signed out; `restore` signs back in with a kept session (backend mode). Keeps the signed-in user's profile fresh after edits. | Core session | `SessionCubit` |
| `lib/core/session/session_state.dart` | Who is signed in, and whether they still see profile setup. | Core session | `SessionState` |
| `lib/core/session/shell_badges_cubit.dart` | Combines unread chat messages and unread notifications for the bottom bar badges. | Core session | `ShellBadgesCubit` |
| `lib/core/session/shell_badges_state.dart` | Unread counts on the bottom bar. | Core session | `ShellBadgesState` |
| `lib/core/theme/app_colors.dart` | Color tokens of the Asatiza design system (owner's design canvas, `project/ds/asatiza/tokens.json`), one set per brightness. Read in… | Core theme | `AppColors` |
| `lib/core/theme/app_radius.dart` | — | Core theme | `AppRadius` |
| `lib/core/theme/app_shadows.dart` | — | Core theme | `AppShadows` |
| `lib/core/theme/app_spacing.dart` | — | Core theme | `AppSpacing` |
| `lib/core/theme/app_text_styles.dart` | — | Core theme | `AppTextStyles` |
| `lib/core/theme/app_theme.dart` | — | Core theme | `AppTheme` |
| `lib/core/utils/relative_time_formatter.dart` | Short relative times as in the design: "now", "20m", "2h", "Yesterday", "Mon", "12 Nov". | Core utils | `RelativeTimeFormatter` |
| `lib/core/widgets/app_avatar.dart` | Round avatar: the profile photo (or an unsaved preview) when there is one, else initials on a token tint from the profile id; `showPhoto: false` keeps initials. | Core widgets | `AppAvatar` |
| `lib/core/widgets/app_bottom_sheet.dart` | The design's bottom sheet: white, 24 px top corners, raised shadow, 40×4 grabber, 20 px side padding, over the scrim colour. | Core widgets | `AppBottomSheet` |
| `lib/core/widgets/app_button.dart` | The design's buttons: primary (brand fill), secondary (white with brand outline) and danger. A null [onPressed] shows the disabled style… | Core widgets | `AppButtonVariant`, `AppButtonSize`, `AppButton` |
| `lib/core/widgets/app_checkbox.dart` | 22 px checkbox (6 px radius) with a label beside it; the whole row is tappable. Checked = brand fill with a white check. | Core widgets | `AppCheckbox` |
| `lib/core/widgets/app_chip.dart` | 36 px selectable pill: surface-200 when off; brand-100 fill, brand outline and a check icon when on. | Core widgets | `AppChip` |
| `lib/core/widgets/app_icon.dart` | A design icon from `assets/icons/` (24×24 stroke icons exported from the design canvas). [color] fills `currentColor`; [strokeWidth] and… | Core widgets | `AppIcon` |
| `lib/core/widgets/app_info_note.dart` | Quiet surface-200 note with an 18 px icon, e.g. "Can’t find it? Check your Spam folder…" on the email-code screen. | Core widgets | `AppInfoNote` |
| `lib/core/widgets/app_option_tile.dart` | Radio option card: 22 px ring, title and description. | Core widgets | `AppOptionTile` |
| `lib/core/widgets/app_segmented_control.dart` | Segmented control from the artboards: surface-200 track (12 px radius, 4 px padding); the selected segment is white with a brand label. | Core widgets | `AppSegmentedControl` |
| `lib/core/widgets/app_switch.dart` | 48×28 switch from the artboards (brand track when on). | Core widgets | `AppSwitch` |
| `lib/core/widgets/app_switch_tile.dart` | 52 px row with a label and an [AppSwitch] (Settings → Notifications). | Core widgets | `AppSwitchTile` |
| `lib/core/widgets/app_text_area.dart` | Multi-line field with an optional label above and a "n / max" counter below on the end side (bio, notes). | Core widgets | `AppTextArea` |
| `lib/core/widgets/app_text_field.dart` | The design's 48 px input: label above, white field with a 1 px line border that becomes a 2 px brand border while focused, optional… | Core widgets | `AppTextField` |
| `lib/core/widgets/back_header.dart` | 56 px header with a 44 px back (or close) button, an optional page title (18/24 bold) and optional trailing widgets. | Core widgets | `BackHeader` |
| `lib/core/widgets/chat_row_skeleton.dart` | Loading placeholder for a chat row (artboard 24). | Core widgets | `ChatRowSkeleton` |
| `lib/core/widgets/confirm_sheet.dart` | Confirmation sheet (artboards 21f / 21g): optional 56 px icon circle, 20 px title, muted message, optional [body], then Cancel and the… | Core widgets | `ConfirmSheet` |
| `lib/core/widgets/count_badge.dart` | Small count bubble with a 2 px ring in the surface behind it. [gold] is the 20 px filter-count badge (gold fill); otherwise it is the 18… | Core widgets | `CountBadge` |
| `lib/core/widgets/empty_state_view.dart` | Empty state: icon in a 52 px brand-100 circle, title, one line of text and an optional small action button (artboard "23 Empty states"). | Core widgets | `EmptyStateView` |
| `lib/core/widgets/info_row.dart` | Detail line from the profile cards: 20 px muted icon, 14 px text and an optional bold gold value at the end (e.g. "Fee … $40 / month"). | Core widgets | `InfoRow` |
| `lib/core/widgets/main_shell.dart` | App shell with the designed bottom bar: Home · Teachers · raised centre "+" · Chats · Alerts. Tab screens are the [navigationShell]… | Core widgets | `MainShell` |
| `lib/core/widgets/numbered_stepper.dart` | "① Email — ② Code — ③ New password": done and current steps are brand filled circles, later steps are outlined. | Core widgets | `NumberedStepper` |
| `lib/core/widgets/otp_input.dart` | Six 48×58 digit boxes (10 px radius). One hidden text field takes the input, so paste and SMS/email autofill work; the next empty box… | Core widgets | `OtpInput` |
| `lib/core/widgets/photo_source_sheet.dart` | "Profile photo" sheet: Take a photo / Choose from gallery. | Core widgets | `PhotoSourceSheet` |
| `lib/core/widgets/post_card.dart` | Feed post card: author row, text (4 lines in the feed), optional Arabic verse and photo, tag + counts, and Like / Comment / Report actions. | Core widgets | `PostCard` |
| `lib/core/widgets/post_card_skeleton.dart` | Loading version of a post card (artboard "24 Loading states"). | Core widgets | `PostCardSkeleton` |
| `lib/core/widgets/profile_header.dart` | Centred profile header: 88 px avatar, 26 px display name, muted subtitle and an optional pill — gold "Verified teacher" ([goldBadge]) or… | Core widgets | `ProfileHeader` |
| `lib/core/widgets/search_field.dart` | Search input from the artboards: 44 px, 20 px search icon, 15 px text. The list style ([pill] false) is a 12 px-radius white field with… | Core widgets | `SearchField` |
| `lib/core/widgets/section_label.dart` | Section heading (15/20, bold) with optional trailing text, e.g. "Choose a tag … Required" or "Available days … 5:00–9:00 pm". | Core widgets | `SectionLabel` |
| `lib/core/widgets/settings_tile.dart` | Settings row (artboard 21): 22 px icon, 15 px label, optional muted [value] below, and a chevron when it opens a screen. [danger] tints… | Core widgets | `SettingsTile` |
| `lib/core/widgets/skeleton_box.dart` | A surface-200 placeholder block for loading states. | Core widgets | `SkeletonBox` |
| `lib/core/widgets/step_progress_header.dart` | Profile-setup header: optional back button, "Step n of total" centred and one bar per step (no Skip). | Core widget | `StepProgressHeader` |
| `lib/core/widgets/tag_chip.dart` | 24 px post tag label: brand tint, or gold tint for achievements and class announcements. | Core widgets | `TagChip` |
| `lib/core/widgets/teacher_card_skeleton.dart` | Loading placeholder for a teacher / student card (artboard 24). | Core widgets | `TeacherCardSkeleton` |
| `lib/core/widgets/verified_badge.dart` | Gold circle with a dark check: the "Verified teacher" badge. | Core widgets | `VerifiedBadge` |
| `lib/data/mock/mock_chats.dart` | — | Mock data | — |
| `lib/data/mock/mock_connections.dart` | Seed connections, created relative to [now]. Accepted pairs match `mockConnectedIds` (feed order); the student account has 2 requests… | Mock data | `buildMockConnections` |
| `lib/data/mock/mock_notifications.dart` | Seed notifications, created relative to [now]. Request notifications point at the pending requests in `buildMockConnections`… | Mock data | `buildMockNotifications` |
| `lib/data/mock/mock_posts.dart` | 14 seed posts, created relative to [now]. `commentCount` is filled from [buildMockComments] by the repository. | Mock data | `MockPostSeed`, `MockImages`, `buildMockPosts`, `buildMockComments` |
| `lib/data/mock/mock_profiles.dart` | The signed-in user's connections, used for feed order. | Mock data | `MockIds`, `MockAccounts`, `mockConnectedIds`, `buildMockProfiles` |
| `lib/data/models/app_notification.dart` | One in-app notification (mirrors the planned `notifications` table). | Model / enum | `AppNotification` |
| `lib/data/models/comment.dart` | A comment on a post (plan table `post_comments`). | Model / enum | `Comment` |
| `lib/data/models/connection.dart` | A connection request between two users (mirrors the planned `connections` table, plan section 12). | Model / enum | `Connection` |
| `lib/data/models/conversation.dart` | A one-to-one chat between two connected users, as seen by one viewer: [lastMessage] and [unreadCount] are filled per viewer by the… | Model / enum | `Conversation` |
| `lib/data/models/enums/connection_status.dart` | Lifecycle of a connection request (plan section 4: chat only after [accepted]). | Model / enum | `ConnectionStatus` |
| `lib/data/models/enums/experience_filter.dart` | Teacher filter "Experience": Any / 2+ / 5+ / 10+ years. | Model / enum | `ExperienceFilter`, `ExperienceFilterLabel` |
| `lib/data/models/enums/fee_unit.dart` | — | Model / enum | `FeeUnit`, `FeeUnitLabel` |
| `lib/data/models/enums/gender.dart` | — | Model / enum | `Gender`, `GenderLabel` |
| `lib/data/models/enums/learner_age_group.dart` | Age group of the learner on a student account. | Model / enum | `LearnerAgeGroup`, `LearnerAgeGroupLabel` |
| `lib/data/models/enums/learner_level.dart` | Current reading level of a learner. | Model / enum | `LearnerLevel`, `LearnerLevelLabel` |
| `lib/data/models/enums/media_bucket.dart` | Storage buckets used by the app (`avatars`, `certificates`). | Model enum | `MediaBucket` |
| `lib/data/models/enums/notification_type.dart` | Kinds of in-app notification (plan section 9). | Model / enum | `NotificationType` |
| `lib/data/models/enums/post_tag.dart` | The one tag every post carries (plan section 4). | Model / enum | `PostTag`, `PostTagLabel` |
| `lib/data/models/enums/report_reason.dart` | Report reasons (plan section 9). | Model / enum | `ReportReason`, `ReportReasonLabel` |
| `lib/data/models/enums/subject.dart` | Quran-learning subjects (plan section 7). | Model / enum | `Subject`, `SubjectLabel` |
| `lib/data/models/enums/teacher_gender_preference.dart` | A student's preferred teacher gender. | Model / enum | `TeacherGenderPreference`, `TeacherGenderPreferenceLabel` |
| `lib/data/models/enums/teaches_audience.dart` | Who a teacher teaches (plan section 7). | Model / enum | `TeachesAudience`, `TeachesAudienceLabel` |
| `lib/data/models/enums/teaching_language.dart` | Languages a teacher teaches in or a student speaks. | Model / enum | `TeachingLanguage`, `TeachingLanguageLabel` |
| `lib/data/models/enums/user_role.dart` | Account role, chosen at sign-up (one per account). | Model / enum | `UserRole`, `UserRoleLabel` |
| `lib/data/models/enums/weekday.dart` | Days of the week, Monday first, as in the availability picker. | Model / enum | `Weekday`, `WeekdayLabel` |
| `lib/data/models/message.dart` | One chat message: text, an image, or both (mirrors the planned `messages` table, plan section 12). | Model / enum | `Message` |
| `lib/data/models/notification_settings.dart` | Which notifications a user wants (Settings → Notifications). | Model / enum | `NotificationSettings` |
| `lib/data/models/picked_document.dart` | A file chosen with the document picker (name, size, bytes). | Model | `PickedDocument` |
| `lib/data/models/post.dart` | A feed post (plan table `posts`), as seen by one viewer. | Model / enum | `Post` |
| `lib/data/models/profile.dart` | A user's public profile (plan table `profiles`). Exactly one of [teacherDetails] / [studentDetails] matches [role]. | Model / enum | `Profile`, `on` |
| `lib/data/models/student_details.dart` | Student-only profile data (plan table `student_details`). | Model / enum | `StudentDetails` |
| `lib/data/models/teacher_details.dart` | Teacher-only profile data (plan table `teacher_details`). | Model / enum | `TeacherDetails` |
| `lib/data/repositories/auth_repository.dart` | — | Repository interface | `AuthRepository` |
| `lib/data/repositories/chat_repository.dart` | — | Repository interface | `ChatRepository` |
| `lib/data/repositories/connection_repository.dart` | — | Repository interface | `ConnectionRepository` |
| `lib/data/repositories/discover_repository.dart` | Contract for the Teachers / Students tabs (visible people; reload by re-subscribing). | Repository interface | `DiscoverRepository` |
| `lib/data/repositories/feed_repository.dart` | — | Repository interface | `FeedRepository` |
| `lib/data/repositories/media_repository.dart` | Storage uploads, download of the own certificate, removals. | Repository interface | `MediaRepository` |
| `lib/data/repositories/mock/mock_feed_repository.dart` | In-memory [FeedRepository] seeded with [buildMockPosts] and [buildMockComments]. State resets when the app restarts. | Mock data | `MockFeedRepository` |
| `lib/data/repositories/mock/mock_notification_repository.dart` | In-memory [NotificationRepository] (resets on restart). | Mock data | `MockNotificationRepository` |
| `lib/data/repositories/mock/mock_safety_repository.dart` | In-memory [SafetyRepository] (post reports only, until the Feed phase). | Mock data | `MockSafetyRepository` |
| `lib/data/repositories/notification_repository.dart` | — | Repository interface | `NotificationRepository` |
| `lib/data/repositories/profile_repository.dart` | — | Repository interface | `ProfileRepository` |
| `lib/data/repositories/block_repository.dart` | Blocks contract (PHASE_007): block, unblock, blocked ids / users. | Repository interface | `BlockedUser`, `BlockRepository` |
| `lib/data/repositories/safety_repository.dart` | Reports contract (blocks moved to `BlockRepository` in PHASE_007). | Repository interface | `SafetyRepository` |
| `lib/data/repositories/supabase/profile_row_mapper.dart` | Converts profile / detail rows to `Profile` and back (snake_case enum text). Pure. | Repository (Supabase) | `ProfileRowMapper` |
| `lib/data/repositories/supabase/supabase_auth_repository.dart` | `AuthRepository` on Supabase Auth with 6-digit email codes; deletion via `delete_my_account()`. | Repository (Supabase) | `SupabaseAuthRepository` |
| `lib/data/repositories/supabase/supabase_block_repository.dart` | `BlockRepository` on `public.blocks` (RLS: own blocks only); streams reload after local changes. | Repository (Supabase) | `SupabaseBlockRepository` |
| `lib/data/repositories/supabase/supabase_chat_repository.dart` | `ChatRepository` on conversations / messages: RLS reads, chat functions, Realtime reloads, signed photo URLs. | Repository (Supabase) | `SupabaseChatRepository` |
| `lib/data/repositories/supabase/supabase_connection_repository.dart` | `ConnectionRepository` on `public.connections`: RLS reads, writes through 3 database functions, `connection_count`; maps rule messages to `Failure`s. | Repository (Supabase) | `SupabaseConnectionRepository` |
| `lib/data/repositories/supabase/supabase_discover_repository.dart` | `DiscoverRepository` on active `profiles` (+ details); drops people the viewer blocked and reloads when blocks change; student photos removed. | Repository (Supabase) | `SupabaseDiscoverRepository` |
| `lib/data/repositories/supabase/supabase_failure_mapper.dart` | Maps Supabase Auth / PostgREST / Storage / network errors to `Failure`s. Pure. | Repository (Supabase) | `SupabaseFailureMapper` |
| `lib/data/repositories/supabase/supabase_media_repository.dart` | `MediaRepository` on Supabase Storage (owner folders; authenticated certificate download). | Repository (Supabase) | `SupabaseMediaRepository` |
| `lib/data/repositories/supabase/supabase_profile_repository.dart` | `ProfileRepository` on `profiles`, `teacher_details`, `student_details` (RLS). | Repository (Supabase) | `SupabaseProfileRepository` |
| `lib/features/auth/bloc/login_cubit.dart` | Email + password log-in (no code at log-in, plan section 4). | Feature auth · bloc | `LoginCubit` |
| `lib/features/auth/bloc/login_state.dart` | — | Feature auth · bloc | `LoginStatus`, `LoginState` |
| `lib/features/auth/bloc/otp_cubit.dart` | 6-digit email code: auto-verifies when complete, runs the 60 s resend countdown (cancelled in [close]). | Feature auth · bloc | `OtpCubit` |
| `lib/features/auth/bloc/otp_state.dart` | Why the code was sent. | Feature auth · bloc | `OtpPurpose`, `OtpStatus`, `OtpState` |
| `lib/features/auth/bloc/password_reset_cubit.dart` | Forgot password: step 1 sends the code, step 3 saves the new password and signs in. (Step 2, the code, uses [OtpCubit].) | Feature auth · bloc | `PasswordResetCubit` |
| `lib/features/auth/bloc/password_reset_state.dart` | Forgot-password email step and new-password step. | Feature auth · bloc | `PasswordResetStatus`, `PasswordResetState` |
| `lib/features/auth/bloc/sign_up_cubit.dart` | Sign-up form. On success the screen opens the email-code step. | Feature auth · bloc | `SignUpCubit` |
| `lib/features/auth/bloc/sign_up_state.dart` | — | Feature auth · bloc | `SignUpStatus`, `SignUpState` |
| `lib/features/auth/logic/otp_rules.dart` | Email-code rules (plan section 4). | Feature auth · logic | `OtpRules` |
| `lib/features/auth/logic/password_rules.dart` | Password and email rules used by sign-up, log-in and password reset. | Feature auth · logic | `PasswordRules` |
| `lib/features/auth/presentation/email_code_screen.dart` | 04 Email code after sign-up: 6 boxes (auto-verify), resend timer, "Wrong email? Change it" and the spam-folder note. | Feature auth · presentation | `EmailCodeScreen` |
| `lib/features/auth/presentation/forgot_password_screen.dart` | 06 / 06a Forgot password: step 1 (email) and step 2 (code). Step 3 is [NewPasswordScreen]. | Feature auth · presentation | `ForgotPasswordScreen` |
| `lib/features/auth/presentation/log_in_screen.dart` | 05 Log in: email + password only (no code at log-in). | Feature auth · presentation | `LogInScreen` |
| `lib/features/auth/presentation/new_password_screen.dart` | 06b New password (step 3 of 3): two fields, live rule checks, then "Save and log in". | Feature auth · presentation | `NewPasswordScreen` |
| `lib/features/auth/presentation/sign_up_screen.dart` | 03 Sign up: role, name, email, password and the 18+ / Terms consent. | Feature auth · presentation | `SignUpScreen` |
| `lib/features/auth/presentation/widgets/role_card.dart` | Sign-up role card ("I am a Student / Teacher"): icon, title, one line. | Feature auth · presentation | `RoleCard` |
| `lib/features/chat/bloc/chat_cubit.dart` | Opens the chat with [otherId] (only for accepted connections), streams its messages, marks them read while open and sends text or an image. | Feature chat · bloc | `ChatCubit` |
| `lib/features/chat/bloc/chat_state.dart` | 18 Chat conversation. | Feature chat · bloc | `ChatStatus`, `ChatState` |
| `lib/features/chat/bloc/chats_cubit.dart` | Lists the viewer's conversations and searches them by name. | Feature chat · bloc | `ChatsCubit` |
| `lib/features/chat/bloc/chats_state.dart` | 17 Chats list. | Feature chat · bloc | `ChatsState` |
| `lib/features/chat/presentation/chat_screen.dart` | 18 Chat with one connection ([otherId]). | Feature chat · presentation | `ChatScreen` |
| `lib/features/chat/presentation/chats_screen.dart` | 17 Chats: search and the conversation list. | Feature chat · presentation | `ChatsScreen` |
| `lib/features/chat/presentation/widgets/chat_bubble.dart` | Text bubble (artboard 18): own messages are brand with read ticks on the end side; received ones are white with a line border. Links… | Feature chat · presentation | `ChatBubble` |
| `lib/features/chat/presentation/widgets/chat_header.dart` | Chat top bar (artboard 18): back, 40 px avatar with name and role line (opens the profile), and the options button. | Feature chat · presentation | `ChatHeader` |
| `lib/features/chat/presentation/widgets/chat_image_bubble.dart` | Image message (artboard 18): 220 px bubble with a 130 px image, optional caption and the time (plus read ticks on own messages). | Feature chat · presentation | `ChatImageBubble` |
| `lib/features/chat/presentation/widgets/conversation_tile.dart` | Chat list row (artboard 17): 52 px avatar, name, time and last message. Unread rows are white with a bold name, brand time and a count… | Feature chat · presentation | `ConversationTile` |
| `lib/features/chat/presentation/widgets/day_divider.dart` | Centred grey pill between messages ("Today", "Connected 3 days ago"). | Feature chat · presentation | `DayDivider` |
| `lib/features/chat/presentation/widgets/message_composer.dart` | Chat composer (artboard 18): photo button, 44 px pill field and the round brand send button. | Feature chat · presentation | `MessageComposer` |
| `lib/features/connections/bloc/connect_request_cubit.dart` | Sends a connection request with an optional note (Connect sheet). | Feature connections · bloc | `ConnectRequestCubit` |
| `lib/features/connections/bloc/connect_request_state.dart` | Connect sheet: the optional note and the send status. | Feature connections · bloc | `ConnectRequestState` |
| `lib/features/connections/bloc/connections_cubit.dart` | My connections: lists, accept / decline, remove, cancel and block. | Feature connections · bloc | `ConnectionsCubit` |
| `lib/features/connections/bloc/connections_state.dart` | My connections (artboard 16): Connected / Requests / Sent. | Feature connections · bloc | `ConnectionsTab`, `ConnectionsState` |
| `lib/features/connections/logic/connect_note_rules.dart` | The optional note sent with a connection request. | Feature connections · logic | `ConnectNoteRules` |
| `lib/features/connections/presentation/connect_sheet.dart` | 15 Connect sheet: who you are connecting with, an optional note (200 characters) and Send request / Cancel. | Feature connections · presentation | `ConnectSheet` |
| `lib/features/connections/presentation/connections_screen.dart` | 16 My connections: Connected / Requests / Sent. | Feature connections · presentation | `ConnectionsScreen` |
| `lib/features/connections/presentation/widgets/request_tile.dart` | Received connection request: avatar, name, subtitle, the optional note and Accept / Decline (My connections → Requests). | Feature connections · presentation | `RequestTile` |
| `lib/features/discover/bloc/discover_cubit.dart` | Loads the visible teachers (student viewer) or students (teacher viewer) and applies search and filters through [TeacherFilter] /… | Feature discover · bloc | `DiscoverCubit` |
| `lib/features/discover/bloc/discover_state.dart` | Teachers tab (student viewer) or Students tab (teacher viewer). | Feature discover · bloc | `DiscoverStatus`, `DiscoverState` |
| `lib/features/discover/bloc/public_profile_cubit.dart` | Someone else's profile: details, connection state, counts and block. | Feature discover · bloc | `PublicProfileCubit` |
| `lib/features/discover/bloc/public_profile_state.dart` | Public profile (artboards 14 / 14b). | Feature discover · bloc | `PublicProfileState` |
| `lib/features/discover/bloc/search_cubit.dart` | Searches people (through the list filters) and posts (body and tag). | Feature discover · bloc | `SearchCubit` |
| `lib/features/discover/bloc/search_state.dart` | Home search results (artboard 08b): All / Teachers (or Students) / Posts. | Feature discover · bloc | `SearchTab`, `SearchState` |
| `lib/features/discover/logic/daily_shuffle.dart` | Random list order, stable per viewer per day (PHASE_006). | Feature discover · logic | `DailyShuffle` |
| `lib/features/discover/logic/student_filter.dart` | Search and filters for the Students tab (teacher view). Pure value: [apply] filters a list (no sort). | Feature discover · logic | `StudentFilter` |
| `lib/features/discover/logic/teacher_filter.dart` | Search and filters for the Teachers tab (student view). Pure value: [apply] filters a list (no sort). | Feature discover · logic | `TeacherFilter` |
| `lib/features/discover/presentation/discover_screen.dart` | 11 Teachers (student viewer) / 12 Students (teacher viewer): search, filter sheet, filter chips and the list. | Feature discover · presentation | `DiscoverScreen` |
| `lib/features/discover/presentation/public_profile_screen.dart` | 14 Public profile (teacher) / 14b Public profile (student). | Feature discover · presentation | `PublicProfileScreen` |
| `lib/features/discover/presentation/search_results_screen.dart` | 08b Home search results: All / Teachers (Students for teachers) / Posts. | Feature discover · presentation | `SearchResultsScreen` |
| `lib/features/discover/presentation/student_filter_sheet.dart` | 13b Student filter sheet: subject wanted, student gender, language, country, level, learner age group and sort, with a live result count. | Feature discover · presentation | `StudentFilterSheet` |
| `lib/features/discover/presentation/teacher_filter_sheet.dart` | 13 Filter sheet (Teachers): subject, teacher gender, language, monthly fee, experience and "Teaches children", with a live result count. | Feature discover · presentation | `TeacherFilterSheet` |
| `lib/features/discover/presentation/widgets/fee_range_slider.dart` | Two-thumb fee slider from the filter sheet (artboard 13): 4 px track, brand active range and 24 px white thumbs with a 2 px brand ring.… | Feature discover · presentation | `FeeRangeSlider` |
| `lib/features/discover/presentation/widgets/filter_chips_bar.dart` | Horizontal row of 36 px filter chips under the search field (artboards 11 / 12): active filters first, then quick suggestions. | Feature discover · presentation | `FilterChipItem`, `FilterChipsBar` |
| `lib/features/discover/presentation/widgets/person_row.dart` | List row with a 48 px avatar, name, one-line subtitle, an optional gold [detail] line (e.g. the fee) and a [trailing] action; 1 px… | Feature discover · presentation | `PersonRow` |
| `lib/features/discover/presentation/widgets/student_card.dart` | Student card on the Students tab (artboard 12): initials avatar (photos are never shown here), name, age group / gender, "Looking" pill,… | Feature discover · presentation | `StudentCard` |
| `lib/features/discover/presentation/widgets/teacher_card.dart` | Teacher card on the Teachers tab (artboard 11): avatar, name, headline, subject / language / audience chips, location, experience, fee,… | Feature discover · presentation | `TeacherCard` |
| `lib/features/feed/bloc/feed_cubit.dart` | Home feed: ordered posts (repository order) minus blocked authors, with their author profiles. | Feature feed · bloc | `FeedCubit` |
| `lib/features/feed/bloc/feed_state.dart` | — | Feature feed · bloc | `FeedStatus`, `FeedState` |
| `lib/features/feed/bloc/post_detail_cubit.dart` | One post with its comments; like, comment and comment-like actions. | Feature feed · bloc | `PostDetailCubit` |
| `lib/features/feed/bloc/post_detail_state.dart` | — | Feature feed · bloc | `PostDetailStatus`, `PostDetailState` |
| `lib/features/feed/logic/feed_ordering.dart` | Feed order (plan section 9): posts from the viewer's connections first, newest first, then everyone else's posts, newest first. | Feature feed · logic | `FeedOrdering` |
| `lib/features/feed/presentation/home_screen.dart` | 08 Home: top bar, profile-strength card, and the feed (connections first, then everyone, newest first). | Feature feed · presentation | `HomeScreen` |
| `lib/features/feed/presentation/post_detail_screen.dart` | 09 Post detail: the full post, its comments and the comment composer. | Feature feed · presentation | `PostDetailScreen` |
| `lib/features/feed/presentation/widgets/comment_composer.dart` | Bottom composer on post detail: user avatar, pill field "Write a comment…" and a 44 px brand send button. | Feature feed · presentation | `CommentComposer` |
| `lib/features/feed/presentation/widgets/comment_tile.dart` | Comment: 36 px avatar, white bubble (4 px top-start corner, 14 px others) with name and text, then "1h · Like · Reply". | Feature feed · presentation | `CommentTile` |
| `lib/features/feed/presentation/widgets/home_top_bar.dart` | Home's 64 px top bar: the user's 40 px avatar (→ My profile) and the pill search field "Search teachers, posts, subjects". | Feature feed · presentation | `HomeTopBar` |
| `lib/features/notifications/bloc/notifications_cubit.dart` | Notifications with Accept / Decline on requests and Mark all read. | Feature notifications · bloc | `NotificationsCubit` |
| `lib/features/notifications/bloc/notifications_state.dart` | 19 Notifications: New (unread) and Earlier (read). | Feature notifications · bloc | `NotificationsState` |
| `lib/features/notifications/presentation/notifications_screen.dart` | 19 Notifications: New / Earlier, Accept / Decline, Mark all read. | Feature notifications · presentation | `NotificationsScreen` |
| `lib/features/notifications/presentation/widgets/notification_tile.dart` | Notification row (artboard 19): 48 px [leading], rich [message], relative time and an optional [footer] (request note and buttons).… | Feature notifications · presentation | `NotificationTile` |
| `lib/features/notifications/presentation/widgets/request_notification_tile.dart` | Footer of a connection-request notification: the quoted note in a white box, then Accept / Decline while the request is open. | Feature notifications · presentation | `RequestNotificationTile` |
| `lib/features/onboarding/bloc/welcome_cubit.dart` | Tracks the visible Welcome slide. | Feature onboarding · bloc | `WelcomeCubit` |
| `lib/features/onboarding/bloc/welcome_state.dart` | — | Feature onboarding · bloc | `WelcomeState` |
| `lib/features/onboarding/presentation/splash_screen.dart` | 01 Splash: brand green, logo, "Asatiza" wordmark and the tagline. After a short pause it continues to Home (the router sends signed-out… | Feature onboarding · presentation | `SplashScreen` |
| `lib/features/onboarding/presentation/welcome_screen.dart` | 02 / 02b / 02c Welcome: three swipeable slides, Skip, and the two account buttons. | Feature onboarding · presentation | `WelcomeScreen` |
| `lib/features/onboarding/presentation/widgets/page_dots.dart` | Slide indicator: the current slide is a 24×8 brand pill, others are 8×8 line-coloured dots. | Feature onboarding · presentation | `PageDots` |
| `lib/features/onboarding/presentation/widgets/welcome_slide.dart` | One Welcome slide: 330 px illustration card (24 px radius), then the Fraunces title and the supporting line. | Feature onboarding · presentation | `WelcomeSlide` |
| `lib/features/post/bloc/create_post_cubit.dart` | New post: text (max 1,500), one optional photo, one required tag. | Feature post · bloc | `CreatePostCubit` |
| `lib/features/post/bloc/create_post_state.dart` | — | Feature post · bloc | `CreatePostStatus`, `CreatePostState` |
| `lib/features/post/logic/post_rules.dart` | Post limits (plan section 9). | Feature post · logic | `PostRules` |
| `lib/features/post/presentation/create_post_screen.dart` | 10 Create post: text (max 1,500), one photo, one required tag and the content-policy note. | Feature post · presentation | `CreatePostScreen` |
| `lib/features/profile/bloc/certificate_viewer_cubit.dart` | Downloads the own certificate for the viewer; `retry`. | Feature profile · bloc | `CertificateViewerCubit` |
| `lib/features/profile/bloc/certificate_viewer_state.dart` | Loading / loaded (bytes in memory) / failure. | Feature profile · bloc | `CertificateViewerStatus`, `CertificateViewerState` |
| `lib/features/profile/bloc/edit_profile_cubit.dart` | Edits a draft of the user's profile; [save] writes it through [ProfileRepository] (role, verification and id are never changed). | Feature profile · bloc | `EditProfileCubit` |
| `lib/features/profile/bloc/edit_profile_state.dart` | 20b / 20d Edit profile: a draft copy saved on "Save". | Feature profile · bloc | `EditProfileState` |
| `lib/features/profile/bloc/my_profile_cubit.dart` | The signed-in user's own profile, posts and connection count; the "Looking for a teacher" switch saves straight away. | Feature profile · bloc | `MyProfileCubit` |
| `lib/features/profile/bloc/my_profile_state.dart` | 20a / 20c My profile. | Feature profile · bloc | `MyProfileState` |
| `lib/features/profile/presentation/certificate_viewer_screen.dart` | In-app PDF viewer for the own certificate (`pdfrx`), page indicator, error + Try again. | Feature profile · presentation | `CertificateViewerScreen` |
| `lib/features/profile/presentation/edit_profile_screen.dart` | 20b Edit profile (student) / 20d Edit profile (teacher). | Feature profile · presentation | `EditProfileScreen` |
| `lib/features/profile/presentation/my_profile_screen.dart` | 20a My profile (student) / 20c My profile (teacher). | Feature profile · presentation | `MyProfileScreen` |
| `lib/features/profile/presentation/widgets/certificate_row.dart` | Uploaded certificate (Edit profile, teacher setup): document icon, original file name, remove; tap opens the viewer. | Feature profile · presentation | `CertificateRow` |
| `lib/features/profile_setup/bloc/student_setup_cubit.dart` | Student setup (artboards 07e, 07d, 07f). Each step is saved when the user continues or skips. | Feature profile_setup · bloc | `StudentSetupCubit` |
| `lib/features/profile_setup/bloc/student_setup_state.dart` | Three-step student setup over a draft copy of the user's profile. | Feature profile_setup · bloc | `StudentSetupState` |
| `lib/features/profile_setup/bloc/teacher_setup_cubit.dart` | Teacher setup (artboards 07a–07c). Every step is saved when the user continues or skips, so the strength % reflects it immediately. | Feature profile_setup · bloc | `TeacherSetupCubit` |
| `lib/features/profile_setup/bloc/teacher_setup_state.dart` | Three-step teacher setup over a draft copy of the user's profile. | Feature profile_setup · bloc | `TeacherSetupState` |
| `lib/features/profile_setup/presentation/student_setup_screen.dart` | 07e / 07d / 07f Student setup (skip-able): photo + learner age group; goals, level, languages; preferred teacher gender, "Looking for a… | Feature profile_setup · presentation | `StudentSetupScreen` |
| `lib/features/profile_setup/presentation/teacher_setup_screen.dart` | 07a–07c Teacher setup (skip-able): photo + headline; subjects, languages, gender, country, time zone; bio, experience, fee, days,… | Feature profile_setup · presentation | `TeacherSetupScreen` |
| `lib/features/profile_setup/presentation/widgets/photo_picker_tile.dart` | 96 px dashed brand circle with a camera, beside a title and hint. Once a photo is attached it shows the user's avatar with a check… | Feature profile_setup · presentation | `PhotoPickerTile` |
| `lib/features/profile_setup/presentation/widgets/upload_tile.dart` | Dashed brand row: upload icon, label and a hint on the end side ("Upload certificates · JPG or PDF"). (Mock phase: attaches a sample file.) | Feature profile_setup · presentation | `UploadTile` |
| `lib/features/profile_setup/presentation/widgets/weekday_picker.dart` | Seven 42 px day circles (M T W T F S S); selected days are brand filled. | Feature profile_setup · presentation | `WeekdayPicker` |
| `lib/features/safety/bloc/report_cubit.dart` | Report a post (anonymous), optionally blocking its author. | Feature safety · bloc | `ReportCubit` |
| `lib/features/safety/bloc/report_state.dart` | — | Feature safety · bloc | `ReportStatus`, `ReportState` |
| `lib/features/safety/presentation/report_sheet.dart` | 22 Report sheet: five reasons, "Also block" + author, Cancel / Report. | Feature safety · presentation | `ReportSheet` |
| `lib/features/settings/bloc/blocked_users_cubit.dart` | Lists the people the user blocked and unblocks them. | Feature settings · bloc | `BlockedUsersCubit` |
| `lib/features/settings/bloc/blocked_users_state.dart` | 21b Blocked users. | Feature settings · bloc | `BlockedUsersState` |
| `lib/features/settings/bloc/change_password_cubit.dart` | Change password with the three live rules from artboard 21a. | Feature settings · bloc | `ChangePasswordCubit` |
| `lib/features/settings/bloc/change_password_state.dart` | 21a Change password: fields, live rules and the save result. | Feature settings · bloc | `ChangePasswordState` |
| `lib/features/settings/bloc/delete_account_cubit.dart` | Deletes the account once the user ticks the confirmation box. | Feature settings · bloc | `DeleteAccountCubit` |
| `lib/features/settings/bloc/delete_account_state.dart` | 21f Delete account sheet. | Feature settings · bloc | `DeleteAccountState` |
| `lib/features/settings/bloc/settings_cubit.dart` | Settings: notification switches (saved on change). | Feature settings · bloc | `SettingsCubit` |
| `lib/features/settings/bloc/settings_state.dart` | 21 Settings. | Feature settings · bloc | `SettingsState` |
| `lib/features/settings/presentation/blocked_users_screen.dart` | 21b Blocked users (and its empty state). | Feature settings · presentation | `BlockedUsersScreen` |
| `lib/features/settings/presentation/change_password_screen.dart` | 21a Change password. | Feature settings · presentation | `ChangePasswordScreen` |
| `lib/features/settings/presentation/delete_account_sheet.dart` | 21f Delete account sheet: what is deleted, the "I understand" box and Cancel / Delete account. | Feature settings · presentation | `DeleteAccountSheet` |
| `lib/features/settings/presentation/log_out_sheet.dart` | — | Feature settings · presentation | `LogOutSheet` |
| `lib/features/settings/presentation/policy_screen.dart` | The three policy pages (artboards 21c / 21d / 21e). | Feature settings · presentation | `PolicyPage`, `PolicyScreen` |
| `lib/features/settings/presentation/settings_screen.dart` | 21 Settings: account, notification switches, privacy & safety, log out and delete account. | Feature settings · presentation | `SettingsScreen` |
| `lib/main.dart` | Composition root: the only place concrete repositories are created; Auth + Profile real, other repositories mock until their phases; the only `Supabase.instance` read. | App | `main` |
| `test/app_test.dart` | Tests | Test | `main` |
| `test/core/config/app_config_test.dart` | Tests | Test | `main` |
| `test/core/logic/certificate_file_rules_test.dart` | `CertificateFileRules` tests. | Test | — |
| `test/core/router/app_router_test.dart` | Tests | Test | `tapTab`, `main` |
| `test/core/theme/app_theme_test.dart` | Pins the theme to the Asatiza design-system tokens (tokens.json), so a drift between design and code shows up as a failing test. | Test | `main` |
| `test/core/widgets/app_avatar_test.dart` | `AppAvatar` photo, fallback, `showPhoto`, preview. | Test | — |
| `test/data/mock_data_test.dart` | Tests | Test | `main` |
| `test/core/logic/profile_completeness_rules_test.dart` | Tests | Test | `main` |
| `test/data/supabase/profile_row_mapper_test.dart` | Tests | Test | `main` |
| `test/data/supabase/supabase_block_repository_test.dart` | Tests | Test | `main` |
| `test/data/supabase/supabase_chat_repository_test.dart` | Tests | Test | `main` |
| `test/data/supabase/supabase_connection_repository_test.dart` | Tests | Test | `main` |
| `test/data/supabase/supabase_discover_repository_test.dart` | Tests | Test | `main` |
| `test/data/supabase/supabase_failure_mapper_test.dart` | Tests | Test | `main` |
| `test/features/chat_notifications_test.dart` | Tests | Test | `settle`, `main` |
| `test/features/cubits_test.dart` | Lets stream listeners and async cubit work run. | Test | `settle`, `main` |
| `test/features/discover_connect_test.dart` | Tests | Test | `settle`, `main` |
| `test/features/logic_rules_test.dart` | Tests | Test | `main` |
| `test/features/media_upload_cubits_test.dart` | Photo / certificate uploads in setup and Edit profile cubits; certificate viewer cubit. | Test | — |
| `test/features/profile_settings_test.dart` | Tests | Test | `settle`, `main` |
| `test/features/screens_test.dart` | Tests | Test | `main` |
| `test/fakes/fake_block_repository.dart` | Test-only in-memory [BlockRepository] (block code moved from `MockSafetyRepository`, PHASE_007). | Test fake | `FakeBlockRepository` |
| `test/fakes/mock_chat_repository.dart` | In-memory [ChatRepository] (resets on restart). Chat is allowed only between accepted connections of [MockConnectionRepository]. Test-only (moved from `lib/` in PHASE_009). | Test fake | `MockChatRepository` |
| `test/fakes/mock_connection_repository.dart` | In-memory [ConnectionRepository]; since PHASE_008 only the sample connections behind the still-mock chat (moves to `test/fakes/` with the Chat phase). Test-only (moved from `lib/` in PHASE_009). | Test fake | `MockConnectionRepository` |
| `test/fakes/mock_profile_repository.dart` | In-memory [ProfileRepository] seeded with [buildMockProfiles]. State resets when the app restarts. Test-only (moved from `lib/` in PHASE_009). | Test fake | `MockProfileRepository` |
| `test/fakes/mock_auth_repository.dart` | In-memory [AuthRepository]. Any valid email + 8-character password signs in; any 6 digits are a valid code. Known emails (the two mock… Test-only (moved from `lib/` in PHASE_007). | Test fake | `MockAuthRepository` |
| `test/fakes/mock_discover_repository.dart` | In-memory [DiscoverRepository] over the mock profiles and blocks. Test-only (moved from `lib/` in PHASE_007). | Test fake | `MockDiscoverRepository` |
| `test/fakes/mock_media_repository.dart` | In-memory [MediaRepository] for tests (`failNext`, `deleted`). Test-only (moved from `lib/` in PHASE_007). | Test fake | `MockMediaRepository` |
| `test/helpers/test_app.dart` | The app wired with fresh mock repositories, as in `main.dart`. | Test | `TestApp`, `enterField`, `enterCode`, `tapText`, `loadDesignFonts` |

`supabase/` and `integration_test/` do not exist yet.
