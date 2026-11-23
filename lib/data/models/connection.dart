import 'package:equatable/equatable.dart';

import 'enums/connection_status.dart';

/// A connection request between two users (mirrors the planned
/// `connections` table, plan section 12).
class Connection extends Equatable {
  const Connection({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String requesterId;
  final String receiverId;
  final ConnectionStatus status;
  final DateTime createdAt;

  /// Optional note sent with the request (at most 200 characters).
  final String? note;

  bool involves(String userId) => requesterId == userId || receiverId == userId;

  /// The other person in this connection, seen from [userId].
  String otherId(String userId) =>
      requesterId == userId ? receiverId : requesterId;

  Connection copyWith({ConnectionStatus? status}) {
    return Connection(
      id: id,
      requesterId: requesterId,
      receiverId: receiverId,
      status: status ?? this.status,
      createdAt: createdAt,
      note: note,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    requesterId,
    receiverId,
    status,
    createdAt,
    note,
  ];
}
