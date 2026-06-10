import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/cancel_booking_usecase.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingBloc({
    required this.createBookingUseCase,
    required this.getUserBookingsUseCase,
    required this.cancelBookingUseCase,
  }) : super(const BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<GetUserBookingsEvent>(_onGetUserBookings);
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
