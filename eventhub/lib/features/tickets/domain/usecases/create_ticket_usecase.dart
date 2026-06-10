import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';

class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase({required this.repository});

  Future<Either<Failure, Ticket>> call({
    required String eventId,
    required String bookingId,
    String? eventTitle,
    String? eventDate,
    String? eventLocation,
    required String qrCode,
  }) {
    return repository.createTicket(
      eventId: eventId,
      bookingId: bookingId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventLocation: eventLocation,
      qrCode: qrCode,
    );
  }
}
