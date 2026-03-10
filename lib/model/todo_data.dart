/// Simple model representing a todo item persisted by the app.
///
/// Fields:
/// - `isHighlight`: whether the task is marked as special/highlighted
/// - `title`: the visible text for the task
class TodoData {
  bool isHighlight;
  String title;

  TodoData({required this.isHighlight, required this.title});

  /// Construct a `TodoData` from a decoded JSON map.
  ///
  /// The `isHighlight` field can be stored as a boolean or as a
  /// string (e.g. "true"/"false"). This factory normalizes those
  /// cases and falls back to `false` for unexpected values.
  factory TodoData.fromJson(Map<String, dynamic> json) {
    // Expect `isHighlight` to be a boolean; default to false otherwise.
    final dynamic rawHighlight = json['isHighlight'];
    final bool isHighlight = rawHighlight is bool ? rawHighlight : false;

    return TodoData(
      isHighlight: isHighlight,
      title: (json['title'] ?? '').toString(),
    );
  }

  /// Convert the model to a JSON-compatible map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'isHighlight': isHighlight,
      'title': title,
    };
  }
}
