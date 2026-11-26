import 'package:equatable/equatable.dart';

import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';

/// Search and filters for the Students tab (teacher view). Pure value:
/// [apply] filters a list (no sort; order comes from `DailyShuffle`).
class StudentFilter extends Equatable {
  const StudentFilter({
    this.query = '',
    this.subjects = const <Subject>{},
    this.gender,
    this.languages = const <TeachingLanguage>{},
    this.country,
    this.levels = const <LearnerLevel>{},
    this.ageGroups = const <LearnerAgeGroup>{},
  });

  final String query;

  /// Subjects wanted.
  final Set<Subject> subjects;

  /// Null means any gender.
  final Gender? gender;
  final Set<TeachingLanguage> languages;

  /// Null means any country.
  final String? country;
  final Set<LearnerLevel> levels;
  final Set<LearnerAgeGroup> ageGroups;

  /// Number of active filters (the badge on the filter button); search text
  /// is not counted.
  int get activeCount =>
      subjects.length +
      (gender == null ? 0 : 1) +
      languages.length +
      (country == null ? 0 : 1) +
      levels.length +
      ageGroups.length;

  /// [subjectLabel] turns a subject into the text searched by [query].
  bool matches(Profile p, String Function(Subject) subjectLabel) {
    final s = p.studentDetails;
    if (s == null) {
      return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = <String>[
        p.fullName,
        s.note ?? '',
        ...s.goals.map(subjectLabel),
      ].join(' ').toLowerCase();
      if (!haystack.contains(q)) {
        return false;
      }
    }
    if (subjects.isNotEmpty && !s.goals.any(subjects.contains)) {
      return false;
    }
    if (gender != null && p.gender != gender) {
      return false;
    }
    if (languages.isNotEmpty && !p.languages.any(languages.contains)) {
      return false;
    }
    if (country != null && p.country != country) {
      return false;
    }
    if (levels.isNotEmpty && !levels.contains(s.level)) {
      return false;
    }
    if (ageGroups.isNotEmpty && !ageGroups.contains(s.ageGroup)) {
      return false;
    }
    return true;
  }

  /// The students matching search and filters, in the given order (the
  /// list order comes from `DailyShuffle`).
  List<Profile> apply(
    Iterable<Profile> students,
    String Function(Subject) subjectLabel,
  ) => students.where((p) => matches(p, subjectLabel)).toList();

  StudentFilter copyWith({
    String? query,
    Set<Subject>? subjects,
    Gender? Function()? gender,
    Set<TeachingLanguage>? languages,
    String? Function()? country,
    Set<LearnerLevel>? levels,
    Set<LearnerAgeGroup>? ageGroups,
  }) {
    return StudentFilter(
      query: query ?? this.query,
      subjects: subjects ?? this.subjects,
      gender: gender != null ? gender() : this.gender,
      languages: languages ?? this.languages,
      country: country != null ? country() : this.country,
      levels: levels ?? this.levels,
      ageGroups: ageGroups ?? this.ageGroups,
    );
  }

  /// Same search text, every filter cleared.
  StudentFilter reset() => StudentFilter(query: query);

  @override
  List<Object?> get props => <Object?>[
    query,
    subjects,
    gender,
    languages,
    country,
    levels,
    ageGroups,
  ];
}
