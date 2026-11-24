import 'dart:typed_data';

import 'package:asatiza/core/theme/app_theme.dart';
import 'package:asatiza/core/widgets/app_avatar.dart';
import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final profile = Profile(
    id: 'user-1',
    role: UserRole.teacher,
    fullName: 'Qari Ahmed Khan',
    createdAt: DateTime(2026),
  );

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('no photo: initials', (tester) async {
    await pump(tester, AppAvatar(profile: profile));
    expect(find.text('AK'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('photo URL: network image, initials while loading', (
    tester,
  ) async {
    await pump(
      tester,
      AppAvatar(
        profile: profile.copyWith(
          photoPath: 'user-1/avatar-1.jpg',
          photoUrl: 'https://example.test/avatars/user-1/avatar-1.jpg',
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    // Tests make no network calls: the frame never arrives, so the
    // initials stay as the placeholder.
    expect(find.text('AK'), findsOneWidget);
  });

  testWidgets('showPhoto false: initials even with a photo', (tester) async {
    await pump(
      tester,
      AppAvatar(
        profile: profile.copyWith(photoUrl: 'https://example.test/a.jpg'),
        showPhoto: false,
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.text('AK'), findsOneWidget);
  });

  testWidgets('preview bytes win over the stored photo', (tester) async {
    await pump(
      tester,
      AppAvatar(
        profile: profile.copyWith(photoUrl: 'https://example.test/a.jpg'),
        preview: Uint8List.fromList(<int>[1, 2, 3]),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });
}
