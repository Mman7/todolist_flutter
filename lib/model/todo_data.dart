class TodoData {
  bool isHighlight;
  String title;

  TodoData({required this.isHighlight, required this.title});

  factory TodoData.fromJson(Map<String, dynamic> json) {
    final dynamic rawHighlight = json['isHighlight'];
    final bool isHighlight =
        rawHighlight is String ? rawHighlight.toLowerCase() == 'true' : false;

    return TodoData(
      isHighlight: isHighlight,
      title: (json['title'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isHighlight': isHighlight,
      'title': title,
    };
  }
}
