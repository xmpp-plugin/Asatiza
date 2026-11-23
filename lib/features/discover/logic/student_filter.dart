import 'package:equatable/equatable.dart';

import '../../../core/logic/profile_strength_calculator.dart';
import '../../../data/models/enums/discover_sort.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';

/// Search and filters for the Students tab (teacher view). Pure value:
/// [apply] filters and orders a list (newest first by default).
class StudentFilter extends Equatable {
  const StudentFilter({
    this.query = '',
    this.subjects = const <Subject>{},
    this.gender,
    this.languages = const <TeachingLanguage>{},
    this.country,
    this.levels = const <LearnerLevel>{},
    this.ageGroups = const <LearnerAgeGroup>{},
    this.sort = DiscoverSort.newest,
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
  final DiscoverSort sort;

  /// Number of active filters (the badge on the filter button); search text
  /// and sort order are not counted.
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

  List<Profile> apply(
    Iterable<Profile> students,
    String Function(Subject) subjectLabel, {
    ProfileStrengthCalculator strength = const ProfileStrengthCalculator(),
  }) {
    final list = students.where((p) => matches(p, subjectLabel)).toList();
    switch (sort) {
      case DiscoverSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case DiscoverSort.recommended:
        final percent = <String, int>{
          for (final p in list) p.id: strength.percent(p),
        };
        list.sort((a, b) {
          final byPercent = percent[b.id]!.compareTo(percent[a.id]!);
          return byPercent != 0
              ? byPercent
              : b.createdAt.compareTo(a.createdAt);
        });
    }
    return list;
  }

  StudentFilter copyWith({
    String? query,
    Set<Subject>? subjects,
    Gender? Function()? gender,
    Set<TeachingLanguage>? languages,
    String? Function()? country,
    Set<LearnerLevel>? levels,
    Set<LearnerAgeGroup>? ageGroups,
    DiscoverSort? sort,
  }) {
    return StudentFilter(
      query: query ?? this.query,
      subjects: subjects ?? this.subjects,
      gender: gender != null ? gender() : this.gender,
      languages: languages ?? this.languages,
      country: country != null ? country() : this.country,
      levels: levels ?? this.levels,
      ageGroups: ageGroups ?? this.ageGroups,
      sort: sort ?? this.sort,
    );
  }

  /// Same search text, every filter cleared and the default order.
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
    sort,
  ];
}
