# PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES — Backend: Storage For Profile Photos And Certificates

## Identity

- Phase ID: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES
- Phase title: Supabase Storage — profile photos and teacher certificates (PDF only, in-app viewer)
- File name: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES.md
- Module: BACKEND
- Priority: High
- Risk level: High (4 new production dependencies with native setup, including a PDF viewer, Storage buckets and policies, a new repository interface, 3 new service interfaces, a shared model change, a shared core widget change, the account-deletion flow, iOS `Info.plist` changes)
- Current status: CLOSED
- Current step: CLOSURE
- Approval: APPROVED
- Outcome: COMPLETED
- Version: 1.0
- Created date: 2026-11-24
- Last updated date: 2026-11-24 (closed)
- Started date: 2026-11-24
- Completed date: 2026-11-24
- Developer owner: Repository owner (developer). They are also the manual tester.
- Dependency phases: PHASE_004_BACKEND_ADD_SUPABASE_AUTH_PROFILES (closed)

## Requirement

- Follow-up 2026-11-24: "Accept recommendations" — the 9 recommended answers are recorded under Decisions; they become binding only with `APPROVE PHASE`.
- Follow-up 2026-11-24 (developer): "continue with pdf only not link … pdf size maximum 3 mb and also we added the view pdf as well in this phase … properly". Certificate links were considered and rejected (privacy, broken or changed links, reviewer safety). The limit changed to 3 MB, and decision 6 changed to an in-app PDF viewer.
- Follow-up 2026-11-24 (developer): "allow only 1 certificate per teacher, later we allow multiple because we use limited Supabase storage, we extend it in v2 or later; also show certificate instruction". Decision 2 changed and decision 10 added.
- Original developer request (2026-11-24): "CREATE PHASE … create the phase about above suggest properly also the certificate only containe pdf file only". The "above suggestion" was: Storage for profile photos and certificates, replacing placeholder paths. The developer also said the PHASE_004 work is committed and pushed, and the exposed keys were already handled. Both items are recorded as done by the developer and are not part of this phase.
- Business objective: Real profile photos and real teacher certificates stored in Supabase Storage (plan section 7, 12: "avatars, post photos, certificates"; strength meter photo 15 % and certificate 10 %; teacher verification later reviews certificates). DECIDED
- Expected outcome: Users pick a real photo, which is compressed and uploaded to the `avatars` bucket. Every avatar in the app shows the photo instead of initials, except where the plan hides student photos. Teachers upload **one** PDF certificate to the private `certificates` bucket (more in v2 or later), with on-screen instructions. `photo_path` and `certificate_paths` hold real Storage paths. Account deletion also removes the user's files.
- Acceptance criteria (approved 2026-11-24):
  1. Photo: Setup step 1 (teacher and student) and Edit profile "Change photo" open the Camera / Gallery chooser (decision 1). The image is compressed to JPEG ≈ 60 KB, about 512 px on the longest side (plan section 13: "avatars ~60 KB") and uploaded to `avatars/<user-id>/…`. The tile shows the new photo. After saving, `profiles.photo_path` holds the path.
  2. Avatars: `AppAvatar` shows the photo when the profile has one. It falls back to initials while loading, on error, or when no photo exists. Student photos never appear in the Students list or in search results (plan sections 14, 16; decision 5).
  3. Certificates: Teacher setup step 3 and Edit profile "Upload certificate" open a **PDF-only** file picker. Only `application/pdf` is accepted, max 3 MB, and **only 1 certificate per teacher** (decision 2). The file is uploaded to `certificates/<user-id>/…` and appears with its original file name. While a certificate exists, the upload tile is hidden. To change it the teacher removes it and uploads another; the old file is deleted after save (decision 3). Remove deletes the file and its path.
  3b. View: tapping the uploaded certificate (teacher setup step 3 and Edit profile) opens an in-app PDF viewer screen. The screen downloads the file from the private bucket with the user's session (owner-only policy). It shows a loading state, then the pages (scroll, pinch-zoom, a "2 / 5" page indicator). A failure shows an error with Retry. The bytes stay in memory only: nothing is written to disk, and no public or signed URL is used. Only the owner can view in this phase (decision 6).
  3a. Instructions: an `AppInfoNote` with the certificate instructions is shown under the certificate section in teacher setup step 3 and in Edit profile (decision 10).
  4. The hint text "JPG or PDF" becomes "PDF". Other file types are refused by the picker (PDF filter) and by the bucket (`allowed_mime_types`). The client also checks the first bytes (`%PDF-`).
  5. Storage policies: a user can upload, replace and delete only files under their own `<user-id>/` folder. Only teachers can upload certificates. Avatars are public-read as the plan says (decision 4). Certificates are readable only by their owner (the admin review is a later phase). Buckets limit file size and MIME type on the server.
  6. Strength meter: the photo (15) and certificate (10) items count real uploads. The existing server trigger and `ProfileStrengthCalculator` stay unchanged (they already check non-empty `photo_path` / `certificate_paths`).
  7. Delete account removes the user's files in `avatars` and `certificates` before the auth user is deleted (see "Account deletion and Storage" below).
  8. Upload errors (no connection, file too large, wrong type, server error) show a clear message and keep the screen usable. The button or tile shows the loading state while uploading.
  9. Old placeholder paths saved during PHASE_004 testing (`avatars/<id>/profile.jpg`, `certificates/<id>/certificate-1.pdf`) do not crash anything. The avatar falls back to initials, and the developer clears them before testing (decision 8).
  10. `flutter analyze` is clean. New logic and mapping are unit-tested, cubits are tested with fake services and repository, and all existing tests stay green.
  11. Nothing is deployed to the remote Supabase project by me. The developer applies the migration in the SQL editor, as in PHASE_004 decision 7.

## Analysis

### Current Behavior (VERIFIED, branch `PHASE_004_BACKEND_FOUNDATION`, commit `2955fd7`)

- **Photo (setup):** `PhotoPickerTile` (`lib/features/profile_setup/presentation/widgets/photo_picker_tile.dart`, "Mock phase: no camera or gallery access") calls `StudentSetupCubit.photoAdded()` / `TeacherSetupCubit.photoAdded()`. These set the fake path `avatars/<id>/profile.jpg`, which `_save()` → `ProfileRepository.updateProfile` writes to `profiles.photo_path`.
- **Photo (edit):** `EditProfileCubit.photoChanged()` sets the fake path `avatars/<id>.jpg` (note: a different pattern from setup).
- **Certificates:** `TeacherSetupCubit.certificateAdded()` and `EditProfileCubit.certificateAdded()` append the fake path `certificates/<id>/certificate-N.pdf`. `EditProfileCubit.certificateRemoved(path)` only removes it from the list. `UploadTile` ("Mock phase: attaches a sample file") is the button. `CertificateRow` shows `path.split('/').last`. The hint string `uploadCertificatesHint` = "JPG or PDF".
- **Display:** `AppAvatar` (`lib/core/widgets/app_avatar.dart`) always draws initials ("the design shows no photos"). It is used in about 18 places (post card, profile header, chat, discover cards, notifications, top bar, setup, edit, my profile).
- **Data:** `Profile.photoPath` (`String?`) and `TeacherDetails.certificatePaths` (`List<String>`) exist. `ProfileRowMapper` maps `photo_path` ↔ `photoPath` and `certificate_paths` ↔ `certificatePaths`. `profiles.photo_path` is in the app's column `update` grant, and `teacher_details` is updatable by its owner.
- **Server strength:** the `profiles.sql` trigger counts `photo_path` (15) and `certificate_paths` (10). No change is needed.
- **Storage:** no buckets, no Storage policies, no `MediaRepository`, no `lib/core/services/` folder, no picker or compression packages. The `delete_my_account()` header says: "Later phases add … their Storage clean-up here."
- **Native:** Android has only `INTERNET`. iOS `Info.plist` has no `NSPhotoLibraryUsageDescription` / `NSCameraUsageDescription`. The iOS deployment target is 13.0, and Android uses Flutter's default `minSdk`.
- **Effect seen by the developer in PHASE_004 testing:** a teacher reached 85 % because "no photo attached". Users can't really attach one today.

