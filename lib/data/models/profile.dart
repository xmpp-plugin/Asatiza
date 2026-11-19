import 'package:equatable/equatable.dart';

import 'enums/gender.dart';
import 'enums/teaching_language.dart';
import 'enums/user_role.dart';
import 'student_details.dart';
import 'teacher_details.dart';

/// A user's public profile (plan table `profiles`). Exactly one of
/// [teacherDetails] / [studentDetails] matches [role].
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.createdAt,
    this.email,
    this.headline,
    this.photoPath,
    this.gender,
    this.country,
    this.city,
    this.timeZone,
    this.languages = const <TeachingLanguage>[],
    this.bio,
    this.isVerified = false,
    this.teacherDetails,
    this.studentDetails,
  });

  /// UUID string (auth user id).
  final String id;
  final UserRole role;
  final String fullName;
  final DateTime createdAt;

  /// Only known for the signed-in user.
  final String? email;
  final String? headline;

  /// Storage path, never a full URL.
  final String? photoPath;
  final Gender? gender;
  final String? country;
  final String? city;

  /// Display form, e.g. "GMT+5".
  final String? timeZone;
  final List<TeachingLanguage> languages;
  final String? bio;

  /// Set by an admin only; the app never writes it.
  final bool isVerified;
  final TeacherDetails? teacherDetails;
  final StudentDetails? studentDetails;

  bool get isTeacher => role == UserRole.teacher;

  /// Up to two initials for the avatar, e.g. "Qari Ahmed Khan" → "AK".
  String get initials {
    const titles = <String>{
      'qari',
      'ustadh',
      'ustadha',
      'hafiz',
      'hafiza',
      'shaykh',
      'sheikh',
      'mufti',
      'maulana',
    };
    final words = fullName
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !titles.contains(w.toLowerCase()))
        .toList();
    if (words.isEmpty) {
      return '';
    }
    final first = words.first.characters.first;
    final last = words.length > 1 ? words.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  Profile copyWith({
    String? fullName,
    String? email,
    String? headline,
    String? photoPath,
    Gender? gender,
    String? country,
    String? city,
    String? timeZone,
    List<TeachingLanguage>? languages,
    String? bio,
    TeacherDetails? teacherDetails,
    StudentDetails? studentDetails,
  }) {
    return Profile(
      id: id,
      role: role,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt,
      email: email ?? this.email,
      headline: headline ?? this.headline,
      photoPath: photoPath ?? this.photoPath,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      timeZone: timeZone ?? this.timeZone,
      languages: languages ?? this.languages,
      bio: bio ?? this.bio,
      isVerified: isVerified,
      teacherDetails: teacherDetails ?? this.teacherDetails,
      studentDetails: studentDetails ?? this.studentDetails,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    role,
    fullName,
    createdAt,
    email,
    headline,
    photoPath,
    gender,
    country,
    city,
    timeZone,
    languages,
    bio,
    isVerified,
    teacherDetails,
    studentDetails,
  ];
}

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
