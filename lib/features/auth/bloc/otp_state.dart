import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/profile.dart';
import '../logic/otp_rules.dart';

/// Why the code was sent.
enum OtpPurpose { signUp, passwordReset }

enum OtpStatus { entering, verifying, verified }

class OtpState extends Equatable {
  const OtpState({
    required this.purpose,
    required this.email,
    this.code = '',
    this.secondsLeft = OtpRules.resendAfterSeconds,
    this.status = OtpStatus.entering,
    this.failure,
    this.user,
  });

  final OtpPurpose purpose;
  final String email;
  final String code;

  /// Seconds until "Resend code" unlocks.
  final int secondsLeft;
  final OtpStatus status;
  final ValidationReason? failure;

  /// Signed-in user after a verified sign-up code.
  final Profile? user;

  static const OtpRules _rules = OtpRules();

  bool get isComplete => _rules.isComplete(code);
  bool get canResend => secondsLeft == 0;

  OtpState copyWith({
    String? code,
    int? secondsLeft,
    OtpStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
    Profile? user,
  }) {
    return OtpState(
      purpose: purpose,
      email: email,
      code: code ?? this.code,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    purpose,
    email,
    code,
    secondsLeft,
    status,
    failure,
    user,
  ];
}
