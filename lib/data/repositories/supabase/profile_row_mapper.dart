import '../../models/enums/fee_unit.dart';
import '../../models/enums/gender.dart';
import '../../models/enums/learner_age_group.dart';
import '../../models/enums/learner_level.dart';
import '../../models/enums/subject.dart';
import '../../models/enums/teacher_gender_preference.dart';
import '../../models/enums/teaches_audience.dart';
import '../../models/enums/teaching_language.dart';
import '../../models/enums/user_role.dart';
import '../../models/enums/weekday.dart';
import '../../models/profile.dart';
import '../../models/student_details.dart';
import '../../models/teacher_details.dart';

/// Converts `profiles` / `teacher_details` / `student_details` rows
/// (`supabase/migrations/*_profiles.sql`) to [Profile] and back.
///
/// Enum values are stored as snake_case text (`readsWithHelp` →
/// `reads_with_help`); unknown values read as null / are skipped. Pure Dart.
class ProfileRowMapper {
  const ProfileRowMapper();

  /// `select` for a profile with its role's details.
  static const String select = '*, teacher_details(*), student_details(*)';

  /// [email] is passed only for the signed-in user (plan: email is private).
  Profile fromRow(Map<String, dynamic> row, {String? email}) {
    final role =
        _enum(UserRole.values, row['role']) ??
        (throw const FormatException('profiles.role'));
    return Profile(
      id: row['id'] as String,
      role: role,
      fullName: (row['full_name'] as String?) ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      email: email,
      headline: _text(row['headline']),
      photoPath: _text(row['photo_path']),
      gender: _enum(Gender.values, row['gender']),
      country: _text(row['country']),
      city: _text(row['city']),
      timeZone: _text(row['timezone']),
      languages: _enumList(TeachingLanguage.values, row['languages']),
      bio: _text(row['bio']),
      isVerified: (row['is_verified'] as bool?) ?? false,
      isActive: row['status'] == 'active',
      teacherDetails: role == UserRole.teacher
          ? _teacher(_embedded(row['teacher_details']))
          : null,
      studentDetails: role == UserRole.student
          ? _student(_embedded(row['student_details']))
          : null,
    );
  }

  /// Only the columns the app may write. Never `id`, `role`,
  /// `is_verified` or `status`.
  Map<String, dynamic> profileUpdate(Profile profile) => <String, dynamic>{
    'full_name': profile.fullName.trim(),
    'headline': _clean(profile.headline),
    'photo_path': _clean(profile.photoPath),
    'gender': _db(profile.gender),
    'country': _clean(profile.country),
    'city': _clean(profile.city),
    'timezone': _clean(profile.timeZone),
    'languages': profile.languages.map(toDb).toList(),
    'bio': _clean(profile.bio),
  };

  Map<String, dynamic> teacherRow(
    String profileId,
    TeacherDetails d,
  ) => <String, dynamic>{
    'profile_id': profileId,
    'subjects': d.subjects.map(toDb).toList(),
    'experience_years': d.experienceYears,
    'qualifications': _clean(d.qualifications),
    'fee_amount': d.feeAmount,
    'fee_currency': d.feeCurrency,
    'fee_unit': _db(d.feeUnit),
    'availability': <String, dynamic>{
      'days': Weekday.values.where(d.availableDays.contains).map(toDb).toList(),
      'from_minutes': d.availableFromMinutes,
      'to_minutes': d.availableToMinutes,
    },
    'teaches': TeachesAudience.values
        .where(d.teaches.contains)
        .map(toDb)
        .toList(),
    'certificate_paths': d.certificatePaths,
  };

  Map<String, dynamic> studentRow(String profileId, StudentDetails d) =>
      <String, dynamic>{
        'profile_id': profileId,
        'age_group': _db(d.ageGroup),
        'goals': d.goals.map(toDb).toList(),
        'level': _db(d.level),
        'preferred_teacher_gender': _db(d.preferredTeacherGender),
        'looking_for_teacher': d.lookingForTeacher,
        'note': _clean(d.note),
      };

  /// `readsWithHelp` → `reads_with_help`.
  static String toDb(Enum value) => value.name.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m[0]!.toLowerCase()}',
  );

  TeacherDetails _teacher(Map<String, dynamic>? row) {
    if (row == null) {
      return const TeacherDetails();
    }
    final availability = row['availability'] is Map
        ? Map<String, dynamic>.from(row['availability'] as Map)
        : const <String, dynamic>{};
    return TeacherDetails(
      subjects: _enumList(Subject.values, row['subjects']),
      experienceYears: row['experience_years'] as int?,
      qualifications: _text(row['qualifications']),
      feeAmount: row['fee_amount'] as int?,
      feeCurrency: (row['fee_currency'] as String?) ?? 'USD',
      feeUnit: _enum(FeeUnit.values, row['fee_unit']),
      availableDays: _enumList(Weekday.values, availability['days']).toSet(),
      availableFromMinutes: availability['from_minutes'] as int?,
      availableToMinutes: availability['to_minutes'] as int?,
      teaches: _enumList(TeachesAudience.values, row['teaches']).toSet(),
      certificatePaths: _strings(row['certificate_paths']),
    );
  }

  StudentDetails _student(Map<String, dynamic>? row) {
    if (row == null) {
      return const StudentDetails();
    }
    return StudentDetails(
      ageGroup: _enum(LearnerAgeGroup.values, row['age_group']),
      goals: _enumList(Subject.values, row['goals']),
      level: _enum(LearnerLevel.values, row['level']),
      preferredTeacherGender: _enum(
        TeacherGenderPreference.values,
        row['preferred_teacher_gender'],
      ),
      lookingForTeacher: (row['looking_for_teacher'] as bool?) ?? false,
      note: _text(row['note']),
    );
  }

  /// PostgREST embeds a one-to-one row as an object (older servers: a list).
  Map<String, dynamic>? _embedded(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }

  static String? _db(Enum? value) => value == null ? null : toDb(value);

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _strings(Object? value) =>
      value is List ? value.whereType<String>().toList() : const <String>[];

  static T? _enum<T extends Enum>(List<T> values, Object? value) {
    for (final v in values) {
      if (toDb(v) == value) {
        return v;
      }
    }
    return null;
  }

  static List<T> _enumList<T extends Enum>(List<T> values, Object? value) =>
      _strings(value).map((s) => _enum(values, s)).whereType<T>().toList();
}
