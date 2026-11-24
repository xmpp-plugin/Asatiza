import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';

/// Turns Supabase Auth / PostgREST / Storage / network errors into [Failure]s so no
/// raw exception leaves a repository. Pure mapping, no calls.
class SupabaseFailureMapper {
  const SupabaseFailureMapper();

  Failure map(Object error) {
    return switch (error) {
      Failure() => error,
      AuthRetryableFetchException() => const NetworkFailure(),
      AuthException() => _auth(error),
      PostgrestException() => _postgrest(error),
      StorageException() => _storage(error),
      SocketException() || TimeoutException() => const NetworkFailure(),
      // `package:http` ClientException (not a direct dependency).
      _ when error.toString().startsWith('ClientException') =>
        const NetworkFailure(),
      _ => const UnexpectedFailure(),
    };
  }

  Failure _auth(AuthException error) {
    final reason = switch (error.code) {
      'invalid_credentials' => ValidationReason.wrongCredentials,
      'email_not_confirmed' => ValidationReason.emailNotConfirmed,
      'user_already_exists' ||
      'email_exists' => ValidationReason.emailAlreadyRegistered,
      // Supabase uses one code for a wrong and an expired code.
      'otp_expired' || 'otp_disabled' => ValidationReason.invalidCode,
      // Decision 2: the only password rule is 8+ characters.
      'weak_password' => ValidationReason.passwordTooShort,
      'same_password' => ValidationReason.passwordUnchanged,
      'email_address_invalid' => ValidationReason.invalidEmail,
      _ => _authByMessage(error.message),
    };
    return reason == null
        ? const UnexpectedFailure()
        : ValidationFailure(reason);
  }

  /// Older Auth servers send no `code`.
  ValidationReason? _authByMessage(String message) {
    final text = message.toLowerCase();
    if (text.contains('invalid login credentials')) {
      return ValidationReason.wrongCredentials;
    }
    if (text.contains('email not confirmed')) {
      return ValidationReason.emailNotConfirmed;
    }
    if (text.contains('already registered')) {
      return ValidationReason.emailAlreadyRegistered;
    }
    if (text.contains('token has expired or is invalid')) {
      return ValidationReason.invalidCode;
    }
    return null;
  }

  Failure _postgrest(PostgrestException error) => switch (error.code) {
    // No row for `.single()`; row hidden or write refused by RLS / privileges.
    'PGRST116' || '42501' => const NotFoundFailure(),
    _ => const UnexpectedFailure(),
  };

  /// Storage answers with an HTTP status and an error name; bucket limits
  /// (size, MIME type) and policies are enforced on the server.
  Failure _storage(StorageException error) {
    final status = error.statusCode ?? '';
    final text = '${error.error ?? ''} ${error.message}'.toLowerCase();
    if (status == '413' ||
        text.contains('payload too large') ||
        text.contains('maximum allowed size') ||
        text.contains('entitytoolarge')) {
      return const ValidationFailure(ValidationReason.fileTooLarge);
    }
    if (status == '415' ||
        text.contains('invalid_mime_type') ||
        text.contains('mime type')) {
      return const ValidationFailure(ValidationReason.fileTypeNotAllowed);
    }
    if (status == '401' ||
        status == '403' ||
        status == '404' ||
        text.contains('not found') ||
        text.contains('row-level security')) {
      return const NotFoundFailure();
    }
    return const UnexpectedFailure();
  }
}
