import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';

class ValidateTicketUseCase {
  final TicketRepository repository;
  ValidateTicketUseCase({required this.repository});

  Future<Either<Failure, Ticket>> call(String qrData) {
    return repository.validateTicket(qrData);
  }
}