### Root Cause / Gap

The UI and the data columns were built for uploads, but there is no Storage backend, no picker or compressor, and no repository to move files. The paths are invented strings.

### End-To-End Flow (target)

- **Photo:** `PhotoPickerTile` / "Change photo" → cubit `photoPicked()` → `ImagePickerService.pickImage(source)` (bytes or `null` if cancelled) → `ImageCompressor.compressAvatar(bytes)` (JPEG bytes) → `MediaRepository.uploadAvatar(userId, bytes)` → `SupabaseMediaRepository` → `client.storage.from('avatars').uploadBinary('<uid>/avatar-<timestamp>.jpg', …, contentType image/jpeg)` → Storage policy on `storage.objects` → the returned path is put in `draft.photoPath` → existing Save / Next → `ProfileRepository.updateProfile` → `profiles.photo_path` (RLS from PHASE_004) → strength trigger.
- **Display:** `SupabaseProfileRepository` maps `photo_path` → the new `Profile.photoUrl` through `client.storage.from('avatars').getPublicUrl(path)` (decision 4) → `AppAvatar` → `Image.network(photoUrl)` in the circle with an initials fallback.
- **Certificate:** `UploadTile` → cubit `certificatePicked()` → `DocumentPickerService.pickPdf()` (bytes + file name, or `null`) → `CertificateFileRules.check(bytes, name)` (size, `%PDF-` header, max 1) → `MediaRepository.uploadCertificate(userId, bytes, fileName)` → `certificates/<uid>/<timestamp>-<safe-name>.pdf` (contentType `application/pdf`) → policy (owner folder, role teacher) → path added to `draft.teacherDetails.certificatePaths` → Save / Next → `teacher_details.certificate_paths`.
- **View certificate:** `CertificateRow` tap → `context.push(AppRoutes.certificate(path))` → `CertificateViewerScreen` creates `CertificateViewerCubit(MediaRepository, path)` → `MediaRepository.downloadCertificate(path)` → `client.storage.from('certificates').download(path)` (authenticated request; `select` policy: owner folder) → bytes → state `loaded` → `PdfViewer` from bytes (`pdfrx`). Failure → `NetworkFailure` / `NotFoundFailure` / `UnexpectedFailure` → error view + Retry. The viewer package is imported only in the viewer screen file (it is a UI widget, not a platform service; see Platform).
- **Remove certificate:** cubit `certificateRemoved(path)` → path removed from the draft → after a successful save → `MediaRepository.deleteFiles(certificates, [path])` (decision 3).
- **Delete account:** `DeleteAccountCubit` → `AuthRepository.deleteAccount(userId)` → `SupabaseAuthRepository` first calls `MediaRepository.deleteAllMyFiles(userId)` (lists `<uid>/` in both buckets and removes them), then `rpc('delete_my_account')`.

### Account Deletion And Storage

- Supabase does not allow deleting Storage files with SQL (`delete from storage.objects`). A protection trigger blocks it, and the Storage API must be used. UNVERIFIED on this project (Supabase platform behaviour), but this phase does not depend on it.
- Recommended: the app removes the user's own files through the Storage API (owner policy allows it) just before `rpc('delete_my_account')`. If file removal fails, deletion stops and shows the error, so the account is never deleted while leaving files behind silently. No Edge Function and no Dio. If removal fails after a partial delete, the remaining files are orphans the developer can delete in the dashboard. This is recorded in Risks.
- `delete_my_account()` is not edited: editing an applied migration is forbidden by `docs/DIRECTORY_STRUCTURE.md`.

### Supabase Contract (proposed, one new migration)

- Buckets (inserted into `storage.buckets` by the migration):
  - `avatars`: `public` per decision 4 (plan: "public read"), `file_size_limit` 1 MB (headroom over ~60 KB), `allowed_mime_types` `{image/jpeg}`.
  - `certificates`: `public = false`, `file_size_limit` 3 MB (decision 2), `allowed_mime_types` `{application/pdf}`.
- Policies on `storage.objects` (folder = `(storage.foldername(name))[1]`):
  - avatars: `insert` / `update` / `delete` to `authenticated` where `bucket_id = 'avatars'` and folder = `auth.uid()::text`. `select`: public bucket reads need no policy for public URLs. A `select` policy for the owner is still needed for `list` (used by deletion).
  - certificates: `select` / `insert` / `update` / `delete` to `authenticated` where `bucket_id = 'certificates'` and folder = `auth.uid()::text`. `insert` also requires `exists (profiles where id = auth.uid() and role = 'teacher')`. No admin policy yet (admin phase), so the developer can view files in the dashboard.
- No table or column change: `photo_path` and `certificate_paths` already exist and are granted.
- Stored values: paths **inside** the bucket (`<uid>/avatar-<ts>.jpg`, `<uid>/<ts>-<name>.pdf`). The bucket is known from the column. This matches `API_REFERENCE.md` ("returns Storage paths").
- RLS checks: new `supabase/tests/storage_policies_checks.sql`, run as manual checks (as in PHASE_004): own folder insert OK, other folder denied, student certificate insert denied, anon insert denied, wrong MIME / size refused (bucket settings, checked from the app or dashboard).

### Models

- `Profile.photoUrl` (`String?`, new, display-only, never written to the database): filled by `SupabaseProfileRepository` from `photo_path`. It is `null` for mocks, so tests and sample people keep initials. **Shared model change: approval.**
  - Alternative (not recommended): `AppAvatar` reads `MediaRepository` from `context`. That couples a shared widget to a repository and breaks every widget test that has no provider.
- `TeacherDetails.certificatePaths` unchanged. The original file name is kept inside the path (`<ts>-<safe-name>.pdf`). `CertificateRow` shows the part after the first `-`. Old paths without a timestamp still show their whole file name.

### Design Against The SOLID Checklist

- S: `SupabaseMediaRepository` only moves files. `ImageCompressor` only compresses. `ImagePickerService` / `DocumentPickerService` only pick. `CertificateFileRules` (pure, `lib/core/logic/`) decides size, type and count (max 1). Cubits coordinate.
- O: services are added beside the existing code. Mocks stay. Screens change only their tap handlers and error text.
- L: `MockMediaRepository` honours the same contract (returns paths and throws only `*Failure`).
- I: `MediaRepository` is a separate small interface (already DECIDED in `CLASS_AND_COMPONENT_RULES.md`). Picking images and picking documents are separate interfaces because their callers differ.
- D: plugins are imported only by their `lib/core/services/<technology>_<name>.dart` implementation. Cubits receive interfaces by constructor. Concrete classes are created only in `lib/main.dart`.

### `MediaRepository` Contract (proposed, `lib/data/repositories/media_repository.dart`)

