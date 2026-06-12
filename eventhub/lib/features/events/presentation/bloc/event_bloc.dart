import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';
import 'package:eventhub/features/events/domain/usecases/get_events_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_event_by_id_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/create_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/update_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/toggle_favorite_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_user_favorite_ids_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_invitations_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/create_invitation_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/delete_invitation_usecase.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;
  final GetEventByIdUseCase getEventByIdUseCase;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetUserFavoriteIdsUseCase getUserFavoriteIdsUseCase;
  final GetInvitationsUseCase getInvitationsUseCase;
  final CreateInvitationUseCase createInvitationUseCase;
  final DeleteInvitationUseCase deleteInvitationUseCase;

  EventBloc({
    required this.getEventsUseCase,
    required this.getEventByIdUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.toggleFavoriteUseCase,
    required this.getUserFavoriteIdsUseCase,
    required this.getInvitationsUseCase,
    required this.createInvitationUseCase,
    required this.deleteInvitationUseCase,
  }) : super(const EventInitial()) {
    on<GetEventsEvent>(_onGetEvents);
    on<GetEventByIdEvent>(_onGetEventById);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<GetUserFavoriteIdsEvent>(_onGetUserFavoriteIds);
    on<GetInvitationsEvent>(_onGetInvitations);
    on<CreateInvitationEvent>(_onCreateInvitation);
    on<DeleteInvitationEvent>(_onDeleteInvitation);
  }

  Future<void> _onGetEvents(GetEventsEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await getEventsUseCase.call(
      page: event.page,
      size: event.size,
      category: event.category,
      city: event.city,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      date: event.date,
      organizerId: event.organizerId,
    );
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (events) => emit(EventsLoaded(
        events: events,
        hasReachedMax: events.length < event.size,
      )),
    );
  }

  Future<void> _onGetEventById(
      GetEventByIdEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await getEventByIdUseCase.call(event.id);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventDetailLoaded(event: event)),
    );
  }

  Future<void> _onCreateEvent(
      CreateEventEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await createEventUseCase.call(event.event);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventCreated(event: event)),
    );
  }

  Future<void> _onUpdateEvent(
      UpdateEventEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await updateEventUseCase.call(event.event);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventUpdated(event: event)),
    );
  }

  Future<void> _onDeleteEvent(
      DeleteEventEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await deleteEventUseCase.call(event.id);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (_) => emit(const EventDeleted()),
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<EventState> emit) async {
    final result = await toggleFavoriteUseCase.call(event.eventId);
    result.fold(
      (failure) => null,
      (isFavorited) => emit(FavoriteToggled(
        isFavorite: isFavorited,
        eventId: event.eventId,
      )),
    );
  }

  Future<void> _onGetUserFavoriteIds(
      GetUserFavoriteIdsEvent event, Emitter<EventState> emit) async {
    final result = await getUserFavoriteIdsUseCase.call();
    result.fold(
      (failure) => null,
      (ids) => emit(FavoriteIdsLoadedState(ids: ids)),
    );
  }

  Future<void> _onGetInvitations(
      GetInvitationsEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());
    final result = await getInvitationsUseCase.call(event.eventId);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (invitations) => emit(InvitationsLoaded(invitations: invitations)),
    );
  }

  Future<void> _onCreateInvitation(
      CreateInvitationEvent event, Emitter<EventState> emit) async {
    final result = await createInvitationUseCase.call(
        event.eventId, event.email, event.name);
    await result.fold(
      (failure) async => emit(EventError(message: failure.message)),
      (_) async {
        final invitations = await getInvitationsUseCase.call(event.eventId);
        invitations.fold(
          (failure) => emit(EventError(message: failure.message)),
          (list) => emit(InvitationsLoaded(invitations: list)),
        );
      },
    );
  }

  Future<void> _onDeleteInvitation(
      DeleteInvitationEvent event, Emitter<EventState> emit) async {
    final result = await deleteInvitationUseCase.call(event.id);
    await result.fold(
      (failure) async => emit(EventError(message: failure.message)),
      (_) async {
        final invitations = await getInvitationsUseCase.call(event.eventId);
        invitations.fold(
          (failure) => emit(EventError(message: failure.message)),
          (list) => emit(InvitationsLoaded(invitations: list)),
        );
      },
    );
  }
}
