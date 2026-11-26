import 'package:equatable/equatable.dart';

/// Base type for every error a repository may throw. No raw exception
/// (Postgrest, Auth, Dio…) leaves a repository.
sealed class Failure extends Equatable implements Exception {
  const Failure();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Input rejected by a rule, e.g. wrong code or too-short password.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.reason);

  final ValidationReason reason;

  @override
  List<Object?> get props => <Object?>[reason];
}

/// What a [ValidationFailure] rejected; screens map it to a message.
/// [network] and [unexpected] are never thrown: cubits set them from
/// [FailureReason.displayReason] so screens can show a general error.
enum ValidationReason {
  invalidEmail,
  passwordTooShort,
  passwordsDoNotMatch,
  wrongCredentials,
  invalidCode,
  emailAlreadyRegistered,
  postEmpty,
  postTooLong,
  postTagMissing,
  dailyPostLimit,
  commentEmpty,
  connectNoteTooLong,
  profileIncomplete,
  alreadyConnected,
  notConnected,
  messageEmpty,
  passwordUnchanged,

  /// Log-in with an email whose sign-up code was never entered.
  emailNotConfirmed,

  /// A photo or certificate is larger than allowed (PHASE_005).
  fileTooLarge,

  /// The file is not of the allowed type (certificates: PDF only).
  fileTypeNotAllowed,

  /// The teacher already has the maximum number of certificates.
  certificateLimitReached,

  /// 10 connection requests in the last 24 hours (PHASE_008).
  requestLimitReached,

  /// The receiver declined this requester less than 3 days ago (PHASE_008).
  declinedRecently,

  /// The receiver's profile is not active yet (PHASE_008).
  receiverNotActive,

  /// No connection (from [NetworkFailure]).
  network,

  /// Anything else that went wrong (e.g. too many emails, server error).
  unexpected,
}

/// The message reason a screen shows for any [Failure].
extension FailureReason on Failure {
  ValidationReason get displayReason => switch (this) {
    ValidationFailure(:final reason) => reason,
    NetworkFailure() => ValidationReason.network,
    _ => ValidationReason.unexpected,
  };
}

/// Reasons shown as a general message, not under a field.
extension GeneralReason on ValidationReason {
  bool get isGeneral =>
      this == ValidationReason.network || this == ValidationReason.unexpected;
}

/// The requested record does not exist or is not visible.
final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// No connection, or the server could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// Anything unexpected.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
