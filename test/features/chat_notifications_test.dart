import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/session/shell_badges_cubit.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import '../fakes/mock_chat_repository.dart';
import '../fakes/mock_connection_repository.dart';
import 'package:asatiza/data/repositories/mock/mock_notification_repository.dart';
import '../fakes/mock_profile_repository.dart';
import 'package:asatiza/features/chat/bloc/chat_cubit.dart';
import 'package:asatiza/features/chat/presentation/chat_screen.dart';
import 'package:asatiza/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:asatiza/features/notifications/bloc/notifications_cubit.dart';
import 'package:asatiza/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:asatiza/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_app.dart';
import '../fakes/fake_block_repository.dart';
import 'package:asatiza/core/services/image_source_kind.dart';
import '../fakes/mock_media_repository.dart';
import 'package:asatiza/core/widgets/app_icon.dart';
import 'package:asatiza/data/models/message.dart';
import 'package:asatiza/features/chat/presentation/widgets/chat_bubble.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  setUpAll(() => initializeDateFormatting('en'));
  final now = DateTime(2026, 11, 23, 18);
  late MockProfileRepository profiles;
  late MockConnectionRepository connections;
  late MockChatRepository chats;
  late MockNotificationRepository notifications;

  setUp(() {
    profiles = MockProfileRepository(now: now);
    connections = MockConnectionRepository(profiles, now: now);
    chats = MockChatRepository(connections, now: now);
    notifications = MockNotificationRepository(now: now);
  });

  group('chat mock', () {
    test(
      'Ayesha has 3 chats, newest first, Qari Ahmed with 2 unread',
      () async {
        final list = await chats.watchConversations(MockIds.ayesha).first;
        expect(list, hasLength(3));
        expect(list.first.otherId(MockIds.ayesha), MockIds.ahmed);
        expect(list.first.unreadCount, 2);
      },
    );

    test('chat only between connections; empty messages rejected', () async {
      await expectLater(
        chats.openConversation(userId: MockIds.ayesha, otherId: MockIds.sana),
        throwsA(const ValidationFailure(ValidationReason.notConnected)),
      );
      final c = await chats.openConversation(
        userId: MockIds.ayesha,
        otherId: MockIds.ahmed,
      );
      await expectLater(
        chats.sendMessage(
          conversationId: c.id,
          senderId: MockIds.ayesha,
          body: '  ',
        ),
        throwsA(const ValidationFailure(ValidationReason.messageEmpty)),
      );
    });

    test('mark read clears the unread count', () async {
      final c = await chats.openConversation(
        userId: MockIds.ayesha,
        otherId: MockIds.ahmed,
      );
      await chats.markRead(conversationId: c.id, userId: MockIds.ayesha);
      final list = await chats.watchConversations(MockIds.ayesha).first;
      expect(list.first.unreadCount, 0);
    });

    test('accepting a request opens a new chat', () async {
      await connections.respond(
        connectionId: 'connection-9',
        userId: MockIds.ahmed,
        accept: true,
      );
      final c = await chats.openConversation(
        userId: MockIds.ahmed,
        otherId: MockIds.omar,
      );
      await chats.sendMessage(
        conversationId: c.id,
        senderId: MockIds.ahmed,
        body: 'Wa alaikum assalam Omar!',
      );
      final list = await chats.watchConversations(MockIds.ahmed).first;
      expect(list.first.otherId(MockIds.ahmed), MockIds.omar);
    });
  });

  group('cubits', () {
    test('badges count unread chats and notifications', () async {
      final cubit = ShellBadgesCubit(
        chats,
        notifications,
        viewerId: MockIds.ayesha,
      );
      await settle();
      expect(cubit.state.chats, 3);
      expect(cubit.state.alerts, 2);
      await notifications.markAllRead(MockIds.ayesha);
      await settle();
      expect(cubit.state.alerts, 0);
      await cubit.close();
    });

    ChatCubit chatCubit({
      String otherId = '',
      MockMediaRepository? media,
      FakeImagePicker? picker,
    }) => ChatCubit(
      chats,
      profiles,
      media: media ?? MockMediaRepository(),
      picker: picker ?? FakeImagePicker(),
      compressor: const FakeImageCompressor(),
      viewerId: MockIds.ayesha,
      otherId: otherId.isEmpty ? MockIds.ahmed : otherId,
    );

    test('chat cubit sends a photo; refuses over 2,000 characters', () async {
      final media = MockMediaRepository();
      final cubit = chatCubit(media: media);
      await settle();
      expect(await cubit.send(text: 'a' * 2001), isFalse);
      expect(cubit.state.error, ValidationReason.messageTooLong);
      cubit.errorShown();
      expect(await cubit.sendPhoto(ImageSourceKind.gallery), isTrue);
      await settle();
      final last = cubit.state.messages.last;
      expect(
        last.imagePath,
        startsWith('${MockIds.ayesha}/${cubit.state.conversation!.id}_'),
      );
      await cubit.close();
    });

    test('chat cubit: 30 photos a day, then a clear limit message', () async {
      final cubit = chatCubit();
      await settle();
      for (var i = 0; i < 30; i++) {
        expect(await cubit.sendPhoto(ImageSourceKind.gallery), isTrue);
      }
      expect(await cubit.sendPhoto(ImageSourceKind.gallery), isFalse);
      expect(cubit.state.error, ValidationReason.dailyPhotoLimit);
      cubit.errorShown();
      // Text still works after the photo limit.
      expect(await cubit.send(text: 'Text is still fine'), isTrue);
      await cubit.close();
    });

    test('ticks: one tick when sent, two when seen', () {
      final sent = Message(
        id: 'm',
        conversationId: 'c',
        senderId: MockIds.ayesha,
        sentAt: DateTime(2026, 11, 27),
      );
      final unread = ChatBubble.ticks(sent, Colors.white) as Opacity;
      expect((unread.child! as AppIcon).name, AppIcon.check);
      final seen = ChatBubble.ticks(
        sent.markRead(DateTime(2026, 11, 27, 1)),
        Colors.white,
      );
      expect((seen as AppIcon).name, AppIcon.readTicks);
    });

    test('chat cubit: removed connection opens read-only', () async {
      final cubit = chatCubit();
      await settle();
      expect(cubit.state.canSend, isTrue);
      final c = (await connections.watchConnections(MockIds.ayesha).first)
          .firstWhere((c) => c.involves(MockIds.ahmed));
      await connections.remove(connectionId: c.id, userId: MockIds.ayesha);
      await cubit.close();
      final readOnly = chatCubit();
      await settle();
      expect(readOnly.state.canSend, isFalse);
      expect(readOnly.state.messages, isNotEmpty);
      expect(await readOnly.send(text: 'Hello?'), isFalse);
      await readOnly.close();
    });

    test('chat cubit marks read and sends', () async {
      final cubit = chatCubit();
      await settle();
      expect(cubit.state.other?.id, MockIds.ahmed);
      expect(cubit.state.messages.where((m) => !m.isRead), isEmpty);
      expect(await cubit.send(text: 'JazakAllahu khairan, I will!'), isTrue);
      await settle();
      expect(cubit.state.messages.last.body, 'JazakAllahu khairan, I will!');
      await cubit.close();
    });

    test('notifications cubit accepts a request', () async {
      final cubit = NotificationsCubit(
        notifications,
        connections,
        profiles,
        FakeBlockRepository(),
        viewerId: MockIds.ahmed,
      );
      await settle();
      final omar = cubit.state.unread.firstWhere(
        (n) => n.actorId == MockIds.omar,
      );
      expect(cubit.state.isOpenRequest(omar), isTrue);
      expect(await cubit.respond(omar, accept: true), isTrue);
      await settle();
      final after = cubit.state.items.firstWhere((n) => n.id == omar.id);
      expect(after.read, isTrue);
      expect(cubit.state.isOpenRequest(after), isFalse);
      await cubit.close();
    });
  });

  group('time labels', () {
    final l10n = AppLocalizationsEn();
    test('chat list and notification times', () {
      expect(
        ConversationTile.timeLabel(DateTime(2026, 11, 23, 16, 16), l10n, now),
        '4:16 pm',
      );
      expect(
        ConversationTile.timeLabel(DateTime(2026, 11, 22, 9), l10n, now),
        'Yesterday',
      );
      expect(
        NotificationTile.ago(
          now.subtract(const Duration(minutes: 10)),
          l10n,
          now,
        ),
        '10 min ago',
      );
      expect(
        NotificationTile.ago(now.subtract(const Duration(days: 2)), l10n, now),
        '2 days ago',
      );
    });
  });

  group('screens', () {
    testWidgets('Chats → chat with Qari Ahmed: read, send, badge clears', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(find.bySemanticsLabel('Chats'));
      await tester.pumpAndSettle();
      expect(find.text('Qari Ahmed Khan'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ConversationTile).first,
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Qari Ahmed Khan'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('zoom.us/j/84213560921'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'JazakAllahu khairan!');
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      expect(find.text('JazakAllahu khairan!'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('You: JazakAllahu khairan!'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('teacher: accept a request from Notifications opens chat', (
      tester,
    ) async {
      final app = TestApp();
      await app.startSignedIn(tester, teacher: true);
      await tester.tap(find.bySemanticsLabel('Alerts'));
      await tester.pumpAndSettle();
      expect(find.text('New'), findsOneWidget);
      expect(
        find.textContaining('wants to connect', findRichText: true),
        findsNWidgets(2),
      );
      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Omar Farooq'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(find.text('New'), findsNothing);
      expect(find.text('Earlier'), findsOneWidget);
      await app.stop(tester);
    });

    testWidgets('Message before connecting stays disabled', (tester) async {
      final app = TestApp();
      await app.startSignedIn(tester);
      await tester.tap(find.bySemanticsLabel('Teachers'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Zainab');
      await tester.pumpAndSettle();
      await tapText(tester, 'View profile');
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsNothing);
      await app.stop(tester);
    });
  });
}
