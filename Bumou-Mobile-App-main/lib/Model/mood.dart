class Mood {
  String? mood;
  num? percentage;

  Mood(String s, int i, {this.mood, this.percentage});

  Mood.fromJson(Map<String, dynamic> json) {
    mood = json['mood'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mood'] = mood;
    data['percentage'] = percentage != null ? '${percentage!.toStringAsFixed(0)}%' : null;
    return data;
  }
}
