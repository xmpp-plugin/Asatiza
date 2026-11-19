import 'package:equatable/equatable.dart';

import 'enums/fee_unit.dart';
import 'enums/subject.dart';
import 'enums/teaches_audience.dart';
import 'enums/weekday.dart';

/// Teacher-only profile data (plan table `teacher_details`).
class TeacherDetails extends Equatable {
  const TeacherDetails({
    this.subjects = const <Subject>[],
    this.experienceYears,
    this.qualifications,
    this.feeAmount,
    this.feeCurrency = 'PKR',
    this.feeUnit,
    this.availableDays = const <Weekday>{},
    this.availableFromMinutes,
    this.availableToMinutes,
    this.teaches = const <TeachesAudience>{},
    this.certificatePaths = const <String>[],
  });

  final List<Subject> subjects;
  final int? experienceYears;
  final String? qualifications;

  /// Whole currency units (e.g. 6000 = PKR 6,000).
  final int? feeAmount;
  final String feeCurrency;
  final FeeUnit? feeUnit;
  final Set<Weekday> availableDays;

  /// Minutes after midnight, local to the teacher's time zone.
  final int? availableFromMinutes;
  final int? availableToMinutes;
  final Set<TeachesAudience> teaches;

  /// Storage paths, never full URLs.
  final List<String> certificatePaths;

  TeacherDetails copyWith({
    List<Subject>? subjects,
    int? experienceYears,
    String? qualifications,
    int? feeAmount,
    String? feeCurrency,
    FeeUnit? feeUnit,
    Set<Weekday>? availableDays,
    int? availableFromMinutes,
    int? availableToMinutes,
    Set<TeachesAudience>? teaches,
    List<String>? certificatePaths,
  }) {
    return TeacherDetails(
      subjects: subjects ?? this.subjects,
      experienceYears: experienceYears ?? this.experienceYears,
      qualifications: qualifications ?? this.qualifications,
      feeAmount: feeAmount ?? this.feeAmount,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      feeUnit: feeUnit ?? this.feeUnit,
      availableDays: availableDays ?? this.availableDays,
      availableFromMinutes: availableFromMinutes ?? this.availableFromMinutes,
      availableToMinutes: availableToMinutes ?? this.availableToMinutes,
      teaches: teaches ?? this.teaches,
      certificatePaths: certificatePaths ?? this.certificatePaths,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    subjects,
    experienceYears,
    qualifications,
    feeAmount,
    feeCurrency,
    feeUnit,
    availableDays,
    availableFromMinutes,
    availableToMinutes,
    teaches,
    certificatePaths,
  ];
}