- `Future<String> uploadAvatar(String userId, Uint8List jpegBytes)` returns the new path. Throws `NetworkFailure`, `ValidationFailure(fileTooLarge | fileTypeNotAllowed)`, `UnexpectedFailure`.
- `Future<String> uploadCertificate(String userId, Uint8List pdfBytes, String fileName)` returns the new path. Same failures.
- `Future<Uint8List> downloadCertificate(String path)` → PDF bytes of the user's own certificate. Throws `NotFoundFailure` (missing or not allowed), `NetworkFailure`, `UnexpectedFailure`.
- `Future<void> deleteFiles(MediaBucket bucket, List<String> paths)`: missing files are ignored. Throws `NetworkFailure`, `UnexpectedFailure`.
- `Future<void> deleteAllUserFiles(String userId)`: avatars and certificates (later phases add post and chat images). Same failures.
- `MediaBucket` enum (`avatars`, `certificates`) in `lib/data/models/enums/media_bucket.dart`.
- Avatar URLs are resolved inside `SupabaseProfileRepository` (it already holds the client), not through `MediaRepository`, so `ProfileRepository` callers get display-ready profiles.

### Services (proposed, `lib/core/services/`; names already DECIDED in `CLASS_AND_COMPONENT_RULES.md` except the document picker)

- `ImagePickerService` → `Future<Uint8List?> pickImage(ImageSourceKind source)`. Implementation `ImagePickerImagePickerService`: file `image_picker_image_picker_service.dart`, per the `<technology>_<name>.dart` rule. The final class names are given at approval.
- `ImageCompressor` → `Future<Uint8List> compressAvatar(Uint8List bytes)`: JPEG, longest side 512, quality about 80, EXIF orientation applied. Implementation `FlutterImageCompressImageCompressor`.
- `DocumentPickerService` → `Future<PickedDocument?> pickPdf()`. Implementation `FilePickerDocumentPickerService` with `FileType.custom`, `allowedExtensions: ['pdf']`, `withData: true`. `PickedDocument` (bytes, name) model in `lib/data/models/picked_document.dart`.
- `ImageSourceKind` enum (`camera`, `gallery`) in `lib/core/services/image_source_kind.dart` (decision 1).

### Reusable Components (reuse first)

`PhotoPickerTile`, `UploadTile`, `CertificateRow`, `AppAvatar`, `AppBottomSheet` (camera / gallery chooser), `AppButton.loading`, `ConfirmSheet`, `ValidationReason` + `displayReason`, `NetworkFailure` / `UnexpectedFailure`, `SupabaseFailureMapper` (extended for `StorageException`), `ProfileRowMapper`, `ProfileStrengthCalculator` and the server trigger (unchanged), `AppInfoNote` (certificate instructions), the existing Save / Next flows, `MockProfileRepository` and other mocks. Nothing new is needed for layout. No new screen or route.

### Platform

- **Android:** `image_picker` uses the system Photo Picker (Android 13+) and the gallery intent below it, so no storage permission is needed. The camera uses `ACTION_IMAGE_CAPTURE`, and no `CAMERA` permission is needed because the app does not declare one. `file_picker` uses the system document picker (SAF) with no permission. Expected: **no manifest change**. UNVERIFIED until the first Android run; any needed change stops at `APPROVAL`. `minSdk` may need a raise if a package version requires it. Checked at execution, and any change stops for approval.
- **iOS:** `Info.plist` needs `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` (decision 1). **Native change: approval.** `file_picker` uses `UIDocumentPickerViewController` (no key). Pods are added on the developer's first iOS build. The iOS deployment target is 13.0. Package minimums are checked at execution, and a raise stops for approval.
- **PDF viewer:** `pdfrx` bundles PDFium native binaries, which adds app size per ABI on Android. The amount is UNVERIFIED and is measured at execution. No permission is needed. It is a UI widget package, so it is imported only in `certificate_viewer_screen.dart`, the same way `flutter_svg` is used in widgets. It is not a platform service and does not go behind `lib/core/services/`.
- **Lifecycle:** Android may kill the app while the camera is open. `image_picker.retrieveLostData()` handling is **not** added (recorded limitation: the user picks again). Cubits ignore results after `close()` (`isClosed` check).

### Both Roles / Signed Out

- Teacher: photo and one certificate. Student: photo only, and certificate upload is blocked by the policy. Student photos are hidden in the Students list.
- Signed out: no upload screens are reachable (router redirect). Anon cannot write to Storage, by policy.

### Security

- Private certificates: no public URL, never shown to other users. Only the owner sees file names. Avatar file names include a timestamp (they are not guessable from the user id alone), but with a public bucket anyone holding the URL can open it (decision 4).
- Paths are always built in the repository from `userId` (never from user input). The file name is sanitised to `[a-z0-9._-]`, 60 characters max.
- No secrets. The app keeps using only the public key. The service-role key is never used.

## Scope

- In scope: Storage buckets and policies (migration and checks), `MediaRepository` + Supabase + mock, 3 service interfaces + implementations, 4 packages, `Profile.photoUrl`, `AppAvatar` photo display, setup and edit-profile photo and certificate flows, PDF-only rule, certificate removal, in-app PDF viewer (owner only), cleanup on account deletion, upload loading and errors, iOS usage descriptions, tests, docs.
- Explicitly out of scope: post images (`post-images`) and chat images (`chat-images`) (feed and chat phases), admin certificate review and `is_verified` (admin phase), viewing another person's certificate (admin phase), downloading / sharing / printing the PDF, photo cropping UI, `retrieveLostData`, image caching packages (`cached_network_image`), Edge Functions, Dio, deploying anything remotely, discover / connections / chat on Supabase.
- Files expected to change (existing):
  - `pubspec.yaml`, `pubspec.lock`: add `image_picker`, `flutter_image_compress`, `file_picker`, `pdfrx` (exact versions chosen at execution). **Dependencies: approval.**
  - `ios/Runner/Info.plist`: usage descriptions. **Native: approval.**
  - `lib/main.dart`: create `SupabaseMediaRepository` and the 3 services, register them by interface, and pass `MediaRepository` to `SupabaseAuthRepository`.
  - `lib/data/models/profile.dart`: `photoUrl` (constructor, `copyWith`, `props`). **Shared model: approval.**
  - `lib/data/repositories/supabase/supabase_profile_repository.dart` (+ `profile_row_mapper.dart` if the URL is passed through it): fill `photoUrl`.
  - `lib/data/repositories/supabase/supabase_auth_repository.dart`: constructor gets `MediaRepository`, and `deleteAccount` removes files first.
  - `lib/data/repositories/supabase/supabase_failure_mapper.dart`: map `StorageException` (413 / "Payload too large" → `fileTooLarge`, 415 / mime → `fileTypeNotAllowed`, others → `UnexpectedFailure`; `SocketException` already → `NetworkFailure`).
  - `lib/core/errors/failures.dart`: `ValidationReason.fileTooLarge`, `fileTypeNotAllowed`, `certificateLimitReached` (defensive: the tile is hidden at the limit). **Shared core: approval.**
  - `lib/core/widgets/app_avatar.dart`: show `photoUrl` with a fallback to initials, plus `showPhoto` (default `true`). **Shared core widget: approval.**
  - `lib/features/discover/presentation/widgets/student_card.dart`: `showPhoto: false`. `person_row.dart`: `showPhoto` parameter, set `false` for students on the search results screen (decision 5); `search_results_screen.dart` passes it.
  - `lib/features/profile_setup/bloc/teacher_setup_cubit.dart` + `teacher_setup_state.dart`, `student_setup_cubit.dart` + `student_setup_state.dart`: real pick → compress → upload, plus `uploading` / `uploadError` state. The constructor gets `MediaRepository`, `ImagePickerService`, `ImageCompressor` (and `DocumentPickerService` for teachers).
  - `lib/features/profile/bloc/edit_profile_cubit.dart` + `edit_profile_state.dart`: same, plus deleting a removed or replaced file after save.
  - `lib/features/profile_setup/presentation/teacher_setup_screen.dart`, `student_setup_screen.dart`, `widgets/photo_picker_tile.dart` (shows the real photo and a loading spinner), `widgets/upload_tile.dart` (`loading`); `lib/features/profile/presentation/edit_profile_screen.dart`, `widgets/certificate_row.dart` (display name; `onTap` opens the viewer). Teacher setup step 3 shows the uploaded certificate with `CertificateRow` instead of the "1 certificate added" label. `CertificateRow` is reused from the profile feature, the same way `PersonRow` is already reused across features. Teacher setup step 3 and Edit profile hide the upload tile when 1 certificate exists and show the instructions note (`AppInfoNote`, existing shared widget, unchanged). The screens pass `context.read<…>()` into the cubits.
  - `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart`: a `certificate` route under `/me` (signed-in only, through the existing redirect). **Shared core router: approval.**
  - `lib/features/settings/bloc/delete_account_cubit.dart`: no change expected (the repository does the work). Listed in case the error text needs it.
  - `lib/l10n/app_en.arb` (+ generated): `uploadCertificatesHint` "PDF"; `uploadCertificatesAction` "Upload certificates" → "Upload certificate"; new `certificateInstructions` (decision 10); new strings for the viewer (title fallback, "Couldn't open the certificate", Retry, page indicator), the camera / gallery chooser and the upload errors (file too large, only PDF, only one certificate, upload failed). The existing plural strings (`certificatesApproved` etc.) stay and work for 1.
  - Tests: `test/features/cubits_test.dart`, `test/features/profile_settings_test.dart` (constructors gain fakes), `test/data/supabase/supabase_failure_mapper_test.dart`, `test/helpers/test_app.dart` (register `MockMediaRepository` + fake services if screens create cubits).
  - Docs: `API_REFERENCE.md`, `DATABASE_AND_CACHE.md`, `ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md`, `COMMON_COMPONENTS.md`, `ERROR_HANDLING.md`, `TESTING_GUIDE.md` (applying the Storage migration, iOS pods), `KNOWN_ISSUES.md`, `PROJECT_OVERVIEW.md`, `FILE_CATALOG.md`.
