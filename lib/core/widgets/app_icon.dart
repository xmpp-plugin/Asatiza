import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A design icon from `assets/icons/` (24×24 stroke icons exported from the
/// design canvas). [color] fills `currentColor`; [strokeWidth] and
/// [fillColor] reproduce the per-use variants seen on the artboards.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.height,
    this.color,
    this.strokeWidth = 1.8,
    this.fillColor,
    this.semanticLabel,
  });

  // Icon names (files in assets/icons/).
  static const String ban = 'ban';
  static const String bell = 'bell';
  static const String bookOpen = 'book_open';
  static const String calendar = 'calendar';
  static const String camera = 'camera';
  static const String chat = 'chat';
  static const String check = 'check';
  static const String chevronDown = 'chevron_down';
  static const String chevronLeft = 'chevron_left';
  static const String chevronRight = 'chevron_right';
  static const String clock = 'clock';
  static const String close = 'close';
  static const String comment = 'comment';
  static const String document = 'document';
  static const String eye = 'eye';
  static const String flag = 'flag';
  static const String globe = 'globe';
  static const String graduationCap = 'graduation_cap';
  static const String heart = 'heart';
  static const String home = 'home';
  static const String image = 'image';
  static const String info = 'info';
  static const String keyIcon = 'key';
  static const String lock = 'lock';
  static const String logOut = 'log_out';
  static const String mail = 'mail';
  static const String mapPin = 'map_pin';
  static const String more = 'more';
  static const String pencil = 'pencil';
  static const String people = 'people';
  static const String plus = 'plus';
  static const String readTicks = 'read_ticks';
  static const String search = 'search';
  static const String send = 'send';
  static const String settings = 'settings';
  static const String share = 'share';
  static const String shield = 'shield';
  static const String sliders = 'sliders';
  static const String trash = 'trash';
  static const String upload = 'upload';
  static const String user = 'user';
  static const String userPlus = 'user_plus';

  final String name;

  /// Width (and height unless [height] is given), in logical pixels.
  final double size;
  final double? height;
  final Color? color;
  final double strokeWidth;
  final Color? fillColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF000000);
    final picture = SvgPicture(
      _IconLoader(
        'assets/icons/$name.svg',
        strokeWidth: strokeWidth,
        fillColor: fillColor,
        theme: SvgTheme(currentColor: resolved),
      ),
      width: size,
      height: height ?? size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    return picture;
  }
}

/// Loads an icon asset and applies the stroke width / fill override before
/// parsing. Equality covers every field, so the SVG cache keeps one entry
/// per variant.
@immutable
class _IconLoader extends SvgLoader<String> {
  const _IconLoader(
    this.assetName, {
    required this.strokeWidth,
    required this.fillColor,
    super.theme,
  });

  final String assetName;
  final double strokeWidth;
  final Color? fillColor;

  @override
  Future<String?> prepareMessage(BuildContext? context) {
    final bundle = context != null
        ? DefaultAssetBundle.of(context)
        : rootBundle;
    return bundle.loadString(assetName);
  }

  @override
  String provideSvg(String? message) {
    var svg = message!.replaceFirst(
      'stroke-width="1.8"',
      'stroke-width="${strokeWidth.toString()}"',
    );
    final fill = fillColor;
    if (fill != null) {
      final hex = fill
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2);
      svg = svg.replaceFirst('fill="none"', 'fill="#$hex"');
    }
    return svg;
  }

  @override
  bool operator ==(Object other) =>
      other is _IconLoader &&
      other.assetName == assetName &&
      other.strokeWidth == strokeWidth &&
      other.fillColor == fillColor &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(assetName, strokeWidth, fillColor, theme);
}
