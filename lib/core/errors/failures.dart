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
}

/// The requested record does not exist or is not visible.
final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// Anything unexpected.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
