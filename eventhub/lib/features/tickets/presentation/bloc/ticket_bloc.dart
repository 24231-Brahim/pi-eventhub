import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/usecases/get_user_tickets_usecase.dart';
import 'package:eventhub/features/tickets/domain/usecases/validate_ticket_usecase.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final GetUserTicketsUseCase getUserTicketsUseCase;
  final ValidateTicketUseCase validateTicketUseCase;

  TicketBloc({
    required this.getUserTicketsUseCase,
    required this.validateTicketUseCase,
  }) : super(const TicketInitial()) {
    on<GetUserTicketsEvent>(_onGetUserTickets);
    on<ValidateTicketEvent>(_onValidateTicket);
  }

  Future<void> _onGetUserTickets(
      GetUserTicketsEvent event, Emitter<TicketState> emit) async {
    emit(const TicketLoading());
    final result = await getUserTicketsUseCase.call();
    result.fold(
      (failure) => emit(TicketError(message: failure.message)),
      (tickets) => emit(UserTicketsLoaded(tickets: tickets)),
    );
  }

  Future<void> _onValidateTicket(
      ValidateTicketEvent event, Emitter<TicketState> emit) async {
    emit(const TicketLoading());
    final result = await validateTicketUseCase.call(event.qrData);
    result.fold(
      (failure) => emit(TicketError(message: failure.message)),
      (ticket) => emit(TicketValidated(ticket: ticket)),
    );
  }
}
