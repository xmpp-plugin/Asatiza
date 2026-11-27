# PHASE_010_FEED_ADD_SUPABASE_FEED_POSTS_LIKES_COMMENTS_REPORTS — Feed: real posts, likes, comments and reports

## Identity

- Phase ID: PHASE_010_FEED_ADD_SUPABASE_FEED_POSTS_LIKES_COMMENTS_REPORTS
- Phase title: Feed — real posts, likes, comments, reports and auto-hide on Supabase
- File name: PHASE_010_FEED_ADD_SUPABASE_FEED_POSTS_LIKES_COMMENTS_REPORTS.md
- Module: FEED
- Priority: High
- Risk level: High (5 tables, RLS, database functions and triggers, moderation rule (auto-hide at 3 reports — protected), a public Storage bucket, 2 repository interfaces and a service interface extended, 2 shared model changes, new UI actions, mock moves)
- Current status: ACTIVE
- Current step: MANUAL_TEST
- Approval: APPROVED
- Outcome: NONE
- Version: 1.0
- Created date: 2026-11-27
- Last updated date: 2026-11-27
- Started date: 2026-11-27
- Completed date: Not completed
- Developer owner: Developer (owner) — VERIFIED (PHASE_001 decision)
- Dependency phases: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES (closed), PHASE_007_SAFETY_ADD_SUPABASE_BLOCKS (closed), PHASE_008_CONNECTIONS_ADD_SUPABASE_CONNECTIONS (closed), PHASE_009_CHAT_ADD_SUPABASE_REALTIME_CHAT_WITH_PHOTOS (closed)

## Requirement

- Original developer request: "Accept recommendation and create phase properly" for the Feed phase (recommendations 1–8 of the previous answer).
- Business objective: members share Islamic posts in a moderated feed (plan sections 3.6–3.8, 4 "Post", 9 "Feed rules and moderation", 12 `posts` / `post_likes` / `post_comments` / `reports` / `post-images`).
- Expected outcome: Home, Create post, Post detail, likes, comments, reports and deleting your own posts / comments work on real Supabase data; the database enforces limits, blocks and auto-hide.
- Acceptance criteria:
  1. Create a post: text up to 1,500 characters, one tag, optional photo (compressed, public `post-images` bucket), optional Arabic verse; at most **10 posts per person in any 24 hours**.
  2. Home feed: posts from **your connections first** (newest first), then everyone else's (newest first); **20 at a time**, more load while scrolling; pull-to-refresh.
  3. Like / unlike posts and comments; counts are correct for everyone.
  4. Comments: add (at most **100 per person in any 24 hours**), list oldest first; delete your own comment.
  5. Delete your own post (its likes, comments, reports and photo go with it).
  6. Report a post or a comment (reasons: spam, inappropriate, hate / harassment, false information, something else); reporting the same item twice does nothing; a post reported by **3 different people** is hidden automatically.
  7. A hidden post disappears for everyone except its author, who sees it with "Under review"; the admin un-hides or deletes it in the Supabase dashboard.
  8. Blocked people's posts and comments are hidden both ways.
  9. Search finds real posts (body and tag) on the server; profiles show the person's real posts / count.
  10. Account deletion removes the user's posts, likes, comments, reports and photos.
  11. Mocks follow the PHASE_007 rule (feed and reports mocks move to `test/fakes/`).

## Decisions (DECIDED 2026-11-27 — developer: "Accept recommendation")

