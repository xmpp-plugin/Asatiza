import 'package:equatable/equatable.dart';

import '../../../data/models/connection.dart';
import '../../../data/models/profile.dart';
import '../logic/student_filter.dart';
import '../logic/teacher_filter.dart';

enum DiscoverStatus { loading, ready }

/// Teachers tab (student viewer) or Students tab (teacher viewer).
class DiscoverState extends Equatable {
  const DiscoverState({
    required this.showTeachers,
    this.status = DiscoverStatus.loading,
    this.all = const <Profile>[],
    this.results = const <Profile>[],
    this.teacherFilter = const TeacherFilter(),
    this.studentFilter = const StudentFilter(),
    this.connections = const <Connection>[],
  });

  /// True for the Teachers list, false for the Students list.
  final bool showTeachers;
  final DiscoverStatus status;

  /// Every visible person before search and filters.
  final List<Profile> all;

  /// [all] after search and filters, in list order.
  final List<Profile> results;
  final TeacherFilter teacherFilter;
  final StudentFilter studentFilter;

  /// The viewer's pending and accepted connections.
  final List<Connection> connections;

  int get activeFilterCount =>
      showTeachers ? teacherFilter.activeCount : studentFilter.activeCount;

  /// The viewer's connection with [profileId], if any.
  Connection? connectionWith(String profileId) {
    for (final c in connections) {
      if (c.involves(profileId)) {
        return c;
      }
    }
    return null;
  }

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Profile>? all,
    List<Profile>? results,
    TeacherFilter? teacherFilter,
    StudentFilter? studentFilter,
    List<Connection>? connections,
  }) {
    return DiscoverState(
      showTeachers: showTeachers,
      status: status ?? this.status,
      all: all ?? this.all,
      results: results ?? this.results,
      teacherFilter: teacherFilter ?? this.teacherFilter,
      studentFilter: studentFilter ?? this.studentFilter,
      connections: connections ?? this.connections,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    showTeachers,
    status,
    all,
    results,
    teacherFilter,
    studentFilter,
    connections,
  ];
}
