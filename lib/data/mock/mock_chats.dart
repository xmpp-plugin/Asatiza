import '../models/conversation.dart';
import '../models/message.dart';
import 'mock_posts.dart';
import 'mock_profiles.dart';

/// Seed conversations and messages, created relative to [now]. Every pair is
/// an accepted connection in `buildMockConnections`.
({List<Conversation> conversations, List<Message> messages}) buildMockChats(
  DateTime now,
) {
  final conversations = <Conversation>[];
  final messages = <Message>[];
  var n = 0;

  void chat(
    String a,
    String b,
    Duration startedAgo,
    List<({String from, Duration ago, String? body, String? image, bool read})>
    items,
  ) {
    final id = 'chat-${conversations.length + 1}';
    conversations.add(
      Conversation(
        id: id,
        memberIds: <String>[a, b],
        startedAt: now.subtract(startedAgo),
      ),
    );
    for (final m in items) {
      n++;
      final sentAt = now.subtract(m.ago);
      messages.add(
        Message(
          id: 'message-$n',
          conversationId: id,
          senderId: m.from,
          sentAt: sentAt,
          body: m.body,
          imagePath: m.image,
          readAt: m.read ? sentAt.add(const Duration(minutes: 3)) : null,
        ),
      );
    }
  }

  ({String from, Duration ago, String? body, String? image, bool read}) msg(
    String from,
    Duration ago, {
    String? body,
    String? image,
    bool read = true,
  }) => (from: from, ago: ago, body: body, image: image, read: read);

  // Ayesha (student account)
  chat(MockIds.ayesha, MockIds.ahmed, const Duration(days: 3, hours: 2), [
    msg(
      MockIds.ayesha,
      const Duration(days: 3, minutes: 18),
      body:
          'Assalamu alaikum Ustadh! Is Thursday 5 pm okay for my first class?',
    ),
    msg(
      MockIds.ahmed,
      const Duration(days: 3, minutes: 8),
      body: 'Wa alaikum assalam! Yes, Thursday 5 pm (PKT) works well.',
    ),
    msg(
      MockIds.ahmed,
      const Duration(minutes: 42),
      image: MockImages.qaidaPage,
      body: 'Please practise this page before class.',
      read: false,
    ),
    msg(
      MockIds.ahmed,
      const Duration(minutes: 40),
      body: 'Here is the Zoom link for Thursday 5 pm:\nzoom.us/j/84213560921',
      read: false,
    ),
  ]);
  chat(MockIds.ayesha, MockIds.maryam, const Duration(days: 20), [
    msg(
      MockIds.maryam,
      const Duration(days: 20),
      body:
          'Assalamu alaikum Ayesha, welcome! We will start with the rules of '
          'noon sakinah.',
    ),
    msg(
      MockIds.ayesha,
      const Duration(days: 19, hours: 23),
      body: 'Wa alaikum assalam, I am looking forward to it.',
    ),
    msg(
      MockIds.maryam,
      const Duration(hours: 3, minutes: 10),
      body: 'JazakAllahu khairan, see you Monday',
      read: false,
    ),
  ]);
  chat(MockIds.ayesha, MockIds.khadija, const Duration(days: 13), [
    msg(
      MockIds.khadija,
      const Duration(days: 1, minutes: 30),
      body: 'Please send me a photo of the page you are reading.',
    ),
    msg(
      MockIds.ayesha,
      const Duration(days: 1, minutes: 10),
      image: MockImages.qaidaPage,
    ),
  ]);
  // Qari Ahmed (teacher account)
  chat(MockIds.hira, MockIds.ahmed, const Duration(days: 39), [
    msg(
      MockIds.hira,
      const Duration(days: 4),
      body: 'Which Qaida book are you using?',
      read: false,
    ),
  ]);
  chat(MockIds.ahmed, MockIds.yusuf, const Duration(days: 11), [
    msg(
      MockIds.yusuf,
      const Duration(days: 11),
      body:
          'Assalamu alaikum Qari sahib, my son is ready for his first lesson.',
    ),
    msg(
      MockIds.ahmed,
      const Duration(days: 10, hours: 23),
      body: 'Wa alaikum assalam! See you on Monday at 5 pm UK time.',
    ),
  ]);
  return (conversations: conversations, messages: messages);
}
