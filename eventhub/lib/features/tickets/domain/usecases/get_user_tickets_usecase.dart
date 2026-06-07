import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';

class GetUserTicketsUseCase {
  final TicketRepository repository;
  GetUserTicketsUseCase({required this.repository});

  Future<Either<Failure, List<Ticket>>> call() {
    return repository.getUserTickets();
  }
}
