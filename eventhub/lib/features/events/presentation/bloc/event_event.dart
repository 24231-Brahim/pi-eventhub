part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class GetEventsEvent extends EventEvent {
  final int page;
  final int size;
  final String? category;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? date;
  final String? organizerId;

  const GetEventsEvent({
    this.page = 0,
    this.size = 20,
    this.category,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.date,
    this.organizerId,
  });

  @override
  List<Object?> get props =>
      [page, size, category, city, minPrice, maxPrice, date, organizerId];
}

class GetEventByIdEvent extends EventEvent {
  final String id;
  const GetEventByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateEventEvent extends EventEvent {
  final Event event;
  const CreateEventEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

class UpdateEventEvent extends EventEvent {
  final Event event;
  const UpdateEventEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

class DeleteEventEvent extends EventEvent {
  final String id;
  const DeleteEventEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleFavoriteEvent extends EventEvent {
  final String eventId;
  const ToggleFavoriteEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class GetUserFavoriteIdsEvent extends EventEvent {
  const GetUserFavoriteIdsEvent();
}

class GetInvitationsEvent extends EventEvent {
  final String eventId;
  const GetInvitationsEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class CreateInvitationEvent extends EventEvent {
  final String eventId;
  final String email;
  final String name;
  const CreateInvitationEvent({
    required this.eventId,
    required this.email,
    this.name = '',
  });

  @override
  List<Object?> get props => [eventId, email, name];
}

class DeleteInvitationEvent extends EventEvent {
  final String id;
  final String eventId;
  const DeleteInvitationEvent({required this.id, required this.eventId});

  @override
  List<Object?> get props => [id, eventId];
}