- Files that must not change: `docs/product/*`, applied migrations (`20261123120000_profiles.sql`, `20261123120100_delete_my_account.sql`), `ProfileStrengthCalculator` and its weights, `AuthRepository` / `ProfileRepository` interfaces (no method change), `android/**` (unless approved during execution), theme, router, other features, `CLAUDE.md`, skill files.

### Proposed New Files (approval requested)

| Group | Count | Paths / classes |
|---|---|---|
| Repository interface | 1 | `lib/data/repositories/media_repository.dart` (`MediaRepository`) |
| Supabase repository | 1 | `lib/data/repositories/supabase/supabase_media_repository.dart` (`SupabaseMediaRepository`; receives `SupabaseClient`) |
| Mock repository | 1 | `lib/data/repositories/mock/mock_media_repository.dart` (`MockMediaRepository`, in memory, for tests) |
| Models / enums | 2 | `lib/data/models/enums/media_bucket.dart` (`MediaBucket`), `lib/data/models/picked_document.dart` (`PickedDocument`) |
| Services | 7 | `lib/core/services/image_picker_service.dart` (`ImagePickerService`), `image_picker_image_picker_service.dart` (implementation), `image_source_kind.dart` (`ImageSourceKind`, decision 1), `image_compressor.dart` (`ImageCompressor`), `flutter_image_compress_image_compressor.dart` (implementation), `document_picker_service.dart` (`DocumentPickerService`), `file_picker_document_picker_service.dart` (implementation) |
| Logic | 1 | `lib/core/logic/certificate_file_rules.dart` (`CertificateFileRules`: PDF header, 3 MB, `maxCertificates = 1`, safe file name; used by `profile` and `profile_setup`) |
| Widget | 1 | `lib/core/widgets/photo_source_sheet.dart` (`PhotoSourceSheet`: Camera / Gallery on `AppBottomSheet`; used by setup and edit profile): **shared widget, approval** (decision 1) |
| Viewer screen + cubit | 3 | `lib/features/profile/presentation/certificate_viewer_screen.dart` (`CertificateViewerScreen`), `lib/features/profile/bloc/certificate_viewer_cubit.dart` (`CertificateViewerCubit`), `certificate_viewer_state.dart` (`CertificateViewerState`) |
| Migration | 1 | `supabase/migrations/20261124120000_storage_avatars_certificates.sql` (2 buckets, size and MIME limits, policies; rollback in the header) |
| SQL checks | 1 | `supabase/tests/storage_policies_checks.sql` |
| Tests | 4 | `test/data/supabase/supabase_media_repository_paths_test.dart` (path building / name sanitising, if kept pure; otherwise merged into the rules test), `test/core/logic/certificate_file_rules_test.dart`, `test/core/widgets/app_avatar_test.dart` (photo, fallback, `showPhoto: false`), `test/features/media_upload_cubits_test.dart` (pick cancelled, upload OK, too large, not PDF, network error, remove → delete after save; `CertificateViewerCubit` loading → loaded, failure → retry → loaded) |

Total ≈ 23 new files, ≈ 33 modified (including generated l10n and docs).

- Approval requirements: High risk. Explicit approval is needed for the 4 dependencies, the new route and viewer screen (a design deviation: no artboard), the iOS `Info.plist` keys, the migration (buckets and policies), the new interface `MediaRepository`, the 3 service interfaces, `Profile.photoUrl`, the new `ValidationReason` values, the `AppAvatar` change, the `SupabaseAuthRepository` constructor change, the new files above, and decisions 1–10.

## Decisions (recommended answers accepted by the developer, 2026-11-24)

All nine questions are answered. Decision 2 was changed and decision 10 added by the developer. Each one stays open to change until `APPROVE PHASE`.

