import '../../../data/models/profile.dart';

/// Orders the Teachers / Students lists randomly, but the same way all day
/// for one viewer (plan section 7: random order, stable per user per day).
///
/// Each person gets a key from the viewer id, the viewer's local date and
/// their own id, so the order changes the next day and adding or removing
/// one person does not reshuffle the others. Verified people get no
/// priority. Pure Dart.
class DailyShuffle {
  const DailyShuffle({required this.viewerId, required this.day});

  final String viewerId;

  /// Only the year, month and day are used.
  final DateTime day;

  List<Profile> apply(Iterable<Profile> people) {
    final date =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final keys = <String, int>{
      for (final p in people) p.id: _fnv1a('$viewerId|$date|${p.id}'),
    };
    return people.toList()..sort((a, b) {
      final byKey = keys[a.id]!.compareTo(keys[b.id]!);
      return byKey != 0 ? byKey : a.id.compareTo(b.id);
    });
  }

  /// 32-bit FNV-1a: small, fast and identical on every platform.
  static int _fnv1a(String text) {
    var hash = 0x811c9dc5;
    for (final unit in text.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
