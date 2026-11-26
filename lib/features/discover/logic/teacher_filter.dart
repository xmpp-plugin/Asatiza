import 'package:equatable/equatable.dart';

import '../../../data/models/enums/experience_filter.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaches_audience.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';

/// Search and filters for the Teachers tab (student view). Pure value:
/// [apply] filters a list (no sort; order comes from `DailyShuffle`).
class TeacherFilter extends Equatable {
  const TeacherFilter({
    this.query = '',
    this.subjects = const <Subject>{},
    this.gender,
    this.languages = const <TeachingLanguage>{},
    this.feeMin = feeFloor,
    this.feeMax = feeCeiling,
    this.experience = ExperienceFilter.any,
    this.teachesChildren = false,
  });

  /// Monthly fee slider range, in US dollars.
  static const int feeFloor = 10;
  static const int feeCeiling = 100;
  static const String feeCurrency = 'USD';

  final String query;
  final Set<Subject> subjects;

  /// Null means any gender.
  final Gender? gender;
  final Set<TeachingLanguage> languages;
  final int feeMin;
  final int feeMax;
  final ExperienceFilter experience;
  final bool teachesChildren;

  bool get feeActive => feeMin != feeFloor || feeMax != feeCeiling;

  /// Number of active filters (the badge on the filter button); the search
  /// text is not counted.
  int get activeCount =>
      subjects.length +
      (gender == null ? 0 : 1) +
      languages.length +
      (feeActive ? 1 : 0) +
      (experience == ExperienceFilter.any ? 0 : 1) +
      (teachesChildren ? 1 : 0);

  /// [subjectLabel] turns a subject into the text searched by [query].
  bool matches(Profile p, String Function(Subject) subjectLabel) {
    final t = p.teacherDetails;
    if (t == null) {
      return false;
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = <String>[
        p.fullName,
        p.headline ?? '',
        ...t.subjects.map(subjectLabel),
      ].join(' ').toLowerCase();
      if (!haystack.contains(q)) {
        return false;
      }
    }
    if (subjects.isNotEmpty && !t.subjects.any(subjects.contains)) {
      return false;
    }
    if (gender != null && p.gender != gender) {
      return false;
    }
    if (languages.isNotEmpty && !p.languages.any(languages.contains)) {
      return false;
    }
    if (feeActive) {
      final fee = t.feeAmount;
      final comparable =
          fee != null &&
          t.feeCurrency == feeCurrency &&
          t.feeUnit == FeeUnit.perMonth;
      if (!comparable || fee < feeMin || fee > feeMax) {
        return false;
      }
    }
    if ((t.experienceYears ?? 0) < experience.minYears) {
      return false;
    }
    if (teachesChildren && !t.teaches.contains(TeachesAudience.children)) {
      return false;
    }
    return true;
  }

  /// The teachers matching search and filters, in the given order (the
  /// list order comes from `DailyShuffle`; Verified teachers get no
  /// priority).
  List<Profile> apply(
    Iterable<Profile> teachers,
    String Function(Subject) subjectLabel,
  ) => teachers.where((p) => matches(p, subjectLabel)).toList();

  TeacherFilter copyWith({
    String? query,
    Set<Subject>? subjects,
    Gender? Function()? gender,
    Set<TeachingLanguage>? languages,
    int? feeMin,
    int? feeMax,
    ExperienceFilter? experience,
    bool? teachesChildren,
  }) {
    return TeacherFilter(
      query: query ?? this.query,
      subjects: subjects ?? this.subjects,
      gender: gender != null ? gender() : this.gender,
      languages: languages ?? this.languages,
      feeMin: feeMin ?? this.feeMin,
      feeMax: feeMax ?? this.feeMax,
      experience: experience ?? this.experience,
      teachesChildren: teachesChildren ?? this.teachesChildren,
    );
  }

  /// Same search text, every filter cleared.
  TeacherFilter reset() => TeacherFilter(query: query);

  @override
  List<Object?> get props => <Object?>[
    query,
    subjects,
    gender,
    languages,
    feeMin,
    feeMax,
    experience,
    teachesChildren,
  ];
}
