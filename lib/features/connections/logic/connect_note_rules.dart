/// The optional note sent with a connection request.
class ConnectNoteRules {
  const ConnectNoteRules();

  /// Longest note, in characters.
  static const int maxLength = 200;

  /// Trimmed note, or null when it is empty.
  String? normalise(String? note) {
    final trimmed = note?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  bool isValid(String? note) => (normalise(note)?.length ?? 0) <= maxLength;
}
