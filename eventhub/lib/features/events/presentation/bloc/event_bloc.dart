import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/usecases/get_events_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_event_by_id_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/create_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/update_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/delete_event_usecase.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;
  final GetEventByIdUseCase getEventByIdUseCase;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;

  EventBloc({
    required this.getEventsUseCase,
    required this.getEventByIdUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
  }) : super(EventInitial()) {
    on<GetEventsEvent>(_onGetEvents);
    on<GetEventByIdEvent>(_onGetEventById);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
  }

  Future<void> _onGetEvents(GetEventsEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final result = await getEventsUseCase.call(
      page: event.page,
      size: event.size,
      category: event.category,
      city: event.city,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      date: event.date,
    );
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (events) => emit(EventsLoaded(events: events)),
    );
  }

  Future<void> _onGetEventById(
      GetEventByIdEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final result = await getEventByIdUseCase.call(event.id);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventDetailLoaded(event: event)),
    );
  }

  Future<void> _onCreateEvent(
      CreateEventEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final result = await createEventUseCase.call(event.event);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventCreated(event: event)),
    );
  }

  Future<void> _onUpdateEvent(
      UpdateEventEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final result = await updateEventUseCase.call(event.event);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (event) => emit(EventUpdated(event: event)),
    );
  }

  Future<void> _onDeleteEvent(
      DeleteEventEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    final result = await deleteEventUseCase.call(event.id);
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (_) => emit(EventDeleted()),
    );
  }
}
