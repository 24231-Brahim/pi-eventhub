import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/tickets/data/datasources/ticket_supabase_datasource.dart';
import 'package:eventhub/features/tickets/data/models/ticket_model.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  TicketRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, List<Ticket>>> getUserTickets() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data = await dataSource.getUserTickets(userId);
      final tickets = data.map((e) => TicketModel.fromJson(e)).toList();
      return Right(tickets);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Ticket>> validateTicket(String qrData) async {
    try {
      final data = await dataSource.validateTicket(qrData);
      return Right(TicketModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
