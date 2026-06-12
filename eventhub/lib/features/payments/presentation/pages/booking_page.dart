import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eventhub/core/di/injection_container.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/usecases/create_ticket_usecase.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';

class BookingPage extends StatefulWidget {
  final String eventId;
  const BookingPage({super.key, required this.eventId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _quantity = 1;
  bool _isProcessing = false;
  String _bookingId = '';
  Ticket? _createdTicket;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(GetEventByIdEvent(id: widget.eventId));
  }

  bool _validateBooking(Event event) {
    if (event.isPast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event has already passed.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (event.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event is fully booked.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (event.status != EventStatus.published) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event is not available for booking.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.id == event.organizerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot book your own event.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void _startBooking(double price) {
    if (_isProcessing) return;
    final eventState = context.read<EventBloc>().state;
    if (eventState is! EventDetailLoaded) return;
    if (!_validateBooking(eventState.event)) return;

    setState(() => _isProcessing = true);
    final total = price * _quantity;
    context
        .read<BookingBloc>()
        .add(CreateBookingEvent(
            eventId: widget.eventId, quantity: _quantity, amount: total));
  }

  Future<Ticket?> _createTicketForBooking() async {
    final eventState = context.read<EventBloc>().state;
    if (eventState is! EventDetailLoaded) return null;
    final event = eventState.event;
    final rand = Random();
    final qrCode =
        '${widget.eventId}-$_bookingId-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(999999)}';
    final result = await sl<CreateTicketUseCase>().call(
          eventId: widget.eventId,
          bookingId: _bookingId,
          eventTitle: event.title,
          eventDate: event.date.toIso8601String(),
          eventLocation: event.location,
          qrCode: qrCode,
        );
    return result.fold((_) => null, (ticket) => ticket);
  }

  Future<void> _confirmBooking() async {
    final ticket = await _createTicketForBooking();
    if (ticket == null || !mounted) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create ticket.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    _createdTicket = ticket;
    context
        .read<BookingBloc>()
        .add(ConfirmBookingEvent(bookingId: _bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Event')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookingBloc, BookingState>(
            listenWhen: (_, state) => state is BookingCreated,
            listener: (context, state) {
              if (state is BookingCreated) {
                _bookingId = state.booking.id;
                final total = state.booking.totalAmount;
                if (total <= 0) {
                  _confirmBooking();
                } else {
                  context.read<PaymentBloc>().add(CreatePaymentIntentEvent(
                        amount: total,
                        bookingId: _bookingId,
                      ));
                }
              }
            },
          ),
          BlocListener<BookingBloc, BookingState>(
            listenWhen: (_, state) => state is BookingConfirmed,
            listener: (context, state) {
              if (state is BookingConfirmed && mounted) {
                setState(() => _isProcessing = false);
                final ticket = _createdTicket;
                if (ticket != null) {
                  context.pushReplacement('/qr-code', extra: ticket);
                } else {
                  context.pop(true);
                }
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listenWhen: (_, state) => state is PaymentIntentCreated,
            listener: (context, state) {
              if (state is PaymentIntentCreated) {
                context.read<PaymentBloc>().add(ConfirmPaymentEvent(
                      paymentIntentId: state.clientSecret,
                      bookingId: _bookingId,
                    ));
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listenWhen: (_, state) => state is PaymentConfirmed,
            listener: (context, state) {
              _confirmBooking();
            },
          ),
          BlocListener<BookingBloc, BookingState>(
            listenWhen: (_, state) => state is BookingError,
            listener: (context, state) {
              setState(() => _isProcessing = false);
              if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listenWhen: (_, state) => state is PaymentError,
            listener: (context, state) {
              setState(() => _isProcessing = false);
              if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return const LoadingWidget();
            }
            if (state is EventError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<EventBloc>()
                    .add(GetEventByIdEvent(id: widget.eventId)),
              );
            }
            if (state is EventDetailLoaded) {
              final event = state.event;
              final total = event.price * _quantity;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Confirm your booking',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            _SummaryRow(
                                label: 'Date',
                                value: DateFormat('MMM d, yyyy')
                                    .format(event.date)),
                            _SummaryRow(
                                label: 'Location',
                                value: event.location),
                            if (event.city != null)
                              _SummaryRow(
                                  label: 'City', value: event.city!),
                            _SummaryRow(
                              label: 'Price per ticket',
                              value: event.isFree
                                  ? 'Free'
                                  : '${event.price.toStringAsFixed(2)} TND',
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Quantity'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: _quantity > 1
                                          ? () => setState(
                                              () => _quantity--)
                                          : null,
                                    ),
                                    Text('$_quantity'),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.add_circle_outline),
                                      onPressed: () =>
                                          setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!event.isFree) ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(
                                    '${total.toStringAsFixed(2)} TND',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<BookingBloc, BookingState>(
                      builder: (context, state) {
                        if (state is BookingLoading || _isProcessing) {
                          return const LoadingWidget();
                        }
                        return ElevatedButton(
                          onPressed: () => _startBooking(event.price),
                          child: Text(
                            event.isFree
                                ? 'Confirm Booking'
                                : 'Pay ${total.toStringAsFixed(2)} TND',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const LoadingWidget();
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
