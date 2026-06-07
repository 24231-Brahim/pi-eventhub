part of 'ticket_bloc.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class GetUserTicketsEvent extends TicketEvent {
  const GetUserTicketsEvent();
}

class ValidateTicketEvent extends TicketEvent {
  final String qrData;
  const ValidateTicketEvent({required this.qrData});

  @override
  List<Object?> get props => [qrData];
}
