part of 'event_bloc.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventsLoaded extends EventState {
  final List<Event> events;
  final bool hasReachedMax;
  const EventsLoaded({required this.events, this.hasReachedMax = false});

  @override
  List<Object?> get props => [events, hasReachedMax];
}

class EventDetailLoaded extends EventState {
  final Event event;
  const EventDetailLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventCreated extends EventState {
  final Event event;
  const EventCreated({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventUpdated extends EventState {
  final Event event;
  const EventUpdated({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventDeleted extends EventState {
  const EventDeleted();
}

class EventError extends EventState {
  final String message;
  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FavoriteToggled extends EventState {
  final bool isFavorite;
  final String eventId;
  const FavoriteToggled({required this.isFavorite, required this.eventId});

  @override
  List<Object?> get props => [isFavorite, eventId];
}

class FavoriteIdsLoadedState extends EventState {
  final List<String> ids;
  const FavoriteIdsLoadedState({required this.ids});

  @override
  List<Object?> get props => [ids];
}
