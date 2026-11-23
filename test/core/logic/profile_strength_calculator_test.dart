import 'package:asatiza/core/logic/profile_strength_calculator.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/fee_unit.dart';
import 'package:asatiza/data/models/enums/subject.dart';
import 'package:asatiza/data/models/enums/teaching_language.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/enums/weekday.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:asatiza/data/models/student_details.dart';
import 'package:asatiza/data/models/teacher_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = ProfileStrengthCalculator();
  final now = DateTime(2026, 11, 19);

  Profile teacher({TeacherDetails details = const TeacherDetails()}) => Profile(
    id: 't',
    role: UserRole.teacher,
    fullName: 'Qari Ahmed Khan',
    createdAt: now,
    teacherDetails: details,
  );

  test('weights add up to 100 for both roles', () {
    int sum(Map<ProfileStrengthItem, int> m) =>
        m.values.fold(0, (a, b) => a + b);
    expect(sum(ProfileStrengthCalculator.teacherWeights), 100);
    expect(sum(ProfileStrengthCalculator.studentWeights), 100);
  });

  test('new teacher is 0%; photo + headline is 25% (artboard 07a)', () {
    expect(calculator.percent(teacher()), 0);
    final withHeadline = teacher().copyWith(
      photoPath: 'avatars/t/p.jpg',
      headline: 'Hafiz & Tajweed teacher',
    );
    expect(calculator.percent(withHeadline), 25);
    expect(
      calculator.missing(withHeadline).first,
      ProfileStrengthItem.subjects,
    );
  });

  test('complete teacher is 100% with nothing missing', () {
    final full =
        teacher(
          details: const TeacherDetails(
            subjects: [Subject.tajweed],
            experienceYears: 8,
            qualifications: 'Ijazah in Hafs an Asim',
            feeAmount: 40,
            feeUnit: FeeUnit.perMonth,
            availableDays: {Weekday.monday},
            certificatePaths: ['certificates/t/1.pdf'],
          ),
        ).copyWith(
          photoPath: 'p',
          headline: 'h',
          bio: 'b',
          languages: const [TeachingLanguage.urdu],
        );
    expect(calculator.percent(full), 100);
    expect(calculator.missing(full), isEmpty);
  });

  test('experience counts only with qualifications (plan section 7)', () {
    final yearsOnly = teacher(
      details: const TeacherDetails(experienceYears: 8),
    );
    expect(
      calculator.missing(yearsOnly),
      contains(ProfileStrengthItem.experience),
    );
    final both = teacher(
      details: const TeacherDetails(
        experienceYears: 8,
        qualifications: 'Hafiz',
      ),
    );
    expect(
      calculator.missing(both),
      isNot(contains(ProfileStrengthItem.experience)),
    );
  });

  test('Qari Ahmed (mock) is 90%, missing only qualifications (20c)', () {
    final ahmed = buildMockProfiles(
      DateTime(2026),
    ).firstWhere((p) => p.id == MockIds.ahmed);
    expect(calculator.percent(ahmed), 90);
    expect(calculator.missing(ahmed), <ProfileStrengthItem>[
      ProfileStrengthItem.experience,
    ]);
  });

  test('fee without days does not count fee + availability', () {
    final t = teacher(details: const TeacherDetails(feeAmount: 6000));
    expect(
      calculator.missing(t),
      contains(ProfileStrengthItem.feeAndAvailability),
    );
  });

  test('Ayesha (mock) matches the Home artboard: 65%, goal first, 2 left', () {
    final ayesha = buildMockProfiles(
      now,
    ).firstWhere((p) => p.id == MockIds.ayesha);
    expect(calculator.percent(ayesha), 65);
    final missing = calculator.missing(ayesha);
    expect(missing.first, ProfileStrengthItem.learningGoals);
    expect(missing.length, 2);
  });

  test('student note counts for photo-or-note', () {
    final s = Profile(
      id: 's',
      role: UserRole.student,
      fullName: 'Hira Baig',
      createdAt: now,
      studentDetails: const StudentDetails(note: 'Evenings please'),
    );
    expect(
      calculator.missing(s),
      isNot(contains(ProfileStrengthItem.photoOrNote)),
    );
  });
}
