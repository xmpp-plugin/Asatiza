import 'package:equatable/equatable.dart';

import 'enums/learner_age_group.dart';
import 'enums/learner_level.dart';
import 'enums/subject.dart';
import 'enums/teacher_gender_preference.dart';

/// Student-only profile data (plan table `student_details`).
class StudentDetails extends Equatable {
  const StudentDetails({
    this.ageGroup,
    this.goals = const <Subject>[],
    this.level,
    this.preferredTeacherGender,
    this.lookingForTeacher = false,
    this.note,
  });

  final LearnerAgeGroup? ageGroup;
  final List<Subject> goals;
  final LearnerLevel? level;
  final TeacherGenderPreference? preferredTeacherGender;
  final bool lookingForTeacher;
  final String? note;

  StudentDetails copyWith({
    LearnerAgeGroup? ageGroup,
    List<Subject>? goals,
    LearnerLevel? level,
    TeacherGenderPreference? preferredTeacherGender,
    bool? lookingForTeacher,
    String? note,
  }) {
    return StudentDetails(
      ageGroup: ageGroup ?? this.ageGroup,
      goals: goals ?? this.goals,
      level: level ?? this.level,
      preferredTeacherGender:
          preferredTeacherGender ?? this.preferredTeacherGender,
      lookingForTeacher: lookingForTeacher ?? this.lookingForTeacher,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    ageGroup,
    goals,
    level,
    preferredTeacherGender,
    lookingForTeacher,
    note,
  ];
}
