import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// Elevation tokens of the Asatiza design system.
abstract final class AppShadows {
  /// `shadow-card`: cards at rest (none in dark mode).
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const <BoxShadow>[];
    }
    return const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(28, 36, 33, 0.06),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ];
  }

  /// `shadow-raised`: bottom sheets, the floating Post button, menus.
  static List<BoxShadow> raised(Brightness brightness) {
    return <BoxShadow>[
      BoxShadow(
        color: brightness == Brightness.dark
            ? const Color.fromRGBO(0, 0, 0, 0.5)
            : const Color.fromRGBO(28, 36, 33, 0.12),
        offset: const Offset(0, 8),
        blurRadius: 24,
      ),
    ];
  }
}
