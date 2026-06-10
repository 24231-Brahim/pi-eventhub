import 'package:equatable/equatable.dart';

enum EventStatus { draft, published, cancelled, completed }
enum EventCategory {
  conference,
  concert,
  exhibition,
  training,
  workshop,
  sports,
  seminar,
  community
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final DateTime? endDate;
  final String location;
  final String? city;
  final double? latitude;
  final double? longitude;
  final double price;
  final int maxParticipants;
  final int currentParticipants;
  final EventCategory category;
  final EventStatus status;
  final String organizerId;
  final String? organizerName;
  final bool isFeatured;
  final bool isPrivate;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    this.endDate,
    required this.location,
    this.city,
    this.latitude,
    this.longitude,
    this.price = 0,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.category,
    this.status = EventStatus.draft,
    required this.organizerId,
    this.organizerName,
    this.isFeatured = false,
    this.isPrivate = false,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  bool get isFree => price == 0;
  bool get isFull => currentParticipants >= maxParticipants;
  bool get isPast => date.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        id, title, description, imageUrl, date, endDate, location,
        city, latitude, longitude, price, maxParticipants,
        currentParticipants, category, status, organizerId,
        organizerName, isFeatured, isPrivate, rejectionReason, createdAt, updatedAt,
      ];
}