1. **Photo source: camera and gallery.** A small chooser sheet (`PhotoSourceSheet` on `AppBottomSheet`). iOS gets both `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription`. `ImageSourceKind` and `PhotoSourceSheet` are included. DECIDED (pending approval)
2. **Certificate limits: 3 MB, only 1 certificate per teacher** (changed 2026-11-24 by the developer from "5 per teacher", then from 5 MB to 3 MB; reason: limited free Supabase Storage; multiple certificates come in v2 or later). The limit is one constant, `CertificateFileRules.maxCertificates = 1`, so v2 changes one value plus the UI. The upload tile is hidden while a certificate exists. Size and type are enforced by the bucket too (`file_size_limit` 3 MB, `allowed_mime_types` `{application/pdf}`). The count is enforced in the app only. `teacher_details.certificate_paths` stays an array (no schema change, ready for v2); a database check `cardinality(certificate_paths) <= 1` is **not** added (it would need removing in v2 and blocks the migration while placeholder rows exist). DECIDED (pending approval)
3. **Upload on pick, commit on save.** The file uploads when picked, and the tile shows a spinner and then the file. The path is saved with the existing Save / Next. A replaced photo or removed certificate is deleted from Storage only after the save succeeds. Files uploaded but never saved are deleted (best effort) when the cubit closes. DECIDED (pending approval)
4. **Avatars: public bucket (plan).** Timestamped file names (`<uid>/avatar-<ts>.jpg`); URLs from `getPublicUrl`. `certificates` stays private. DECIDED (pending approval)
5. **Student photos hidden in every discover list.** The Students tab cards (`StudentCard`) and search results (`PersonRow` when the person is a student) show initials. The student's own profile, chat, comments and posts show the photo. DECIDED (pending approval)
6. **In-app PDF viewer for the owner** (changed 2026-11-24 by the developer from "no preview").
   - Route: new full-screen route `/me/certificate?path=<encoded path>` (`AppRoutes.certificate(path)`).
   - Classes: `CertificateViewerScreen` + `CertificateViewerCubit` (status loading / loaded / failure, `retry()`).
   - Layout, built from existing parts because no artboard exists for this screen (a design deviation that needs approval): `BackHeader` with the file name as the title, the PDF pages on `surface100`, a centred spinner while loading, and `EmptyStateView` (document icon, "Couldn't open the certificate", Retry) on failure.
   - Opened by tapping `CertificateRow` in teacher setup step 3 and Edit profile. This also works right after upload, before save, because the file is already in Storage.
   - Download goes through the authenticated Storage API: no public or signed URL, no disk cache.
   - Viewer package: **`pdfrx` (recommended: MIT licence, maintained, renders from bytes on Android and iOS, built-in zoom and scroll)**. The exact version and app-size impact are checked at execution, and a problem stops for approval. Alternative: `pdfx` (uses the platform renderers, smaller, less actively maintained).
   - Others (admin, students) cannot view; the admin view comes in the admin phase.
   DECIDED (pending approval)
7. **Verified teachers may remove certificates.** `is_verified` is not touched (admin-only). Recorded for the admin phase. DECIDED (pending approval)
8. **Placeholder rows from PHASE_004:** the developer clears `photo_path` / `certificate_paths` for test accounts (or deletes them) before manual testing. The code only adds the initials fallback, with no data migration. DECIDED (pending approval)
9. **Migration applied by the developer** in the Supabase SQL editor, followed by `storage_policies_checks.sql`, as in PHASE_004 decision 7. I take no remote action. DECIDED (pending approval)
10. **Certificate instructions** (added 2026-11-24 by the developer). An `AppInfoNote` under the certificate section in teacher setup step 3 and Edit profile, shown whether or not a certificate is uploaded. Proposed text (`certificateInstructions`, the developer may change the wording before approval): "Upload one certificate (ijazah, sanad or diploma) as a PDF, up to 3 MB. Make sure your name and the issuing institute are clear. Only our review team can see it." DECIDED (pending approval)

Resulting file choices (from the "chosen at approval" items above):

- `CertificateFileRules` → `lib/core/logic/certificate_file_rules.dart` (used by 2 features); test `test/core/logic/certificate_file_rules_test.dart`.
- `PhotoSourceSheet` → `lib/core/widgets/photo_source_sheet.dart` (shared widget, used by setup and edit profile).
- `ImageSourceKind` → `lib/core/services/image_source_kind.dart` (needed because of decision 1).
- `PersonRow` (`lib/features/discover/presentation/widgets/person_row.dart`) is modified for decision 5. It gets a `showPhoto` parameter (default `true`). Only `search_results_screen.dart` sets it to `false` for students, so connections and blocked users are unchanged.

## Readiness Checklist

- [x] Requirement is clear (decisions 1–10; decision 6 changed to the in-app viewer)
- [x] Expected behavior is clear (draft acceptance criteria)
- [x] Existing flow is traced
- [x] API is verified (Supabase Storage `uploadBinary`, `remove`, `list`, `getPublicUrl` in `supabase_flutter` 2.18; remote project exists and is used since PHASE_004)
- [x] Request contract is verified (`MediaRepository` contract above)
- [x] Response contract is verified (paths returned; `photoUrl` derived)
- [x] Supabase tables, RLS and Storage policies are defined (contract above; bucket visibility: decision 4)
- [x] Security, 18+ gate and moderation rules are unaffected or approved (no change to them; student-photo rule kept; admin-only columns untouched)
- [x] Required UI/design is available (existing tiles, rows and avatar; the chooser sheet uses `AppBottomSheet`; the viewer screen has no artboard and is built from `BackHeader` + `EmptyStateView`, a design deviation for approval)
- [x] Existing reusable components are identified
- [x] Proposed files are identified
- [x] New files/classes are approved
- [x] Platform behavior is understood (Android: no permission expected, UNVERIFIED until a run; iOS: 2 plist keys)
- [x] Permissions are understood
- [x] Dependencies are available (4 packages approved: `image_picker`, `flutter_image_compress`, `file_picker`, `pdfrx`; versions checked against SDK `^3.11.0`, iOS 13.0 and Android `minSdk` at execution)
- [x] Risks are documented
- [x] Automated tests are defined
- [x] Manual tests are defined
- [x] Rollback plan is defined
- [x] Phase dependencies are completed (PHASE_004 closed)
- [x] Developer approval is recorded

## Risks

- One certificate is enforced in the app only. A user calling the Storage API directly could upload more files into their own folder (still 3 MB each, PDF only, own folder). Accepted for v1. An admin can clean up in the dashboard.
- Storage policy mistakes expose private certificates or let users overwrite others' files. Mitigation: SQL checks, owner-folder policies, a private bucket and server MIME and size limits.
- Public avatars (decision 4): anyone with the URL can view a photo.
- Native setup: the 3 plugins add pods and Gradle dependencies. A package may need a higher iOS target or `minSdk`. If so, execution stops for approval.
- `flutter_image_compress` behaviour differs per platform (HEIC on iOS, EXIF rotation). This is manual-tested on both platforms.
- Large PDFs are read fully into memory (`withData: true`). The viewer also downloads into memory. The 3 MB limit keeps this safe.
- PDF viewer: `pdfrx` adds native PDFium binaries (app size) and a new native dependency on both platforms. A malformed PDF goes to the viewer's error callback and then the error view. No crash is expected; this is manual-tested with a damaged file.
- The viewer screen has no design artboard; it uses existing components only.
- Account deletion: files are removed before the auth user. A failure in between leaves orphan files, or (if the order were reversed) files with no owner. Mitigated by ordering and error display. Leftovers can be removed in the dashboard.
- Orphan uploads when the app is killed before save (decision 3). Small, and recorded.
- CDN caching: a fixed avatar file name would show stale photos. Timestamped names avoid this.
- `Profile.photoUrl` is a shared model change: every `Profile` equality and `copyWith` user is affected (additive, default `null`).
- Constructor changes on 3 cubits and `SupabaseAuthRepository` mean the existing tests need fakes.
- Free plan: 1 GB Storage and the egress limits (plan section 13).

## Test Plan

