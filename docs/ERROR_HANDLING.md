# Error Handling

## Verified

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
