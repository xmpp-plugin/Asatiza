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
