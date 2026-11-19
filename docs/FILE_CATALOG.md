# File Catalog

Every project-owned file under `lib/` and `test/`. Generated and tool files are not catalogued (`lib/l10n/app_localizations*.dart` come from `flutter gen-l10n`). Assets: `assets/fonts/` (PHASE_001), `assets/icons/` (42 design icons), `assets/illustrations/` (6), `assets/images/` (2 logos) — PHASE_002.

Last audit: 2026-11-19 (`PHASE_002_UI_ADD_FULL_APP_DESIGN_MOCK_DATA`).

| Path | Purpose | Layer | Public types / functions |
|---|---|---|---|
| `lib/app.dart` | Root widget: light/dark theme from the design tokens (following the phone setting), English localization and the session-aware router.… | App | `AsatizaApp` |
| `lib/core/errors/failures.dart` | Base type for every error a repository may throw. No raw exception (Postgrest, Auth, Dio…) leaves a repository. | Core errors | `Failure`, `ValidationFailure`, `ValidationReason`, `NotFoundFailure`, `UnexpectedFailure` |
| `lib/core/logic/profile_strength_calculator.dart` | Checklist items behind the profile-strength %, in the order the strength card suggests them. | Core logic | `ProfileStrengthItem`, `ProfileStrengthCalculator` |
| `lib/core/router/app_router.dart` | Builds the app's route table, redirecting on the [session]: - signed out → only Splash and the sign-in screens; - signed in right after… | Core router | `createAppRouter` |
| `lib/core/router/app_routes.dart` | Route paths, signed-out set, `setupFor(role)` | Core router | `AppRoutes` |
| `lib/core/session/session_cubit.dart` | App-wide session. Every launch starts signed out (mock data resets). Keeps the signed-in user's profile fresh after edits. | Core session | `SessionCubit` |
| `lib/core/session/session_state.dart` | Who is signed in, and whether they still see profile setup. | Core session | `SessionState` |
| `lib/core/theme/app_colors.dart` | Color tokens of the Asatiza design system (owner's design canvas, `project/ds/asatiza/tokens.json`), one set per brightness. Read in… | Core theme | `AppColors` |
| `lib/core/theme/app_radius.dart` | Radius tokens + artboard radii (4, 6, 9, 10, 14, 20) | Core theme | `AppRadius` |
| `lib/core/theme/app_shadows.dart` | `shadow-card` / `shadow-raised` per brightness | Core theme | `AppShadows` |
| `lib/core/theme/app_spacing.dart` | Spacing tokens + artboard gaps (2, 6, 10, 14, 18, 22) | Core theme | `AppSpacing` |
| `lib/core/theme/app_text_styles.dart` | Type scale + artboard styles (splash 44, auth 28/34, body 15/22, helper 13/18…) | Core theme | `AppTextStyles` |
| `lib/core/theme/app_theme.dart` | Light and dark Material 3 themes from the tokens | Core theme | `AppTheme` |
| `lib/core/utils/relative_time_formatter.dart` | Short relative times as in the design: "now", "20m", "2h", "Yesterday", "Mon", "12 Nov". | Core utils | `RelativeTimeFormatter` |
| `lib/core/widgets/app_avatar.dart` | Initials avatar on a token tint (the design shows no photos). The tint is picked from the profile id so a person keeps the same colour… | Core widgets | `AppAvatar` |
| `lib/core/widgets/app_bottom_sheet.dart` | The design's bottom sheet: white, 24 px top corners, raised shadow, 40×4 grabber, 20 px side padding, over the scrim colour. | Core widgets | `AppBottomSheet` |
| `lib/core/widgets/app_button.dart` | The design's buttons: primary (brand fill), secondary (white with brand outline) and danger. A null [onPressed] shows the disabled style… | Core widgets | `AppButtonVariant`, `AppButtonSize`, `AppButton` |
| `lib/core/widgets/app_checkbox.dart` | 22 px checkbox (6 px radius) with a label beside it; the whole row is tappable. Checked = brand fill with a white check. | Core widgets | `AppCheckbox` |
| `lib/core/widgets/app_chip.dart` | 36 px selectable pill: surface-200 when off; brand-100 fill, brand outline and a check icon when on. | Core widgets | `AppChip` |
| `lib/core/widgets/app_icon.dart` | A design icon from `assets/icons/` (24×24 stroke icons exported from the design canvas). [color] fills `currentColor`; [strokeWidth] and… | Core widgets | `AppIcon` |
| `lib/core/widgets/app_text_area.dart` | Multi-line field with an optional label above and a "n / max" counter below on the end side (bio, notes). | Core widgets | `AppTextArea` |
| `lib/core/widgets/app_text_field.dart` | The design's 48 px input: label above, white field with a 1 px line border that becomes a 2 px brand border while focused, optional… | Core widgets | `AppTextField` |
| `lib/core/widgets/back_header.dart` | 56 px header with a 44 px back (or close) button, an optional page title (18/24 bold) and optional trailing widgets. | Core widgets | `BackHeader` |
| `lib/core/widgets/empty_state_view.dart` | Empty state: icon in a 52 px brand-100 circle, title, one line of text and an optional small action button (artboard "23 Empty states"). | Core widgets | `EmptyStateView` |
| `lib/core/widgets/main_shell.dart` | App shell with the designed bottom bar: Home · Teachers · raised centre "+" · Chats · Alerts. Tab screens are the [navigationShell]… | Core widgets | `MainShell` |
| `lib/core/widgets/numbered_stepper.dart` | "① Email — ② Code — ③ New password": done and current steps are brand filled circles, later steps are outlined. | Core widgets | `NumberedStepper` |
| `lib/core/widgets/otp_input.dart` | Six 48×58 digit boxes (10 px radius). One hidden text field takes the input, so paste and SMS/email autofill work; the next empty box… | Core widgets | `OtpInput` |
| `lib/core/widgets/post_card.dart` | Feed post card: author row, text (4 lines in the feed), optional Arabic verse and photo, tag + counts, and Like / Comment / Report actions. | Core widgets | `PostCard` |
| `lib/core/widgets/post_card_skeleton.dart` | Loading version of a post card (artboard "24 Loading states"). | Core widgets | `PostCardSkeleton` |
| `lib/core/widgets/profile_strength_card.dart` | Brand-tinted card: "Your profile is n% complete", a hint for the next missing item, an 8 px progress bar, "Complete profile" and steps left. | Core widgets | `ProfileStrengthCard` |
| `lib/core/widgets/section_label.dart` | Section heading (15/20, bold) with optional trailing text, e.g. "Choose a tag … Required" or "Available days … 5:00–9:00 pm". | Core widgets | `SectionLabel` |
| `lib/core/widgets/skeleton_box.dart` | A surface-200 placeholder block for loading states. | Core widgets | `SkeletonBox` |
| `lib/core/widgets/step_progress_header.dart` | Profile-setup header: optional back button, "Step n of total" centred, "Skip for now" on the end side, and one 6 px bar per step below. | Core widgets | `StepProgressHeader` |
| `lib/core/widgets/tag_chip.dart` | 24 px post tag label: brand tint, or gold tint for achievements and class announcements. | Core widgets | `TagChip` |
| `lib/core/widgets/verified_badge.dart` | Gold circle with a dark check: the "Verified teacher" badge. | Core widgets | `VerifiedBadge` |
| `lib/data/mock/mock_posts.dart` | 14 seed posts, created relative to [now]. `commentCount` is filled from [buildMockComments] by the repository. | Mock data | `MockPostSeed`, `MockImages`, `buildMockPosts`, `buildMockComments` |
| `lib/data/mock/mock_profiles.dart` | The signed-in user's connections, used for feed order. | Mock data | `MockIds`, `MockAccounts`, `mockConnectedIds`, `buildMockProfiles` |
| `lib/data/models/comment.dart` | A comment on a post (plan table `post_comments`). | Model / enum | `Comment` |
| `lib/data/models/enums/fee_unit.dart` | Fee per class / per month | Model / enum | `FeeUnit`, `FeeUnitLabel` |
| `lib/data/models/enums/gender.dart` | Male / female | Model / enum | `Gender`, `GenderLabel` |
| `lib/data/models/enums/learner_age_group.dart` | Age group of the learner on a student account. | Model / enum | `LearnerAgeGroup`, `LearnerAgeGroupLabel` |
| `lib/data/models/enums/learner_level.dart` | Current reading level of a learner. | Model / enum | `LearnerLevel`, `LearnerLevelLabel` |
| `lib/data/models/enums/post_tag.dart` | The one tag every post carries (plan section 4). | Model / enum | `PostTag`, `PostTagLabel` |
| `lib/data/models/enums/report_reason.dart` | Report reasons (plan section 9). | Model / enum | `ReportReason`, `ReportReasonLabel` |
| `lib/data/models/enums/subject.dart` | Quran-learning subjects (plan section 7). | Model / enum | `Subject`, `SubjectLabel` |
| `lib/data/models/enums/teacher_gender_preference.dart` | A student's preferred teacher gender. | Model / enum | `TeacherGenderPreference`, `TeacherGenderPreferenceLabel` |
| `lib/data/models/enums/teaches_audience.dart` | Who a teacher teaches (plan section 7). | Model / enum | `TeachesAudience`, `TeachesAudienceLabel` |
| `lib/data/models/enums/teaching_language.dart` | Languages a teacher teaches in or a student speaks. | Model / enum | `TeachingLanguage`, `TeachingLanguageLabel` |
| `lib/data/models/enums/user_role.dart` | Account role, chosen at sign-up (one per account). | Model / enum | `UserRole`, `UserRoleLabel` |
| `lib/data/models/enums/weekday.dart` | Days of the week, Monday first, as in the availability picker. | Model / enum | `Weekday`, `WeekdayLabel` |
| `lib/data/models/post.dart` | A feed post (plan table `posts`), as seen by one viewer. | Model / enum | `Post` |
| `lib/data/models/profile.dart` | A user's public profile (plan table `profiles`). Exactly one of [teacherDetails] / [studentDetails] matches [role]. | Model / enum | `Profile`, `on` |
| `lib/data/models/student_details.dart` | Student-only profile data (plan table `student_details`). | Model / enum | `StudentDetails` |
| `lib/data/models/teacher_details.dart` | Teacher-only profile data (plan table `teacher_details`). | Model / enum | `TeacherDetails` |
| `lib/data/repositories/auth_repository.dart` | Sign up, code, log in, password reset (provisional contract) | Repository interface | `AuthRepository` |
| `lib/data/repositories/feed_repository.dart` | Posts, likes, comments in feed order (provisional contract) | Repository interface | `FeedRepository` |
| `lib/data/repositories/mock/mock_auth_repository.dart` | In-memory [AuthRepository]. Any valid email + 8-character password signs in; any 6 digits are a valid code. Known emails (the two mock… | Mock data | `MockAuthRepository` |
| `lib/data/repositories/mock/mock_feed_repository.dart` | In-memory [FeedRepository] seeded with [buildMockPosts] and [buildMockComments]. State resets when the app restarts. | Mock data | `MockFeedRepository` |
| `lib/data/repositories/mock/mock_profile_repository.dart` | In-memory [ProfileRepository] seeded with [buildMockProfiles]. State resets when the app restarts. | Mock data | `MockProfileRepository` |
| `lib/data/repositories/mock/mock_safety_repository.dart` | In-memory [SafetyRepository]. Reports are kept for the session only. | Mock data | `MockSafetyRepository` |
| `lib/data/repositories/profile_repository.dart` | Read/update profiles (provisional contract) | Repository interface | `ProfileRepository` |
| `lib/data/repositories/safety_repository.dart` | Reports and blocks (provisional contract) | Repository interface | `SafetyRepository` |
| `lib/features/auth/bloc/login_cubit.dart` | Email + password log-in (no code at log-in, plan section 4). | Feature auth · bloc | `LoginCubit` |
| `lib/features/auth/bloc/login_state.dart` | Log-in form state | Feature auth · bloc | `LoginStatus`, `LoginState` |
| `lib/features/auth/bloc/otp_cubit.dart` | 6-digit email code: auto-verifies when complete, runs the 60 s resend countdown (cancelled in [close]). | Feature auth · bloc | `OtpCubit` |
| `lib/features/auth/bloc/otp_state.dart` | Why the code was sent. | Feature auth · bloc | `OtpPurpose`, `OtpStatus`, `OtpState` |
| `lib/features/auth/bloc/password_reset_cubit.dart` | Forgot password: step 1 sends the code, step 3 saves the new password and signs in. (Step 2, the code, uses [OtpCubit].) | Feature auth · bloc | `PasswordResetCubit` |
| `lib/features/auth/bloc/password_reset_state.dart` | Forgot-password email step and new-password step. | Feature auth · bloc | `PasswordResetStatus`, `PasswordResetState` |
| `lib/features/auth/bloc/sign_up_cubit.dart` | Sign-up form. On success the screen opens the email-code step. | Feature auth · bloc | `SignUpCubit` |
| `lib/features/auth/bloc/sign_up_state.dart` | Sign-up form state (18+ consent) | Feature auth · bloc | `SignUpStatus`, `SignUpState` |
| `lib/features/auth/logic/otp_rules.dart` | Email-code rules (plan section 4). | Feature auth · logic | `OtpRules` |
| `lib/features/auth/logic/password_rules.dart` | Password and email rules used by sign-up, log-in and password reset. | Feature auth · logic | `PasswordRules` |
| `lib/features/auth/presentation/email_code_screen.dart` | 04 Email code after sign-up: 6 boxes (auto-verify), resend timer, "Wrong email? Change it" and the spam-folder note. | Feature auth · presentation | `EmailCodeScreen` |
| `lib/features/auth/presentation/forgot_password_screen.dart` | 06 / 06a Forgot password: step 1 (email) and step 2 (code). Step 3 is [NewPasswordScreen]. | Feature auth · presentation | `ForgotPasswordScreen` |
| `lib/features/auth/presentation/log_in_screen.dart` | 05 Log in: email + password only (no code at log-in). | Feature auth · presentation | `LogInScreen` |
| `lib/features/auth/presentation/new_password_screen.dart` | 06b New password (step 3 of 3): two fields, live rule checks, then "Save and log in". | Feature auth · presentation | `NewPasswordScreen` |
| `lib/features/auth/presentation/sign_up_screen.dart` | 03 Sign up: role, name, email, password and the 18+ / Terms consent. | Feature auth · presentation | `SignUpScreen` |
| `lib/features/auth/presentation/widgets/info_note.dart` | Quiet surface-200 note with an 18 px icon, e.g. "Can’t find it? Check your Spam folder…" on the email-code screen. | Feature auth · presentation | `InfoNote` |
| `lib/features/auth/presentation/widgets/role_card.dart` | Sign-up role card ("I am a Student / Teacher"): icon, title, one line. | Feature auth · presentation | `RoleCard` |
| `lib/features/chat/presentation/chats_screen.dart` | Chats tab placeholder with the designed title header. The chat list and search come with the chat phase. | Feature chat · presentation | `ChatsScreen` |
| `lib/features/discover/presentation/discover_screen.dart` | Teachers tab placeholder with the designed title header. Search, filters and the role-aware Students view come with the discover phase. | Feature discover · presentation | `DiscoverScreen` |
| `lib/features/feed/bloc/feed_cubit.dart` | Home feed: ordered posts (repository order) minus blocked authors, with their author profiles. | Feature feed · bloc | `FeedCubit` |
| `lib/features/feed/bloc/feed_state.dart` | Feed posts + authors state | Feature feed · bloc | `FeedStatus`, `FeedState` |
| `lib/features/feed/bloc/post_detail_cubit.dart` | One post with its comments; like, comment and comment-like actions. | Feature feed · bloc | `PostDetailCubit` |
| `lib/features/feed/bloc/post_detail_state.dart` | Post detail + comments state | Feature feed · bloc | `PostDetailStatus`, `PostDetailState` |
| `lib/features/feed/logic/feed_ordering.dart` | Feed order (plan section 9): posts from the viewer's connections first, newest first, then everyone else's posts, newest first. | Feature feed · logic | `FeedOrdering` |
| `lib/features/feed/presentation/home_screen.dart` | 08 Home: top bar, profile-strength card, and the feed (connections first, then everyone, newest first). | Feature feed · presentation | `HomeScreen` |
| `lib/features/feed/presentation/post_detail_screen.dart` | 09 Post detail: the full post, its comments and the comment composer. | Feature feed · presentation | `PostDetailScreen` |
| `lib/features/feed/presentation/widgets/comment_composer.dart` | Bottom composer on post detail: user avatar, pill field "Write a comment…" and a 44 px brand send button. | Feature feed · presentation | `CommentComposer` |
| `lib/features/feed/presentation/widgets/comment_tile.dart` | Comment: 36 px avatar, white bubble (4 px top-start corner, 14 px others) with name and text, then "1h · Like · Reply". | Feature feed · presentation | `CommentTile` |
| `lib/features/feed/presentation/widgets/home_top_bar.dart` | Home's 64 px top bar: the user's 40 px avatar (→ My profile) and the pill search field "Search teachers, posts, subjects". | Feature feed · presentation | `HomeTopBar` |
| `lib/features/notifications/presentation/notifications_screen.dart` | Alerts tab placeholder titled "Notifications", as in the design. The list and "Mark all read" come with the notifications phase. | Feature notifications · presentation | `NotificationsScreen` |
| `lib/features/onboarding/bloc/welcome_cubit.dart` | Tracks the visible Welcome slide. | Feature onboarding · bloc | `WelcomeCubit` |
| `lib/features/onboarding/bloc/welcome_state.dart` | Visible Welcome slide | Feature onboarding · bloc | `WelcomeState` |
| `lib/features/onboarding/presentation/splash_screen.dart` | 01 Splash: brand green, logo, "Asatiza" wordmark and the tagline. After a short pause it continues to Home (the router sends signed-out… | Feature onboarding · presentation | `SplashScreen` |
| `lib/features/onboarding/presentation/welcome_screen.dart` | 02 / 02b / 02c Welcome: three swipeable slides, Skip, and the two account buttons. | Feature onboarding · presentation | `WelcomeScreen` |
| `lib/features/onboarding/presentation/widgets/page_dots.dart` | Slide indicator: the current slide is a 24×8 brand pill, others are 8×8 line-coloured dots. | Feature onboarding · presentation | `PageDots` |
| `lib/features/onboarding/presentation/widgets/welcome_slide.dart` | One Welcome slide: 330 px illustration card (24 px radius), then the Fraunces title and the supporting line. | Feature onboarding · presentation | `WelcomeSlide` |
| `lib/features/post/bloc/create_post_cubit.dart` | New post: text (max 1,500), one optional photo, one required tag. | Feature post · bloc | `CreatePostCubit` |
| `lib/features/post/bloc/create_post_state.dart` | New post form state | Feature post · bloc | `CreatePostStatus`, `CreatePostState` |
| `lib/features/post/logic/post_rules.dart` | Post limits (plan section 9). | Feature post · logic | `PostRules` |
| `lib/features/post/presentation/create_post_screen.dart` | 10 Create post: text (max 1,500), one photo, one required tag and the content-policy note. | Feature post · presentation | `CreatePostScreen` |
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
| `lib/features/safety/bloc/report_state.dart` | Report reason + also-block state | Feature safety · bloc | `ReportStatus`, `ReportState` |
| `lib/features/safety/presentation/report_sheet.dart` | 22 Report sheet: five reasons, "Also block" + author, Cancel / Report. | Feature safety · presentation | `ReportSheet` |
| `lib/main.dart` | Composition root: the only place concrete repositories are created. UI-only phase: in-memory mock implementations (reset on restart).… | App entry | `main` |
| `test/app_test.dart` | Tests | Test | `main` |
| `test/core/logic/profile_strength_calculator_test.dart` | Tests | Test | `main` |
| `test/core/router/app_router_test.dart` | Tests | Test | `tapTab`, `main` |
| `test/core/theme/app_theme_test.dart` | Pins the theme to the Asatiza design-system tokens (tokens.json), so a drift between design and code shows up as a failing test. | Test | `main` |
| `test/data/mock_data_test.dart` | Tests | Test | `main` |
| `test/features/cubits_test.dart` | Lets stream listeners and async cubit work run. | Test | `settle`, `main` |
| `test/features/logic_rules_test.dart` | Tests | Test | `main` |
| `test/features/screens_test.dart` | Tests | Test | `main` |
| `test/helpers/test_app.dart` | The app wired with fresh mock repositories, as in `main.dart`. | Test | `TestApp`, `enterField`, `enterCode`, `tapText`, `loadDesignFonts` |

`supabase/` and `integration_test/` do not exist yet.
