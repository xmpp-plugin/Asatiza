import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';

/// Composition root: starts the app. Later phases create services and
/// repositories here and register them by interface type.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  runApp(const AsatizaApp());
}

/// The bundled fonts use the SIL Open Font License, which requires shipping
/// the license text; it appears on the app's licenses page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    const fonts = <String, String>{
      'Fraunces': 'assets/fonts/OFL-Fraunces.txt',
      'Plus Jakarta Sans': 'assets/fonts/OFL-PlusJakartaSans.txt',
      'Amiri': 'assets/fonts/OFL-Amiri.txt',
    };
    for (final entry in fonts.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}
