import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/auth_repository.dart';
import '../logic/otp_rules.dart';
import 'otp_state.dart';

/// 6-digit email code: auto-verifies when complete, runs the 60 s resend
/// countdown (cancelled in [close]).
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._auth, {required OtpPurpose purpose, required String email})
    : super(OtpState(purpose: purpose, email: email)) {
    _startCountdown();
  }

  final AuthRepository _auth;
  Timer? _timer;
  static const OtpRules _rules = OtpRules();

  void _startCountdown() {
    _timer?.cancel();
    emit(state.copyWith(secondsLeft: OtpRules.resendAfterSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        timer.cancel();
      }
      if (!isClosed) {
        emit(state.copyWith(secondsLeft: next < 0 ? 0 : next));
      }
    });
  }

  void codeChanged(String value) {
    final code = _rules.sanitize(value);
    emit(state.copyWith(code: code, clearFailure: true));
    if (_rules.isComplete(code)) {
      verify();
    }
  }

  Future<void> verify() async {
    if (!state.isComplete || state.status == OtpStatus.verifying) {
      return;
    }
    emit(state.copyWith(status: OtpStatus.verifying, clearFailure: true));
    try {
      switch (state.purpose) {
        case OtpPurpose.signUp:
          final user = await _auth.verifySignUpCode(
            email: state.email,
            code: state.code,
          );
          if (!isClosed) {
            emit(state.copyWith(status: OtpStatus.verified, user: user));
          }
        case OtpPurpose.passwordReset:
          await _auth.verifyResetCode(email: state.email, code: state.code);
          if (!isClosed) {
            emit(state.copyWith(status: OtpStatus.verified));
          }
      }
    } on ValidationFailure catch (f) {
      if (!isClosed) {
        emit(state.copyWith(status: OtpStatus.entering, failure: f.reason));
      }
    } on Failure catch (f) {
      if (!isClosed) {
        emit(
          state.copyWith(status: OtpStatus.entering, failure: f.displayReason),
        );
      }
    }
  }

  Future<void> resend() async {
    if (!state.canResend) {
      return;
    }
    emit(state.copyWith(clearFailure: true));
    try {
      await _auth.resendCode(email: state.email);
    } on Failure catch (f) {
      // E.g. offline or too many emails: show it; the link stays active.
      if (!isClosed) {
        emit(state.copyWith(failure: f.displayReason));
      }
      return;
    }
    if (!isClosed) {
      _startCountdown();
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
