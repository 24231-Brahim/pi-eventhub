import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';

abstract class TicketRepository {
  Future<Either<Failure, List<Ticket>>> getUserTickets();
  Future<Either<Failure, Ticket>> validateTicket(String qrData);
  Future<Either<Failure, Ticket>> createTicket({
    required String eventId,
    required String bookingId,
    String? eventTitle,
    String? eventDate,
    String? eventLocation,
    required String qrCode,
  });
}
