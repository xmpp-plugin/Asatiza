# Error Handling

## Verified

VERIFIED 2026-11-24 (`PHASE_005`): `ValidationReason.fileTooLarge`, `fileTypeNotAllowed`, `certificateLimitReached`. Storage errors: status 413 / "payload too large" → `fileTooLarge`; 415 / `invalid_mime_type` → `fileTypeNotAllowed`; 401 / 403 / 404 / row-level security → `NotFoundFailure`; others → `UnexpectedFailure`. Services throw `UnexpectedFailure` when a plugin fails. Setup and Edit profile show upload problems in a SnackBar ("too large", "only PDF", "one certificate", "No internet connection", "Upload failed"). The certificate viewer shows "Couldn't open the certificate" with Try again.

VERIFIED 2026-11-23 (`PHASE_004`): `SupabaseFailureMapper` maps Supabase errors — Auth codes `invalid_credentials` → `wrongCredentials`, `email_not_confirmed` → `emailNotConfirmed`, `user_already_exists` / `email_exists` → `emailAlreadyRegistered`, `otp_expired` → `invalidCode` (Supabase uses one code for wrong and expired), `weak_password` → `passwordTooShort`, `same_password` → `passwordUnchanged`, `email_address_invalid` → `invalidEmail`; `AuthRetryableFetchException`, `SocketException`, `TimeoutException`, http `ClientException` → `NetworkFailure`; PostgREST `PGRST116` / `42501` → `NotFoundFailure`; anything else → `UnexpectedFailure`. Screens show them since 2026-11-24: auth cubits and `ChangePasswordCubit` set `failure.displayReason` (`ValidationReason.network` / `unexpected`, never thrown) and the screens show "No internet connection…" or "Something went wrong…" above the button (code screens: in place of the code error). My profile shows "Couldn't load your profile" when loading fails.

No error handling, logging or crash reporting yet. VERIFIED

## Decided Pattern

- Repositories catch `AuthException`, `PostgrestException`, `StorageException`, `DioException`, `SocketException`/`TimeoutException` and map them to `*Failure` types in `lib/core/errors/`.
- Blocs/cubits expose failures as a `failure` status with a `*Failure` object; screens show user messages from one mapping function (no raw exception text).
- Auth messages: wrong code, expired code, email already registered, unconfirmed email (resend code and open code screen), weak password, too many attempts.
- Offline/timeouts show a retry action; lists keep cached data where available.
- Crashlytics records uncaught Flutter and platform errors (`FlutterError.onError`, `PlatformDispatcher.instance.onError`). No personal data or message bodies in logs.
- Use `debugPrint`/`log` only in debug; no `print` in production code.

## Rules For Recording Results

- Never claim validation passed unless the exact command ran successfully.
- Record pre-existing analyzer/test failures separately from newly introduced failures.
- For platform phases, handle permission denied/permanently denied, foreground, background, terminated and cleanup where relevant.
