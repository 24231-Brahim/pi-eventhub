import 'package:eventhub/features/events/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    required super.date,
    super.endDate,
    required super.location,
    super.city,
    super.latitude,
    super.longitude,
    super.price,
    required super.maxParticipants,
    super.currentParticipants,
    required super.category,
    super.status,
    required super.organizerId,
    super.organizerName,
    super.isFeatured,
    super.isPrivate,
    super.rejectionReason,
    super.createdAt,
    super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      location: json['location'] as String,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: (json['currentParticipants'] as int?) ?? 0,
      category: _parseCategory(json['category'] as String),
      status: _parseStatus(json['status'] as String? ?? 'draft'),
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'category': category.name,
      'status': status.name,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'isFeatured': isFeatured,
      'isPrivate': isPrivate,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static EventCategory _parseCategory(String value) {
    return EventCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => EventCategory.conference,
    );
  }

  static EventStatus _parseStatus(String value) {
    return EventStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => EventStatus.draft,
    );
  }
}
