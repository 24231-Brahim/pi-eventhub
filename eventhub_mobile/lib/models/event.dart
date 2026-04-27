class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? categoryName;
  final String organizerName;
  final String organizerEmail;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.categoryName,
    required this.organizerName,
    required this.organizerEmail,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        location: json['location'] as String,
        categoryName: json['categoryName'] as String?,
        organizerName: json['organizerName'] as String,
        organizerEmail: json['organizerEmail'] as String,
      );
}

class EventRequest {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int? categoryId;

  const EventRequest({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        if (categoryId != null) 'categoryId': categoryId,
      };
}
