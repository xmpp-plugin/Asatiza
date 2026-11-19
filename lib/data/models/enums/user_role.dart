import '../../../l10n/app_localizations.dart';

/// Account role, chosen at sign-up (one per account).
enum UserRole { student, teacher }

extension UserRoleLabel on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.student => l10n.roleStudent,
    UserRole.teacher => l10n.roleTeacher,
  };
}
