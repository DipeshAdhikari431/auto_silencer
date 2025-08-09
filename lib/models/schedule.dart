
class Schedule {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? title;

  Schedule(this.startDateTime, this.endDateTime, {this.title});

  Map<String, dynamic> toJson() => {
    'startDateTime': startDateTime.toIso8601String(),
    'endDateTime': endDateTime.toIso8601String(),
    'title': title,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      DateTime.parse(json['startDateTime']),
      DateTime.parse(json['endDateTime']),
      title: json['title'],
    );
  }
}