- Automated: `flutter analyze`. `CertificateFileRules` (PDF header OK / not PDF, size limit, count limit, file-name sanitising, display name from path). `SupabaseFailureMapper` (Storage errors → failures). `AppAvatar` (photo URL → `Image.network`, error → initials, `showPhoto: false` → initials). Cubits with `MockMediaRepository` and fake services: cancel → no change; photo upload → path in draft + strength; upload network error → error state, draft unchanged; certificate not PDF / too large / second certificate → refused (`certificateLimitReached`); upload tile hidden when 1 exists; remove + save → delete called; replace photo + save → old file deleted. All existing tests stay green. Supabase repositories are not tested against a live server.
- SQL: `supabase/tests/storage_policies_checks.sql`, run by the developer after the migration.
- Manual (developer, Android and iOS, real Supabase; high risk, so the cases are listed):
  1. Teacher setup step 1 → Camera and Gallery → photo shows → Next → `profiles.photo_path` set, file in `avatars/<uid>/`, strength +15.
  2. Student setup photo → same. In the Students list that student shows initials and also in search results. Their own profile shows the photo.
  3. Edit profile → Change photo → Save → new photo everywhere (top bar, my profile, posts). The old file is gone from the bucket.
  4. Pick, then cancel → nothing changes.
  5. Teacher → instructions note visible → Upload certificate → only PDFs are selectable. A PDF under 3 MB uploads and shows its name. The upload tile disappears. Strength +10. The file is in `certificates/<uid>/`.
  6. A PDF over 3 MB → "too large". Remove → the upload tile comes back → upload a different PDF → Save → only the new file is in the bucket.
  6b. Tap the uploaded certificate (setup and Edit profile) → the viewer opens with a spinner, then the pages. Zoom and scroll work, the page indicator updates, and Back returns. Airplane mode → error + Retry → works after reconnecting. A non-PDF file renamed to `.pdf` is refused at upload (header check).
  7. Remove certificate → Save → the file is gone from the bucket and the row is updated.
  8. Airplane mode → upload → "No connection". Turn it back on and retry.
  9. Log in as another user → their certificates can't be listed. The public avatar URL opens (decision 4).
  10. Delete account → both bucket folders are empty, the user is gone.
  11. An old placeholder `photo_path` → initials, no crash.
  12. Run `storage_policies_checks.sql` → all PASS.

## Rollback Plan

- App: revert the phase commit (or restore the modified files and delete the new ones), then run `flutter pub get` and `pod install` (iOS). Photos fall back to initials and uploads return to placeholders.
- Database / Storage: the migration is additive. On a project with no real users, empty and drop the two buckets and policies as written in the migration header. Buckets must be emptied through the dashboard or API first. Never run this against production data without explicit approval.
- `photo_path` / `certificate_paths` values pointing to deleted files fall back to initials or a file name only.

## Implementation

- Approved implementation plan: Approved 2026-11-24 by the developer ("APPROVE PHASE: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES"), after decisions 1–10 were recorded and shown. Readiness 21/21. Approval covers:
  - Scope, acceptance criteria 1–11 (including 3a instructions and 3b viewer) and decisions 1–10 as written above, including the proposed instruction text and `pdfrx` as the viewer package.
  - Dependencies: `image_picker`, `flutter_image_compress`, `file_picker`, `pdfrx` (exact versions chosen at execution and recorded). No other package.
  - Native: `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` in `ios/Runner/Info.plist`. No Android change is approved. If one turns out to be needed (manifest, `minSdk`), or an iOS deployment-target raise, execution stops at `APPROVAL`.
  - Supabase: 1 new migration (`avatars` public bucket with JPEG / 1 MB; `certificates` private bucket with PDF / 3 MB; owner-folder policies; teacher-only certificate insert) and `supabase/tests/storage_policies_checks.sql`. Applied by the developer (decision 9). No edit to applied migrations, no table change, no remote action by me.
  - New interfaces: `MediaRepository` (upload avatar / certificate, download certificate, delete files, delete all user files), `ImagePickerService`, `ImageCompressor`, `DocumentPickerService`.
  - Shared changes: `Profile.photoUrl` (display-only); `ValidationReason.fileTooLarge`, `fileTypeNotAllowed`, `certificateLimitReached`; `AppAvatar` photo display + `showPhoto`; `PersonRow.showPhoto`; the `certificate` route in `app_routes.dart` / `app_router.dart`; the `SupabaseAuthRepository` constructor gets `MediaRepository` (files removed before `delete_my_account`).
  - Design deviation: the certificate viewer screen has no artboard and uses `BackHeader`, `EmptyStateView` and the theme tokens only.
  - New files (≈ 23): `media_repository.dart`, `supabase_media_repository.dart`, `mock_media_repository.dart`, `media_bucket.dart`, `picked_document.dart`, 7 files in `lib/core/services/` (3 interfaces, 3 implementations, `image_source_kind.dart`), `lib/core/logic/certificate_file_rules.dart`, `lib/core/widgets/photo_source_sheet.dart`, `certificate_viewer_screen.dart`, `certificate_viewer_cubit.dart`, `certificate_viewer_state.dart`, the migration, the SQL checks, and the 4 test files listed under Scope.
  - Modified files as listed under Scope.
  - Not approved: post or chat images, admin certificate review or `is_verified`, a database check on the certificate count, Edge Functions, Dio, any remote Supabase action, Android native changes, any other package. Anything unplanned during execution stops at step `APPROVAL`.
  - Prerequisites before manual testing (not before execution): the developer applies the migration, runs the SQL checks, clears placeholder rows (decision 8), and does the first iOS build with pods.
- Implementation log:
  - 2026-11-24 Developer: "EXECUTE PHASE". Readiness OK, no other active phase. Baseline: branch `PHASE_004_BACKEND_FOUNDATION` at `2955fd7`; pre-existing uncommitted changes: this phase's docs only. Status `ACTIVE`, step `EXECUTION`. Implemented the approved scope in one pass; step `MANUAL_TEST`.
  - Decisions taken inside the approved scope (no new file, class, dependency or interface beyond the approval):
    - `pdfrx` resolved to `^2.4.7`: `pdfrx` 3.x needs a newer Flutter than the project's 3.41. Native minimums checked in the pub cache: `image_picker_android` needs `minSdk` 24, which is the Flutter 3.41 default; PDFium pod iOS 12 is at or below the project's 13.0. No Android or iOS project setting changed.
    - Certificate viewer route is top-level `/certificate?path=…` (`AppRoutes.certificate(path)`), not `/me/certificate`. Opening it from teacher setup must not build My profile under it.
    - `AppAvatar` got a `preview` (bytes) parameter beside `showPhoto`, inside the approved `AppAvatar` change. A just-uploaded photo shows before save, because the public URL exists only after the profile is saved and read back.
    - `DocumentPickerService.pickPdf({required int maxReadBytes})` and `PickedDocument.sizeBytes`: a file over 3 MB is never read into memory.
    - The file-name rules (`objectName`, `displayName`) live in `CertificateFileRules`, so the planned `test/data/supabase/supabase_media_repository_paths_test.dart` was merged into `test/core/logic/certificate_file_rules_test.dart`, as the approved plan allowed.
    - Edit profile: after a successful save, the `saved` state is emitted before old files are deleted. The deletions run in the background. Awaiting them first let the router's session refresh undo the screen's pop (found by the existing screen test).
    - Picker permission denial or plugin errors become `UnexpectedFailure` → "Upload failed. Please try again." No new reason.
    - `test/helpers/test_app.dart` `tapText` now pumps after `ensureVisible`. Teacher setup step 3 became taller (instructions note), and the helper tapped before the scrolled layout existed. The layout itself was checked: the button is reachable by scrolling.
- Exact changed files: see Change Log.
- Purpose of every changed file: see Change Log.
- Existing components reused: see Analysis.
- New approved components (all created as approved): `MediaRepository`, `SupabaseMediaRepository`, `MockMediaRepository`, `MediaBucket`, `PickedDocument`, `ImagePickerService` (+ implementation), `ImageSourceKind`, `ImageCompressor` (+ implementation), `DocumentPickerService` (+ implementation), `CertificateFileRules`, `PhotoSourceSheet`, `CertificateViewerScreen`, `CertificateViewerCubit`, `CertificateViewerState` (see approved plan).
- Out-of-scope findings:
  - `EditProfileCubit.photoChanged()` and the setup cubits used different placeholder path patterns (`avatars/<id>.jpg` vs `avatars/<id>/profile.jpg`). Both are replaced by the real path in this phase.
  - Per-item busy states for list buttons and missing network-error text on setup / edit profile (recorded in PHASE_004). The upload errors added here cover only uploads, not the general Save error.
