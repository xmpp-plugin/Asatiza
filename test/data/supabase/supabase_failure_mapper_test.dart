import 'dart:async';
import 'dart:io';

import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/repositories/supabase/supabase_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const mapper = SupabaseFailureMapper();

  ValidationFailure v(ValidationReason r) => ValidationFailure(r);

  test('Auth error codes', () {
    final cases = <String, Failure>{
      'invalid_credentials': v(ValidationReason.wrongCredentials),
      'email_not_confirmed': v(ValidationReason.emailNotConfirmed),
      'user_already_exists': v(ValidationReason.emailAlreadyRegistered),
      'email_exists': v(ValidationReason.emailAlreadyRegistered),
      'otp_expired': v(ValidationReason.invalidCode),
      'weak_password': v(ValidationReason.passwordTooShort),
      'same_password': v(ValidationReason.passwordUnchanged),
      'email_address_invalid': v(ValidationReason.invalidEmail),
      'over_email_send_rate_limit': const UnexpectedFailure(),
    };
    cases.forEach((code, failure) {
      expect(
        mapper.map(AuthApiException('x', code: code)),
        failure,
        reason: code,
      );
    });
  });

  test('Auth messages without a code', () {
    expect(
      mapper.map(const AuthException('Invalid login credentials')),
      v(ValidationReason.wrongCredentials),
    );
    expect(
      mapper.map(const AuthException('Email not confirmed')),
      v(ValidationReason.emailNotConfirmed),
    );
    expect(
      mapper.map(const AuthException('Token has expired or is invalid')),
      v(ValidationReason.invalidCode),
    );
  });

  test('network errors', () {
    expect(
      mapper.map(AuthRetryableFetchException(message: 'offline')),
      const NetworkFailure(),
    );
    expect(
      mapper.map(const SocketException('no route')),
      const NetworkFailure(),
    );
    expect(mapper.map(TimeoutException('slow')), const NetworkFailure());
  });

  test('PostgREST errors and pass-through', () {
    expect(
      mapper.map(const PostgrestException(message: 'none', code: 'PGRST116')),
      const NotFoundFailure(),
    );
    expect(
      mapper.map(const PostgrestException(message: 'denied', code: '42501')),
      const NotFoundFailure(),
    );
    expect(
      mapper.map(const PostgrestException(message: 'bad', code: '23514')),
      const UnexpectedFailure(),
    );
    expect(
      mapper.map(v(ValidationReason.invalidEmail)),
      v(ValidationReason.invalidEmail),
    );
    expect(mapper.map(StateError('x')), const UnexpectedFailure());
  });
}
