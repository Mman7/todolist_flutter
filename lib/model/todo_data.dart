/// Simple model representing a todo item persisted by the app.
///
/// Fields:
/// - `isHighlight`: whether the task is marked as special/highlighted
/// - `title`: the visible text for the task
class TodoItem {
  bool isHighlight;
  bool isCompleted = false;
  String title;
  DateTime dateTime;

  TodoItem(
      {required this.isHighlight,
      required this.title,
      required this.dateTime,
      this.isCompleted = false});

  /// Construct a `TodoData` from a decoded JSON map.
  ///
  /// The `isHighlight` field can be stored as a boolean or as a
  /// string (e.g. "true"/"false"). This factory normalizes those
  /// cases and falls back to `false` for unexpected values.
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    // Expect `isHighlight` to be a boolean; default to false otherwise.
    final dynamic rawHighlight = json['isHighlight'];
    final bool isHighlight = rawHighlight is bool ? rawHighlight : false;

    return TodoItem(
      isHighlight: isHighlight,
      title: (json['title'] ?? '').toString(),
      dateTime: DateTime.tryParse((json['dateTime'] ?? '').toString()) ??
          DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  updateText(String newText) {
    title = newText;
    _updateDateTime(DateTime.now());
  }

  _updateDateTime(DateTime newDateTime) {
    dateTime = newDateTime;
  }

  updateHighlight(bool newHighlight) {
    isHighlight = newHighlight;
  }

  updateCompleted(bool newCompleted) {
    isCompleted = newCompleted;
  }

  /// Convert the model to a JSON-compatible map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'isHighlight': isHighlight,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