- 2026-11-24 (developer report during manual test: "student profile all details added but still 60 %"). Pre-existing since PHASE_003, not caused by this phase: the student Edit profile has no fields for **level (15)**, **languages (15)** and **preferred teacher gender (10)**. These are set only in student setup steps 2–3, so a student who skipped setup can reach at most 60 % from Edit profile. `ProfileStrengthCalculator` and the SQL trigger agree. Developer approved fixing it inside this phase ("Fix inside PHASE_005", 2026-11-24): see Change Log, "Fix 2026-11-24 — student Edit profile fields".
- Upload bookkeeping (decision 3: which files to delete after save or on leaving) is about 40 identical lines in `TeacherSetupCubit`, `StudentSetupCubit` and `EditProfileCubit`. A shared helper class would have been an unapproved new file. Candidate for a small approved extraction later.
  - The ARB string `certificatesAdded` is no longer used (setup now shows the certificate row). Left in place: removing it is cleanup outside scope.
  - Create post and chat still attach sample photos (feed and chat phases).
- Not in this phase: opening the certificate from My profile, which shows only the "1 certificate · in review" text. It can be added on request.
- Unexpected risks: None yet.

## Change Log

Branch `PHASE_004_BACKEND_FOUNDATION` (base `2955fd7`). Pre-existing uncommitted changes before execution: this phase's docs only (`PHASE_INDEX.md`, `PHASE_STATE.md`, this file). Every path below is in an approved group.