1. **Comment likes kept** — table `comment_likes` (not in the plan's table list; the app already has the ❤ on comments).
2. **Arabic verse kept** — optional `posts.arabic_verse` column (≤ 300 characters).
3. **Photo compression** — new `ImageCompressor.compressPhoto` (~1280 px on the longer side, ~200 KB JPEG, plan section 9) used by posts **and chat** (chat switches from the avatar setting; closes the PHASE_009 limitation).
4. **Paging** — 20 posts per page, more on scroll, pull-to-refresh; no Realtime for the feed.
5. **Reports** — posts and comments now; profile reports later with admin tools.
6. **Own hidden post** — visible to its author with "Under review"; hidden for everyone else.
7. **Comment limit** — 100 per person in any 24 hours, with a clear message (new `ValidationReason.dailyCommentLimit`).
8. **Admin review** — in the Supabase dashboard (un-hide = set `is_hidden = false`, or delete the post); no admin app in v1.0.

## Analysis

- Current behavior (VERIFIED): `lib/main.dart` wires `MockFeedRepository()` and `MockSafetyRepository()` (reports only). Posts are sample data; `CreatePostCubit.photoAdded()` attaches a sample SVG (`sampleAttachment`); there is **no delete action** for posts or comments in the UI; `ReportSheet` reports posts only; profiles and search filter the full in-memory `watchPosts` list by author / text.
- Root cause / gap: no feed tables, functions, bucket or Supabase implementation; the contract has no paging, delete, posts-by-author or server search.
- End-to-end flow (traced, VERIFIED):
  - Home: `HomeScreen` → `FeedCubit` (`FeedRepository.watchPosts`, `ProfileRepository.getProfiles` for authors, `BlockRepository.watchBlockedIds` filter, `toggleLike`) → `PostCard`.
  - Post detail: `PostDetailScreen` → `PostDetailCubit` (`watchPost`, `watchComments`, `toggleLike`, `toggleCommentLike`, `addComment`) → `ReportSheet` → `ReportCubit` (`SafetyRepository.reportPost` + `BlockRepository.blockUser`).
  - Create: `CreatePostScreen` → `CreatePostCubit` (`PostRules`, `createPost`).
  - My profile: `MyProfileCubit` → `watchPosts` filtered to own posts. Public profile: `PublicProfileCubit` → `watchPosts` count by author. Search: `SearchCubit` → `watchPosts` filtered by text / tag.
  - Server (proposed): tables + RLS (read-only for the app) → functions → triggers (counts, auto-hide) → Storage `post-images`.
- Relevant files: `lib/data/repositories/{feed_repository,safety_repository,media_repository}.dart`, `mock/mock_feed_repository.dart`, `mock/mock_safety_repository.dart`, `lib/data/models/{post,comment}.dart`, `enums/{post_tag,report_reason,media_bucket}.dart`, `lib/core/services/{image_compressor,flutter_image_compress_image_compressor}.dart`, `lib/features/feed/{bloc,logic,presentation}/*`, `lib/features/post/*`, `lib/features/safety/*`, `lib/features/profile/bloc/my_profile_cubit.dart`, `lib/features/discover/bloc/{public_profile_cubit,search_cubit}.dart`, `lib/features/chat/bloc/chat_cubit.dart`, `lib/core/widgets/post_card.dart`, `lib/main.dart`.
- Existing reusable components (VERIFIED): `Post` / `Comment` models, `PostTag`, `ReportReason`, `PostRules` (1,500 / 10 per day), `FeedOrdering` (connections first — mirrored by the SQL), `PostCard`, `PostCardSkeleton`, `ReportSheet` + `ReportCubit`, `PhotoSourceSheet`, `ImagePickerService`, `ImageCompressor`, `MediaRepository` / `SupabaseMediaRepository`, `SupabaseFailureMapper`, `private.pair_blocked`, `private.pair_connected` (PHASE_009), `ConfirmSheet` (delete confirmation), `EmptyStateView`.
- API details: PostgREST + Storage via `supabase_flutter`; no Realtime, Dio or Edge Function.
- Platform: camera / gallery permissions from PHASE_005; no native change.
- Lifecycle: feed streams re-subscribe on refresh / load-more; cubits cancel subscriptions in `close()`.
- Supabase (proposed, plan section 12):
  - `posts (id, author_id, body ≤ 1,500, tag, arabic_verse ≤ 300, image_path, like_count, comment_count, report_count, is_hidden, created_at)`.
  - `post_likes (post_id, user_id, created_at)`, `post_comments (id, post_id, author_id, body ≤ 1,000, like_count, created_at)`, `comment_likes (comment_id, user_id, created_at)`.
  - `reports (id, reporter_id, target_type post|comment, target_id, reason, status open|reviewed, created_at)`, unique per reporter + target.
  - RLS: select posts that are not hidden (or are your own), whose author is not blocked either way; likes / comments of visible posts; reports only your own. No direct writes.
  - Functions (security definer): `create_post`, `delete_post`, `toggle_post_like`, `add_comment`, `delete_comment`, `toggle_comment_like`, `report_content`, `list_feed(p_limit, p_offset)` (connections first, then newest; `liked_by_me`), `list_posts_by(p_author, p_limit)`, `search_posts(p_query, p_limit)`.
  - Triggers: like / comment counters; auto-hide when 3 distinct reporters report a post.
  - Storage: public bucket `post-images` (JPEG, 1 MB); path `<user-id>/post_<n>.jpg`; owner uploads / deletes in their own folder; public read (plan).
- Both roles: same for teachers and students (anyone with a confirmed email can post — plan section 7).
- Security: functions use `auth.uid()`; `is_hidden` and `report_count` are never writable by the app; report details are visible only to the reporter (and the admin in the dashboard).

## Scope

- In scope: the migration and a rolled-back check script; `SupabaseFeedRepository`; `SupabaseSafetyRepository` (reports); `ImageCompressor.compressPhoto` + its Flutter implementation; `MediaRepository.uploadPostImage` + `MediaBucket.postImages`; contract additions; model fields; new reason; cubit and screen changes listed below; delete actions (own post, own comment) with a confirmation sheet; "Under review" label; report on comments; infinite scroll + pull-to-refresh on Home; `main.dart` wiring; mock moves; tests; docs.
- Explicitly out of scope: notifications and push for likes / comments (Notifications phase), profile reports, editing posts / comments, more than one photo, video, Realtime feed, ranking beyond the plan's order, admin app, dependencies, native changes.
- API contract changes (approval required):
  - `FeedRepository.watchPosts({viewerId, int limit})` (limit added; the cubit asks for more pages), `watchPostsBy({authorId, viewerId})`, `searchPosts({query, viewerId})`, `deletePost({postId, userId})`, `deleteComment({commentId, userId})`; `addComment` may throw `dailyCommentLimit`.
  - `SafetyRepository.reportComment({commentId, reporterId, reason})`.
  - `MediaRepository.uploadPostImage(String userId, Uint8List jpegBytes)`; `MediaBucket.postImages`.
  - `ImageCompressor.compressPhoto(Uint8List bytes)`.
  - `Post.imageUrl` (public URL, display only) and `Post.isUnderReview` (author view of a hidden post) — shared model changes.
  - `ValidationReason.dailyCommentLimit`.
- Files expected to change:
  - Data / services: `lib/data/repositories/{feed_repository,safety_repository,media_repository}.dart`, `lib/data/models/post.dart`, `lib/data/models/enums/media_bucket.dart`, `lib/data/repositories/supabase/supabase_media_repository.dart`, `lib/core/services/{image_compressor,flutter_image_compress_image_compressor}.dart`, `lib/core/errors/failures.dart`, `lib/main.dart`
  - Feed: `lib/features/feed/bloc/{feed_cubit,feed_state,post_detail_cubit,post_detail_state}.dart`, `lib/features/feed/presentation/{home_screen,post_detail_screen}.dart`, `lib/features/feed/logic/feed_ordering.dart` (doc: mirrored by SQL)
  - Post: `lib/features/post/bloc/{create_post_cubit,create_post_state}.dart`, `lib/features/post/presentation/create_post_screen.dart`
  - Safety: `lib/features/safety/bloc/{report_cubit,report_state}.dart`, `lib/features/safety/presentation/report_sheet.dart`
  - Others: `lib/core/widgets/post_card.dart` (network photo, Under review), `lib/features/profile/bloc/my_profile_cubit.dart`, `lib/features/discover/bloc/{public_profile_cubit,search_cubit}.dart`, `lib/features/chat/bloc/chat_cubit.dart` (`compressPhoto`)
  - `lib/l10n/app_en.arb` + generated
  - Moves (renames): `lib/data/repositories/mock/{mock_feed_repository,mock_safety_repository}.dart` → `test/fakes/`
  - Tests: helpers, every test using the feed / safety mocks or the changed cubits, new repository tests
  - Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `COMMON_COMPONENTS` (PostCard), `FILE_CATALOG`, `KNOWN_ISSUES`; phase / state / index
- Files that must not change: product plans, earlier migrations, auth / profile / discover / blocks / connections / chat repositories (except chat cubit's compression call), native files, `pubspec.yaml`.
- Proposed new files (approval required):
  - `supabase/migrations/20261202120000_feed.sql`
  - `supabase/tests/feed_rls_checks.sql`
  - `lib/data/repositories/supabase/supabase_feed_repository.dart` — `SupabaseFeedRepository`
  - `lib/data/repositories/supabase/supabase_safety_repository.dart` — `SupabaseSafetyRepository` (reports)
  - `test/data/supabase/supabase_feed_repository_test.dart` (row / error mapping, no network)
- Proposed new classes: `SupabaseFeedRepository`, `SupabaseSafetyRepository` (constructors: `SupabaseClient`, `SupabaseFailureMapper`; contracts = their interfaces; throw only `*Failure`).
- Dependency / native changes: None (`flutter_image_compress` already present).
- Supabase changes: tables, RLS, functions, triggers, Storage bucket + policies (approval required; the developer applies them).

## Readiness Checklist

- [x] Requirement is clear
- [x] Expected behavior is clear
- [x] Existing flow is traced
- [x] API is verified
- [x] Request contract is verified
- [x] Response contract is verified
- [x] Supabase tables, RLS and Storage policies are defined
- [x] Security, 18+ gate and moderation rules are unaffected or approved (auto-hide at 3 reports implements the plan's rule; final approval at Approve Phase)
- [x] Required UI/design is available (existing feed artboards; delete menu items, "Under review" label and comment report are small deviations reusing `ConfirmSheet` / `ReportSheet`)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood
- [x] Permissions are understood
- [x] Dependencies are available
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed
- [x] Developer approval is recorded

## Risks

- Moderation rule (auto-hide at 3 distinct reporters) is protected — covered by the check script; un-hiding is an admin action only.
- Public `post-images` bucket: photos are readable by anyone with the link (plan decision for posts); chat photos stay private.
- Counters by trigger must stay correct under concurrent likes — counted from the like tables, not incremented blindly.
- Offset paging can repeat / skip a post when new posts arrive while scrolling — acceptable for v1.0 (pull-to-refresh resets).
- Several contracts change at once; every implementation and fake must follow.
- Remote migration must be applied before the new build.

## Test Plan

- Automated: repository row / error mapping; `FeedCubit` paging and refresh; `CreatePostCubit` photo flow (fake picker / compressor / media) and limits; `PostDetailCubit` delete post / comment, comment limit; `ReportCubit` for comments; `PostCard` "Under review"; search and profile posts through the new methods; chat uses `compressPhoto`.
- SQL (developer, `feed_rls_checks.sql`, rolled back, works with the two existing profiles): create post OK; > 1,500 refused; 11th post in 24 h refused; like / unlike counts; comment add / 101st refused / delete own only; delete own post only; direct writes refused; report twice = one report; 3 distinct reporters hide a post (simulated reporters inserted as the owner inside the transaction); author still sees own hidden post, others do not; block hides posts both ways; storage upload only in own folder; anon has no access.
- Manual (two phones): post with and without photo; feed order (connection's post above others); scroll loads more; like / comment on each other's posts; delete own comment and post; report; block hides posts; search finds a post; profiles show posts.

## Rollback Plan

- App: revert the phase commit (mocks back to `lib/`, sample feed).
- Database: the migration's rollback section drops the functions, triggers, tables and `post-images` policies (empty the bucket first in the dashboard). Feed data is lost (it did not exist before).

## Implementation

- Approved implementation plan: Approved 2026-11-27 (developer: "Approve phase"). Covers decisions 1–8 and the Scope section: migration `20261202120000_feed.sql` (posts, post_likes, post_comments, comment_likes, reports; RLS; create / delete post, likes, add / delete comment, report, list_feed, list_posts_by, search_posts; counter and auto-hide triggers; public `post-images` bucket + policies; rollback notes); `supabase/tests/feed_rls_checks.sql`; `SupabaseFeedRepository`, `SupabaseSafetyRepository`, `test/data/supabase/supabase_feed_repository_test.dart`; the listed contract additions (`FeedRepository` paging / by author / search / delete, `SafetyRepository.reportComment`, `MediaRepository.uploadPostImage`, `MediaBucket.postImages`, `ImageCompressor.compressPhoto`); `Post.imageUrl`, `Post.isUnderReview`; `ValidationReason.dailyCommentLimit`; the listed cubit / screen / widget changes (paging, photo flow, delete actions, Under review, comment report, chat `compressPhoto`); `main.dart`; feed and reports mocks moved to `test/fakes/`; tests; docs. Not approved: notifications / push, profile reports, editing, multiple photos, video, Realtime feed, admin app, dependencies, native changes.
- Implementation log: 2026-11-27 — implemented the approved scope. See Change Log.
- Exact changed files: see Change Log
- Purpose of every changed file: see Change Log
- Existing components reused: listed in Analysis
- New approved components: migration `20261202120000_feed.sql`, `feed_rls_checks.sql`, `SupabaseFeedRepository`, `SupabaseSafetyRepository`, `supabase_feed_repository_test.dart`, the listed contract additions, `Post.imageUrl` / `isUnderReview`, `dailyCommentLimit`
- Deviations from the plan (recorded):
  - `MediaRepository.uploadPostImage` only (no separate public-URL method): the feed repository builds the public URL itself from the post path.
  - `SearchCubit` lost its `tagLabel` parameter (search runs on the server; tags match by their database words, e.g. "tajweed tip").
  - The create-post photo preview got a placeholder `errorBuilder` (an undecodable image no longer throws).
  - `lib/features/feed/logic/feed_ordering.dart` was not edited: `list_feed` mirrors it and the test fake still uses it.
  - `list_feed` allows up to 500 posts per request (paging grows the limit by 20).
- Out-of-scope findings:
  - Notifications for likes / comments and push: Notifications phase.
  - Profile reports and an admin app: later.
- Unexpected risks: None

## Change Log

| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |
|---|---|---|---|---|---|---|---|
| `supabase/migrations/20261202120000_feed.sql` | added | Yes | 5 tables, indexes, select-only RLS, `private.can_see_post`, 3 counter triggers + auto-hide trigger, 7 write functions, 3 list functions, public `post-images` bucket + 2 policies, rollback notes | Real feed with server rules | — | Needs the migration before the build | Not run against a database (no CLI) |
| `supabase/tests/feed_rls_checks.sql` | added | Yes | 22 rolled-back checks with the two existing profiles (direct insert, create / empty / long / tag / foreign photo, feed, like / unlike, comment, report once, delete-other comment, 2 reports keep visible, 3-reporter hide (SKIPPED without a third profile), author sees hidden, search, 10-post limit, 100-comment limit, block hides, delete other / own post, anon) | Verify rules | — | None (rolled back) | Not run (developer) |
| `lib/data/repositories/supabase/supabase_feed_repository.dart` | added | Yes | RPC writes / lists, RLS reads, tag mapping, public photo URLs, rule-message mapping, photo removal on delete | Real feed | — | No Realtime (refresh) | `supabase_feed_repository_test.dart` |
| `lib/data/repositories/supabase/supabase_safety_repository.dart` | added | Yes | `report_content` for posts and comments; reason mapping | Real reports | — | — | `supabase_feed_repository_test.dart` |
| `lib/data/repositories/{feed_repository,safety_repository,media_repository}.dart` | modified | Yes | Contract additions and wording | Approved contract changes | Existing signatures kept (watchPosts gained an optional `limit`) | Every implementation / fake updated | analyze |
| `lib/data/models/post.dart`, `lib/data/models/enums/media_bucket.dart` | modified | Yes | `imageUrl`, `isUnderReview`; `MediaBucket.postImages` | Photos, Under review | Other fields unchanged | Equality includes the new fields | tests |
| `lib/data/repositories/supabase/supabase_media_repository.dart` | modified | Yes | `uploadPostImage` (own folder) | Post photos | Other uploads unchanged; `deleteAllUserFiles` now also clears post photos | — | analyze |
| `lib/core/services/{image_compressor,flutter_image_compress_image_compressor}.dart` | modified | Yes | `compressPhoto` (1280 px, quality 75); shared `_compress` | Decision 3 | `compressAvatar` unchanged | — | analyze |
| `lib/core/errors/failures.dart` | modified | Yes | `dailyCommentLimit` | Decision 7 | — | — | analyze |
| `lib/features/feed/bloc/{feed_cubit,feed_state}.dart`, `presentation/home_screen.dart` | modified | Yes | Paging (`loadMore`, `refresh`, `canLoadMore`), pull-to-refresh, scroll trigger, loading row, delete own post from the card | Decision 4, acceptance 5 | Ordering, block filter, likes unchanged | — | cubits_test, screens_test |
| `lib/features/feed/bloc/{post_detail_cubit,post_detail_state}.dart`, `presentation/post_detail_screen.dart`, `widgets/comment_tile.dart` | modified | Yes | Delete own post / comment with confirmation; report comments; error snackbar (comment limit) | Acceptance 4–6 | Like / comment flows unchanged | — | tests |
| `lib/features/post/bloc/{create_post_cubit,create_post_state}.dart`, `presentation/create_post_screen.dart` | modified | Yes | Real photo: picker → `compressPhoto` → `uploadPostImage`, preview, orphan clean-up; sample attachment removed | Acceptance 1 | Text / tag rules unchanged | Unposted photos deleted on close | cubits_test, screens_test |
| `lib/features/safety/bloc/report_cubit.dart`, `presentation/report_sheet.dart` | modified | Yes | Optional `commentId`; comment title / message | Decision 5 | Post reports unchanged | — | tests |
| `lib/core/widgets/post_card.dart` | modified | Yes | Network photo with placeholder, asset fallback; "Under review" line | Decisions 3, 6 | Layout unchanged | — | tests |
| `lib/features/profile/bloc/my_profile_cubit.dart`, `lib/features/discover/bloc/public_profile_cubit.dart` | modified | Yes | `watchPostsBy` | Paging-safe profiles | — | — | tests |
| `lib/features/discover/bloc/search_cubit.dart`, `presentation/search_results_screen.dart` | modified | Yes | Server `searchPosts`; `tagLabel` removed | Paging-safe search | People search unchanged | — | tests |
| `lib/features/chat/bloc/chat_cubit.dart` | modified | Yes | `compressPhoto` for chat photos | Decision 3 | — | Larger chat photos (~200 KB) | chat tests |
| `lib/main.dart` | modified | Yes | `SupabaseFeedRepository`, `SupabaseSafetyRepository`; doc comment | Wiring | Other repositories unchanged | Needs the migration | analyze |
| `lib/l10n/app_en.arb` + 2 generated | modified | Yes | 9 strings (delete, report comment, Under review, comment limit) | UI text | — | — | gen-l10n |
| `lib/data/repositories/mock/{mock_feed,mock_safety}_repository.dart` → `test/fakes/` | renamed (`git mv`, staged) | Yes | Package imports; new methods (paging, by author, search, delete, comment limit, reportComment) | Decision / PHASE_007 rule | Sample behaviour unchanged | — | tests |
| Tests: `test/fakes/mock_media_repository.dart`, `test/helpers/test_app.dart`, `test/data/mock_data_test.dart`, `test/features/{cubits,profile_settings,screens}_test.dart`; added `test/data/supabase/supabase_feed_repository_test.dart` | modified / added | Yes | Fakes (`uploadPostImage`, `compressPhoto`); create-post test uses a real pick; screen test picks from the gallery sheet; mapping tests | Cover the change | — | — | `flutter test` |
| Docs: `DATABASE_AND_CACHE`, `API_REFERENCE`, `ARCHITECTURE`, `COMMON_COMPONENTS`, `FILE_CATALOG`, `KNOWN_ISSUES`; phase / state / index | modified | Yes | PHASE_010 facts and limitations | Required docs | — | — | `validate_phase_structure.sh` |

Pre-existing uncommitted changes at the start: PHASE_010 phase docs only.

## Execute Technical Checks

- Changed-file evidence reviewed after changes: `git status --short` after implementation — exactly the files above (2 renames staged by `git mv`)
- Git status/diff rerun reason: baseline at start; once after implementation
- Patch/whitespace check result, when run: Not run
- Relevant Dart formatting: `dart format lib test` — clean
- Scoped or project analysis commands: `flutter analyze` — No issues found (2 list-syntax slips and 1 unused import fixed during execution)
- Relevant targeted tests: `flutter test` (full) — 171/171 passed (5 new; the create-post test and screen test updated for the real photo flow)
- Newly introduced issues found: create-post preview threw on undecodable test bytes; 2 syntax slips; 1 unused import
- Newly introduced issues fixed: all (preview `errorBuilder`)
- Pre-existing unrelated issues: None recorded
- Commands that could not run and why: migration and `feed_rls_checks.sql` not run (no Supabase CLI or project link; developer applies them); app not launched; iOS not built (Windows)

## Manual Testing

- Ready for developer manual testing: Yes (2026-11-27). First apply `supabase/migrations/20261202120000_feed.sql` and run `supabase/tests/feed_rls_checks.sql` (all PASS; 14–15 SKIPPED with two profiles); then follow the Manual tests on two phones.
- Developer manual-test confirmation: Not provided
- Manual-test notes requested by developer: None

## Closure

- Developer manual-test confirmation: Not provided
- Tested platforms: Not provided
- Tested devices: Not provided
- Failed and retested cases: None recorded
- Known limitations: None recorded
- Follow-up phases: Notifications
- Reused Execute technical evidence at closure: Not evaluated
- Rollback guidance: see Rollback Plan
- Final status: Not closed
- Completion date: Not completed
