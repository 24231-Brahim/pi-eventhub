part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final String eventId;
  final int quantity;
  final double amount;
  const CreateBookingEvent({
    required this.eventId,
    required this.quantity,
    required this.amount,
  });

  @override
  List<Object?> get props => [eventId, quantity, amount];
}

class GetUserBookingsEvent extends BookingEvent {
  const GetUserBookingsEvent();
}

class ConfirmBookingEvent extends BookingEvent {
  final String bookingId;
  const ConfirmBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  const CancelBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