| File | Type | Approved | What / why | Preserved / risk |
|---|---|---|---|---|
| `pubspec.yaml`, `pubspec.lock` | modified | yes (dependencies) | `image_picker ^1.2.4`, `flutter_image_compress ^2.5.1`, `file_picker ^13.4.1`, `pdfrx ^2.4.7` (+ transitive, 52 changed) | No other direct package; first iOS build adds pods (PDFium xcframework) |
| `ios/Runner/Info.plist` | modified | yes (native) | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` | Other keys unchanged; Android untouched |
| `lib/core/errors/failures.dart` | modified | yes (shared core) | `ValidationReason.fileTooLarge`, `fileTypeNotAllowed`, `certificateLimitReached` | Additive; existing switches have defaults |
| `lib/core/logic/certificate_file_rules.dart` | added | yes | PDF header, 3 MB, max 1, safe / display names | Pure |
| `lib/core/services/*` (7 files) | added | yes | `ImagePickerService` + `ImagePickerImagePickerService`, `ImageCompressor` + `FlutterImageCompressImageCompressor`, `DocumentPickerService` + `FilePickerDocumentPickerService`, `ImageSourceKind` | Plugins imported only here |
| `lib/core/widgets/photo_source_sheet.dart` | added | yes (shared widget) | Camera / Gallery chooser on `AppBottomSheet` + `SettingsTile` | — |
| `lib/core/widgets/app_avatar.dart` | modified | yes (shared widget) | Photo from `photoUrl` / `preview`, initials while loading and on error; `showPhoto` | Without a photo: identical initials avatar |
| `lib/core/router/app_routes.dart`, `app_router.dart` | modified | yes (router) | `certificateViewer` route + `certificate(path)` | Other routes and redirects unchanged |
| `lib/data/models/profile.dart` | modified | yes (shared model) | `photoUrl` (display-only) in constructor, `copyWith`, `props` | Default null; never written to the DB (`ProfileRowMapper` unchanged) |
| `lib/data/models/enums/media_bucket.dart`, `lib/data/models/picked_document.dart` | added | yes | `MediaBucket`, `PickedDocument` | — |
| `lib/data/repositories/media_repository.dart` | added | yes (interface) | Contract as approved (+ `downloadCertificate`) | — |
| `lib/data/repositories/supabase/supabase_media_repository.dart` | added | yes | Storage upload / download / remove / list in the owner's folder | Checks the signed-in user before writing |
| `lib/data/repositories/mock/mock_media_repository.dart` | added | yes | In-memory files for tests | Not registered in `main.dart` |
| `lib/data/repositories/supabase/supabase_failure_mapper.dart` | modified | yes | `StorageException` mapping | Auth / PostgREST mapping unchanged |
| `lib/data/repositories/supabase/supabase_profile_repository.dart` | modified | yes | `photoUrl` from `getPublicUrl` when reading | Writes unchanged |
| `lib/data/repositories/supabase/supabase_auth_repository.dart` | modified | yes (constructor) | Gets `MediaRepository`; `deleteAccount` removes files before the rpc | Other auth flows unchanged |
| `lib/main.dart` | modified | yes | Creates `SupabaseMediaRepository` and the 3 services; registers them by interface | Other wiring unchanged |
| `lib/features/profile_setup/bloc/teacher_setup_cubit.dart` + state, `student_setup_cubit.dart` + state | modified | yes | Real pick → compress → upload; certificate pick / remove; `uploadingPhoto`, `photoPreview`, `mediaError`, `uploadingCertificate`; delete replaced / unsaved files | Step / save / skip flow unchanged; placeholder `photoAdded` / `certificateAdded` removed |
| `lib/features/profile/bloc/edit_profile_cubit.dart` + state | modified | yes | Same for Edit profile; `saved` emitted before background deletions | Field editing and save unchanged; placeholder `photoChanged` / `certificateAdded` removed |
| `lib/features/profile/bloc/certificate_viewer_cubit.dart`, `certificate_viewer_state.dart` | added | yes | Download for the viewer, `retry` | — |
| `lib/features/profile/presentation/certificate_viewer_screen.dart` | added | yes (design deviation) | `BackHeader` + `PdfViewer.data` + page indicator; error view with Try again | Only file importing `pdfrx` |
| `lib/features/profile_setup/presentation/teacher_setup_screen.dart`, `student_setup_screen.dart` | modified | yes | Chooser sheet, upload states, SnackBar for upload errors; step 3: `CertificateRow`, tile hidden at the limit, instructions note | Layout otherwise unchanged |
| `lib/features/profile_setup/presentation/widgets/photo_picker_tile.dart`, `upload_tile.dart` | modified | yes | `preview` / `loading`; `loading` | Defaults keep the old look |
| `lib/features/profile/presentation/edit_profile_screen.dart` | modified | yes | Chooser, photo spinner and preview, viewer link, tile hidden at the limit, instructions, upload-error SnackBar | Save / pop behaviour unchanged |
| `lib/features/profile/presentation/widgets/certificate_row.dart` | modified | yes | Original file name; `onTap` | Without `onTap`, same row |
| `lib/features/discover/presentation/widgets/person_row.dart`, `search_results_screen.dart`, `widgets/student_card.dart` | modified | yes | `showPhoto`; student photos hidden in search results and Students cards (decision 5) | Connections / blocked users unchanged |
| `lib/l10n/app_en.arb` (+ generated) | modified | yes | "Upload certificate", "PDF", chooser, instructions, upload errors, viewer strings | — |
| `supabase/migrations/20261124120000_storage_avatars_certificates.sql` | added | yes | 2 buckets + 8 policies; rollback in header | Not applied remotely by me |
| `supabase/tests/storage_policies_checks.sql` | added | yes | 9 PASS / FAIL checks in a rolled-back transaction | Changes nothing |
| `test/helpers/test_app.dart` | modified | yes | Registers `MockMediaRepository` + fakes; `samplePdf`; `tapText` pumps after `ensureVisible` | — |
| `test/features/cubits_test.dart`, `profile_settings_test.dart` | modified | yes | New constructors; teacher setup test uploads a real (mock) photo | Assertions kept |
| `test/data/supabase/supabase_failure_mapper_test.dart` | modified | yes | Storage error cases | — |
| `test/core/logic/certificate_file_rules_test.dart`, `test/core/widgets/app_avatar_test.dart`, `test/features/media_upload_cubits_test.dart` | added | yes | 24 new tests in total | — |
| `docs/API_REFERENCE.md`, `DATABASE_AND_CACHE.md`, `ARCHITECTURE.md`, `DIRECTORY_STRUCTURE.md`, `COMMON_COMPONENTS.md`, `ERROR_HANDLING.md`, `TESTING_GUIDE.md`, `KNOWN_ISSUES.md`, `PROJECT_OVERVIEW.md`, `FILE_CATALOG.md` | modified | yes | PHASE_005 facts, setup step 7 | — |
| `docs/phases/items/…`, `PHASE_INDEX.md`, `state/PHASE_STATE.md` | modified | yes | Phase records | — |

Not changed: `android/**`, applied migrations, `ProfileStrengthCalculator`, `AuthRepository` / `ProfileRepository` interfaces, theme, `docs/product/*`, `CLAUDE.md`, skill files.

### Fix 2026-11-24 — student Edit profile fields (developer request, inside this active phase)

Developer (manual test): "in student profile i have added all detail but it still 60 percent". Cause: the student Edit profile had no Level, Languages or Preferred teacher gender (15 + 15 + 10 = 40 % of the student strength). These could only be set in setup steps 2–3, so a student who skipped setup topped out at 60 %. This dated from PHASE_003 and was not caused by this phase. The developer chose "Fix inside PHASE_005". No new file, class, dependency, interface, migration or string.

| File | Type | What / why | Preserved / risk |
|---|---|---|---|
| `lib/features/profile/bloc/edit_profile_cubit.dart` | modified | `levelChanged`, `preferenceChanged` (same as `StudentSetupCubit`); languages use the existing `languageToggled` | Other edits and save unchanged |
| `lib/features/profile/presentation/edit_profile_screen.dart` | modified | Student section: Level select, Languages chips (the 4 setup languages), Preferred teacher gender segmented control, between "What I want to learn" and the short note. Reuses existing strings and widgets (`_select`, `_chips`, `AppSegmentedControl`) | Teacher section unchanged |
| `test/features/profile_settings_test.dart` | modified | 1 test: a student without setup reaches 60 % with the old fields, and 100 % after the 3 new ones (also after save) | — |

Strength rules (`ProfileStrengthCalculator`, SQL trigger) were not changed; they were already correct.

Checks: `dart format` on the 3 files; `flutter analyze` — No issues found; `flutter test` — 146 / 146 passed.

## Execute Technical Checks

2026-11-24:

- `flutter pub add image_picker flutter_image_compress file_picker pdfrx`: resolved, 52 dependencies changed.
- `flutter gen-l10n`: OK.
- `dart format lib test`: applied.
- `flutter analyze`: No issues found.
- `flutter test`: 145 / 145 passed (121 existing + 24 new). Two newly introduced failures were fixed in scope: the late-initialised saved-media map, and the save/pop ordering in Edit profile. One helper timing issue was fixed (`tapText`).
- Source assertions: `image_picker`, `flutter_image_compress` and `file_picker` are imported only in `lib/core/services/`; `pdfrx` only in `certificate_viewer_screen.dart`; `supabase_flutter` only in `lib/data/repositories/supabase/` and `lib/main.dart`; `Supabase.instance` only in `lib/main.dart`. No keys or tokens in `lib/`, `supabase/`, `test/` (one doc comment mentions `service_role` as refused).
- Not run: the migration and `storage_policies_checks.sql` (no remote access; the developer applies them, decision 9); app launch and builds (not requested); iOS `pod install` (the developer's first iOS build); plugin behaviour on devices (manual test).

## Manual Testing

- Developer manual-test confirmation: 2026-11-24, "CLOSE PHASE: PHASE_005_BACKEND_ADD_STORAGE_PHOTOS_CERTIFICATES". It was sent after the instruction to send it when everything works, including the student-fields fix, so it is treated as successful manual-test confirmation.
- Tested platforms / devices: not stated by the developer.
- Failed and retested cases: one. The student strength stuck at 60 % was fixed inside this phase ("Fix 2026-11-24 — student Edit profile fields"); the developer closed afterwards.
- Storage policy SQL checks (`storage_policies_checks.sql`): result not reported. The migration being applied remotely is implied by working uploads but was not verified by me.
- Manual cases: see Test Plan.

## Closure

- Closed 2026-11-24: status `CLOSED`, step `CLOSURE`, outcome `COMPLETED`.
- Final changed files: as in the Change Log and the 2026-11-24 fix (student Edit profile fields). No unapproved dependency or architecture change. The only new packages are the approved `image_picker`, `flutter_image_compress`, `file_picker` and `pdfrx` (2.4.7). The only native change is the 2 approved `Info.plist` keys. `pubspec.yaml` and `Info.plist` diffs contain only this phase's changes (checked at closure).
- Pre-existing / unrelated changes in the working tree, not part of this phase and not claimed: new app launcher icons made by the developer (`android/app/src/main/res/mipmap-*` incl. new `mipmap-anydpi-v26/`, `mipmap-ldpi/`, `*_foreground.png`, `*_round.png`, `values/ic_launcher_background.xml`; `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` incl. `Contents.json` and `ItunesArtwork@2x.png`). `pubspec.lock` and the generated `lib/l10n/app_localizations*.dart` were re-touched by the developer's `flutter pub get` / run; their content comes from this phase.
- Technical evidence reused (no phase implementation file changed after it): `flutter analyze` — No issues found; `flutter test` — 146 / 146 passed (after the student-fields fix). Not rerun at closure.
- Known limitations:
  - One certificate per teacher is enforced in the app only (a direct Storage API call could add more PDFs to the user's own folder; still PDF, 3 MB).
  - Orphan files are possible when the app is killed between upload and Save, or when a best-effort deletion fails (clean in the dashboard).
  - Avatars are public by URL (plan decision 4).
  - `image_picker` lost-data recovery is not handled; a denied photo permission shows "Upload failed".
  - Certificates open only for their owner and only from setup / Edit profile (not My profile); the admin view comes with the admin phase.
  - Post and chat photos are still sample attachments.
  - Upload bookkeeping is duplicated in 3 cubits (candidate extraction); the ARB string `certificatesAdded` is unused.
  - Network / unexpected errors on the general Save of setup / Edit profile still only re-enable the button (from PHASE_004).
- Follow-up phases (on request, dependency order): discover → safety → connections → chat (chat images bucket) → feed (post images bucket) → notifications; admin phase (certificate review, `is_verified`, admin Storage policy).
- Rollback: revert the phase commit (or restore modified files and delete new ones), then `flutter pub get` and `pod install`. Storage: drop the 8 policies as written in the migration header, then empty and delete both buckets in the dashboard. Only on a project without real users; never against production data without explicit approval.
- Commit: not requested; nothing committed by this closure.
