class TodoData {
  bool isHighlight;
  String title;

  TodoData({required this.isHighlight, required this.title});

  factory TodoData.fromJson(Map<String, dynamic> json) {
    final dynamic rawHighlight = json['isHighlight'];
    final bool isHighlight;
    
    if (rawHighlight is bool) {
      isHighlight = rawHighlight;
    } else if (rawHighlight is String) {
      isHighlight = rawHighlight.toLowerCase() == 'true';
    } else {
      isHighlight = false;
    }

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
