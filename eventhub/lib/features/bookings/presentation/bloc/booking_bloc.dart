import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/get_event_bookings_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/confirm_booking_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/cancel_booking_usecase.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;
  final GetEventBookingsUseCase getEventBookingsUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingBloc({
    required this.createBookingUseCase,
    required this.getUserBookingsUseCase,
    required this.getEventBookingsUseCase,
    required this.confirmBookingUseCase,
    required this.cancelBookingUseCase,
  }) : super(const BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<GetUserBookingsEvent>(_onGetUserBookings);
    on<GetEventBookingsEvent>(_onGetEventBookings);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  Future<void> _onCreateBooking(
      CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    final result = await createBookingUseCase.call(
        event.eventId, event.quantity, event.amount);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (booking) => emit(BookingCreated(booking: booking)),
    );
  }

  Future<void> _onGetUserBookings(
      GetUserBookingsEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    final result = await getUserBookingsUseCase.call();
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (bookings) => emit(UserBookingsLoaded(bookings: bookings)),
    );
  }

  Future<void> _onGetEventBookings(
      GetEventBookingsEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    final result = await getEventBookingsUseCase.call(event.eventId);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (bookings) => emit(EventBookingsLoaded(bookings: bookings)),
    );
  }

  Future<void> _onConfirmBooking(
      ConfirmBookingEvent event, Emitter<BookingState> emit) async {
    final result = await confirmBookingUseCase.call(event.bookingId);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (_) {
        emit(BookingConfirmed(
          booking: (state is BookingCreated)
              ? (state as BookingCreated).booking
              : Booking(id: event.bookingId, eventId: '', userId: ''),
        ));
      },
    );
  }

  Future<void> _onCancelBooking(
      CancelBookingEvent event, Emitter<BookingState> emit) async {
    final previousBookings = state is UserBookingsLoaded
        ? (state as UserBookingsLoaded).bookings
        : null;
    emit(const BookingLoading());
    final result = await cancelBookingUseCase.call(event.bookingId);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (_) {
        if (previousBookings != null) {
          final updated = previousBookings.where((b) => b.id != event.bookingId).toList();
          emit(UserBookingsLoaded(bookings: updated));
        } else {
          emit(const BookingInitial());
        }
      },
    );
  }
}
