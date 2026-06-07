part of 'ticket_bloc.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {
  const TicketInitial();
}

class TicketLoading extends TicketState {
  const TicketLoading();
}

class UserTicketsLoaded extends TicketState {
  final List<Ticket> tickets;
  const UserTicketsLoaded({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

class TicketValidated extends TicketState {
  final Ticket ticket;
  const TicketValidated({required this.ticket});

  @override
  List<Object?> get props => [ticket];
}

class TicketError extends TicketState {
  final String message;
  const TicketError({required this.message});

  @override
  List<Object?> get props => [message];
}
