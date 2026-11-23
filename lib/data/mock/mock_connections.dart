import '../models/connection.dart';
import '../models/enums/connection_status.dart';
import 'mock_profiles.dart';

/// Seed connections, created relative to [now]. Accepted pairs match
/// `mockConnectedIds` (feed order); the student account has 2 requests and
/// 1 sent request, the teacher account has 2 requests.
List<Connection> buildMockConnections(DateTime now) {
  var n = 0;
  Connection c(
    String from,
    String to, {
    ConnectionStatus status = ConnectionStatus.accepted,
    required Duration ago,
    String? note,
  }) {
    n++;
    return Connection(
      id: 'connection-$n',
      requesterId: from,
      receiverId: to,
      status: status,
      createdAt: now.subtract(ago),
      note: note,
    );
  }

  return <Connection>[
    // Ayesha (student account)
    c(
      MockIds.ayesha,
      MockIds.ahmed,
      ago: const Duration(days: 3, hours: 3),
      note:
          'Assalamu alaikum! I’m looking for Tajweed classes 3 days a week, '
          'evenings Pakistan time.',
    ),
    c(MockIds.ayesha, MockIds.maryam, ago: const Duration(days: 21)),
    c(MockIds.khadija, MockIds.ayesha, ago: const Duration(days: 14)),
    c(
      MockIds.usman,
      MockIds.ayesha,
      status: ConnectionStatus.pending,
      ago: const Duration(hours: 5),
      note:
          'Assalamu alaikum Ayesha, I have evening slots for Tajweed '
          'revision if you are still looking.',
    ),
    c(
      MockIds.fatimaZahra,
      MockIds.ayesha,
      status: ConnectionStatus.pending,
      ago: const Duration(days: 1, hours: 3),
    ),
    c(
      MockIds.ayesha,
      MockIds.hafsa,
      status: ConnectionStatus.pending,
      ago: const Duration(days: 2),
      note: 'I would like to join your weekend Tajweed circle for sisters.',
    ),
    // Qari Ahmed (teacher account)
    c(MockIds.hira, MockIds.ahmed, ago: const Duration(days: 40)),
    c(MockIds.ahmed, MockIds.yusuf, ago: const Duration(days: 12)),
    c(
      MockIds.omar,
      MockIds.ahmed,
      status: ConnectionStatus.pending,
      ago: const Duration(hours: 2),
      note:
          'Assalamu alaikum Qari sahib, I am revising my first 10 juz and '
          'need someone to listen to my revision three times a week.',
    ),
    c(
      MockIds.hamid,
      MockIds.ahmed,
      status: ConnectionStatus.pending,
      ago: const Duration(days: 1),
      note:
          'Learning to read as an adult, weekends only. Do you take '
          'beginners?',
    ),
    // Other members
    c(MockIds.sana, MockIds.maryam, ago: const Duration(days: 30)),
    c(MockIds.zara, MockIds.khadija, ago: const Duration(days: 18)),
    c(MockIds.noor, MockIds.maryam, ago: const Duration(days: 9)),
    c(MockIds.ibrahim, MockIds.usman, ago: const Duration(days: 6)),
  ];
}
