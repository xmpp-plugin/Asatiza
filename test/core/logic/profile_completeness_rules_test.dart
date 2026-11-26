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
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = ProfileCompletenessRules();
  final created = DateTime(2026, 11, 26);

  Profile teacher({TeacherDetails? details, String? headline = 'Tajweed'}) =>
      Profile(
        id: 't',
        role: UserRole.teacher,
        fullName: 'Qari Ahmed',
        createdAt: created,
        headline: headline,
        gender: Gender.male,
        country: 'Pakistan',
        timeZone: 'GMT+5',
        languages: const <TeachingLanguage>[TeachingLanguage.urdu],
        bio: 'Bio',
        teacherDetails:
            details ??
            const TeacherDetails(
              subjects: <Subject>[Subject.tajweed],
              experienceYears: 5,
              qualifications: 'Ijazah',
              feeAmount: 0,
              feeUnit: FeeUnit.perMonth,
              availableDays: <Weekday>{Weekday.monday},
              teaches: <TeachesAudience>{TeachesAudience.all},
            ),
      );

  Profile student({StudentDetails? details}) => Profile(
    id: 's',
    role: UserRole.student,
    fullName: 'Ayesha Khan',
    createdAt: created,
    gender: Gender.female,
    country: 'Pakistan',
    timeZone: 'GMT+5',
    languages: const <TeachingLanguage>[TeachingLanguage.urdu],
    studentDetails:
        details ??
        const StudentDetails(
          ageGroup: LearnerAgeGroup.adult,
          goals: <Subject>[Subject.nazra],
          level: LearnerLevel.beginner,
          preferredTeacherGender: TeacherGenderPreference.any,
        ),
  );

  test('a complete teacher is active without photo or certificate; fee 0 '
      'counts (free)', () {
    final t = teacher();
    expect(t.photoPath, isNull);
    expect(t.teacherDetails!.certificatePaths, isEmpty);
    expect(rules.isComplete(t), isTrue);
    expect(rules.firstIncompleteStep(t), isNull);
  });

  test('a complete student is active without photo, note or Looking', () {
    final s = student();
    expect(s.studentDetails!.lookingForTeacher, isFalse);
    expect(rules.isComplete(s), isTrue);
  });

  test('missing fields map to their setup step', () {
    final noHeadline = teacher(headline: ' ');
    expect(rules.missing(noHeadline), <RequiredField>[RequiredField.headline]);
    expect(rules.firstIncompleteStep(noHeadline), 0);

    final noTeaches = teacher(
      details: const TeacherDetails(
        subjects: <Subject>[Subject.tajweed],
        experienceYears: 5,
        qualifications: 'Ijazah',
        feeAmount: 20,
        availableDays: <Weekday>{Weekday.monday},
      ),
    );
    expect(rules.missing(noTeaches), <RequiredField>[RequiredField.teaches]);
    expect(rules.firstIncompleteStep(noTeaches), 2);
    expect(rules.missingInStep(noTeaches, 1), isEmpty);

    final noGoals = student(
      details: const StudentDetails(
        ageGroup: LearnerAgeGroup.child,
        level: LearnerLevel.beginner,
        preferredTeacherGender: TeacherGenderPreference.female,
      ),
    );
    expect(rules.missing(noGoals), <RequiredField>[RequiredField.goals]);
    expect(rules.firstIncompleteStep(noGoals), 1);
  });

  test('a profile without its detail row is incomplete', () {
    final bare = Profile(
      id: 'n',
      role: UserRole.student,
      fullName: 'New user',
      createdAt: created,
    );
    expect(rules.isComplete(bare), isFalse);
    expect(rules.firstIncompleteStep(bare), 0);
  });
}
