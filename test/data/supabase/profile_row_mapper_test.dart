import 'dart:io';

import 'package:asatiza/core/logic/profile_completeness_rules.dart';
import 'package:asatiza/data/models/enums/fee_unit.dart';
import 'package:asatiza/data/models/enums/gender.dart';
import 'package:asatiza/data/models/enums/learner_age_group.dart';
import 'package:asatiza/data/models/enums/learner_level.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/enums/teacher_gender_preference.dart';
import 'package:asatiza/data/models/enums/teaches_audience.dart';
import 'package:asatiza/data/models/enums/teaching_language.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/enums/weekday.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/models/student_details.dart';
import 'package:asatiza/data/models/teacher_details.dart';
import 'package:asatiza/data/repositories/supabase/profile_row_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = ProfileRowMapper();
  final created = DateTime.utc(2026, 11, 23, 10);

  Map<String, dynamic> base(String role) => <String, dynamic>{
    'id': 'u-1',
    'role': role,
    'full_name': 'Qari Ahmed Khan',
    'created_at': created.toIso8601String(),
    'headline': 'Tajweed teacher',
    'photo_path': null,
    'gender': 'male',
    'country': 'Pakistan',
    'city': '  ',
    'timezone': 'GMT+5',
    'languages': <String>['urdu', 'english', 'klingon'],
    'bio': null,
    'status': 'incomplete',
    'is_verified': true,
  };

  test('snake_case enum names', () {
    expect(
      ProfileRowMapper.toDb(LearnerLevel.readsWithHelp),
      'reads_with_help',
    );
    expect(ProfileRowMapper.toDb(Subject.nooraniQaida), 'noorani_qaida');
    expect(ProfileRowMapper.toDb(FeeUnit.perMonth), 'per_month');
    expect(ProfileRowMapper.toDb(Gender.female), 'female');
  });

  test('teacher row → profile (embedded object, unknown values skipped)', () {
    final row = base('teacher')
      ..['teacher_details'] = <String, dynamic>{
        'profile_id': 'u-1',
        'subjects': <String>['tajweed', 'islamic_studies'],
        'experience_years': 8,
        'qualifications': 'Ijazah',
        'fee_amount': 40,
        'fee_currency': 'USD',
        'fee_unit': 'per_month',
        'availability': <String, dynamic>{
          'days': <String>['monday', 'friday'],
          'from_minutes': 540,
          'to_minutes': 1020,
        },
        'teaches': <String>['children', 'women'],
        'certificate_paths': <String>['certificates/u-1/ijazah.pdf'],
      }
      ..['student_details'] = null;

    final p = mapper.fromRow(row, email: 'ahmed@example.com');
    expect(p.role, UserRole.teacher);
    expect(p.email, 'ahmed@example.com');
    expect(p.createdAt, created);
    expect(p.city, isNull, reason: 'blank text reads as null');
    expect(p.languages, <TeachingLanguage>[
      TeachingLanguage.urdu,
      TeachingLanguage.english,
    ]);
    expect(p.isVerified, isTrue);
    expect(p.studentDetails, isNull);
    final t = p.teacherDetails!;
    expect(t.subjects, <Subject>[Subject.tajweed, Subject.islamicStudies]);
    expect(t.feeUnit, FeeUnit.perMonth);
    expect(t.availableDays, <Weekday>{Weekday.monday, Weekday.friday});
    expect(t.availableFromMinutes, 540);
    expect(t.teaches, <TeachesAudience>{
      TeachesAudience.children,
      TeachesAudience.women,
    });
    expect(t.certificatePaths, hasLength(1));
  });

  test('student row in a list; missing details read as empty', () {
    final row = base('student')
      ..['student_details'] = <dynamic>[
        <String, dynamic>{
          'age_group': 'teen',
          'goals': <String>['hifz'],
          'level': 'reads_fluently',
          'preferred_teacher_gender': 'any',
          'looking_for_teacher': true,
          'note': 'Evenings',
        },
      ];
    final p = mapper.fromRow(row);
    expect(p.email, isNull);
    final s = p.studentDetails!;
    expect(s.ageGroup, LearnerAgeGroup.teen);
    expect(s.level, LearnerLevel.readsFluently);
    expect(s.preferredTeacherGender, TeacherGenderPreference.any);
    expect(s.lookingForTeacher, isTrue);

    final bare = mapper.fromRow(base('teacher'));
    expect(bare.teacherDetails, const TeacherDetails());
  });

  test('write maps never include admin or server columns', () {
    final profile = Profile(
      id: 'u-1',
      role: UserRole.teacher,
      fullName: '  Qari Ahmed  ',
      createdAt: created,
      headline: '',
      gender: Gender.male,
      languages: const <TeachingLanguage>[TeachingLanguage.arabic],
      isVerified: true,
    );
    final update = mapper.profileUpdate(profile);
    for (final column in <String>[
      'id',
      'role',
      'is_verified',
      'status',
      'created_at',
    ]) {
      expect(update.containsKey(column), isFalse, reason: column);
    }
    expect(update['full_name'], 'Qari Ahmed');
    expect(update['headline'], isNull);
    expect(update['languages'], <String>['arabic']);

    const details = TeacherDetails(
      availableDays: <Weekday>{Weekday.friday, Weekday.monday},
      feeUnit: FeeUnit.perClass,
    );
    final teacher = mapper.teacherRow('u-1', details);
    expect(teacher['availability'], <String, dynamic>{
      'days': <String>['monday', 'friday'],
      'from_minutes': null,
      'to_minutes': null,
    });
    expect(teacher['fee_unit'], 'per_class');

    final student = mapper.studentRow(
      'u-1',
      const StudentDetails(level: LearnerLevel.readsWithHelp, note: ' '),
    );
    expect(student['level'], 'reads_with_help');
    expect(student['note'], isNull);
  });

  test('round trip keeps the editable fields', () {
    final row = base('student')
      ..['student_details'] = mapper.studentRow(
        'u-1',
        const StudentDetails(
          ageGroup: LearnerAgeGroup.adult,
          goals: <Subject>[Subject.tafsir],
          preferredTeacherGender: TeacherGenderPreference.female,
        ),
      );
    final p = mapper.fromRow(row);
    expect(p.studentDetails!.goals, <Subject>[Subject.tafsir]);
    expect(p.studentDetails!.ageGroup, LearnerAgeGroup.adult);
  });

  test('server status check covers every app required field', () {
    final sql = File(
      'supabase/migrations/20261126120000_profile_status.sql',
    ).readAsStringSync();
    final start = sql.indexOf(
      'create or replace function private.profile_is_complete(',
    );
    final body = sql.substring(
      start,
      sql.indexOf(
        'create or replace function private.profiles_before_write(',
        start,
      ),
    );
    // One SQL condition per RequiredField (ProfileCompletenessRules).
    const columns = <RequiredField, String>{
      RequiredField.name: 'p.full_name',
      RequiredField.gender: 'p.gender',
      RequiredField.languages: 'p.languages',
      RequiredField.country: 'p.country',
      RequiredField.timeZone: 'p.timezone',
      RequiredField.headline: 'p.headline',
      RequiredField.subjects: 't.subjects',
      RequiredField.bio: 'p.bio',
      RequiredField.experience: 't.experience_years',
      RequiredField.qualifications: 't.qualifications',
      RequiredField.fee: 't.fee_amount',
      RequiredField.availableDays: "t.availability -> 'days'",
      RequiredField.teaches: 't.teaches',
      RequiredField.learner: 's.age_group',
      RequiredField.goals: 's.goals',
      RequiredField.level: 's.level',
      RequiredField.preferredTeacherGender: 's.preferred_teacher_gender',
    };
    expect(columns.keys.toSet(), RequiredField.values.toSet());
    for (final entry in columns.entries) {
      expect(body.contains(entry.value), isTrue, reason: entry.key.name);
    }
  });
}
