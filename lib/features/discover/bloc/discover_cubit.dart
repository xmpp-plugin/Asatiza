import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/discover_repository.dart';
import '../logic/daily_shuffle.dart';
import '../logic/student_filter.dart';
import '../logic/teacher_filter.dart';
import 'discover_state.dart';

/// Loads the listed teachers (student viewer) or students (teacher viewer),
/// orders them with [DailyShuffle] (random, stable for the day) and applies
/// search and filters through [TeacherFilter] / [StudentFilter].
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(
    this._discover,
    this._connections, {
    required this.viewerId,
    required bool showTeachers,
    required String Function(Subject) subjectLabel,
    DateTime? today,
  }) : _subjectLabel = subjectLabel,
       _order = DailyShuffle(viewerId: viewerId, day: today ?? DateTime.now()),
       super(DiscoverState(showTeachers: showTeachers)) {
    unawaited(_listenPeople());
    _listenConnections();
  }

  /// The viewer's pending / accepted connections (button states). A new
  /// subscription loads them again.
  void _listenConnections() {
    _connectionsSub = _connections.watchConnections(viewerId).listen((list) {
      if (!isClosed) {
        emit(state.copyWith(connections: list));
      }
    }, onError: (Object _) {});
  }

  final DiscoverRepository _discover;
  final ConnectionRepository _connections;
  final String viewerId;
  final String Function(Subject) _subjectLabel;
  final DailyShuffle _order;

  StreamSubscription<List<Profile>>? _peopleSub;
  StreamSubscription<List<Connection>>? _connectionsSub;

  /// Subscribes to the visible people. Completes on the first list or
  /// error (so pull-to-refresh can stop its spinner).
  Future<void> _listenPeople() {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    final people = state.showTeachers
        ? _discover.watchTeachers(viewerId: viewerId)
        : _discover.watchStudents(viewerId: viewerId);
    _peopleSub = people.listen(
      (list) {
        _emitFiltered(all: _order.apply(list), status: DiscoverStatus.ready);
        finish();
      },
      onError: (Object _) {
        if (!isClosed) {
          emit(state.copyWith(status: DiscoverStatus.error));
        }
        finish();
      },
      onDone: finish,
    );
    return done.future;
  }

  /// Reloads the list and the viewer's connections (pull-to-refresh and
  /// "Try again"), e.g. after the other person accepted on their device.
  /// Search and filters are kept. Shows the skeleton only after an error.
  Future<void> refresh() async {
    await _peopleSub?.cancel();
    await _connectionsSub?.cancel();
    if (isClosed) {
      return;
    }
    _listenConnections();
    if (state.status == DiscoverStatus.error) {
      emit(state.copyWith(status: DiscoverStatus.loading));
    }
    return _listenPeople();
  }

  void _emitFiltered({
    List<Profile>? all,
    DiscoverStatus? status,
    TeacherFilter? teacherFilter,
    StudentFilter? studentFilter,
  }) {
    if (isClosed) {
      return;
    }
    final people = all ?? state.all;
    final teachers = teacherFilter ?? state.teacherFilter;
    final students = studentFilter ?? state.studentFilter;
    emit(
      state.copyWith(
        status: status,
        all: people,
        teacherFilter: teachers,
        studentFilter: students,
        results: state.showTeachers
            ? teachers.apply(people, _subjectLabel)
            : students.apply(people, _subjectLabel),
      ),
    );
  }

  void queryChanged(String query) => state.showTeachers
      ? _emitFiltered(teacherFilter: state.teacherFilter.copyWith(query: query))
      : _emitFiltered(
          studentFilter: state.studentFilter.copyWith(query: query),
        );

  void teacherFilterChanged(TeacherFilter filter) =>
      _emitFiltered(teacherFilter: filter);

  void studentFilterChanged(StudentFilter filter) =>
      _emitFiltered(studentFilter: filter);

  /// Result count for a filter being edited in the filter sheet.
  int countTeachers(TeacherFilter filter) =>
      filter.apply(state.all, _subjectLabel).length;

  int countStudents(StudentFilter filter) =>
      filter.apply(state.all, _subjectLabel).length;

  /// Accepts a request the viewer received from [connection]'s requester.
  Future<void> accept(Connection connection) async {
    try {
      await _connections.respond(
        connectionId: connection.id,
        userId: viewerId,
        accept: true,
      );
    } on Failure {
      // Already answered elsewhere; the stream shows the current state.
    }
  }

  @override
  Future<void> close() async {
    await _peopleSub?.cancel();
    await _connectionsSub?.cancel();
    return super.close();
  }
}
