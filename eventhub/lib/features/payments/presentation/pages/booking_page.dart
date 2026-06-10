import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eventhub/core/di/injection_container.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/payments/presentation/bloc/payment_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(GetEventByIdEvent(id: widget.eventId));
  }

  void _startBooking(double price) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final total = price * _quantity;
    context
        .read<BookingBloc>()
        .add(CreateBookingEvent(
            eventId: widget.eventId, quantity: _quantity, amount: total));
  }

  void _createTicketForBooking(BuildContext context) {
    final eventState = context.read<EventBloc>().state;
    if (eventState is EventDetailLoaded) {
      final event = eventState.event;
      final rand = Random();
      final qrCode =
          '${widget.eventId}-$_bookingId-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(999999)}';
      sl<CreateTicketUseCase>().call(
            eventId: widget.eventId,
            bookingId: _bookingId,
            eventTitle: event.title,
            eventDate: event.date.toIso8601String(),
            eventLocation: event.location,
            qrCode: qrCode,
          );
    }
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
                final total = state.booking.totalAmount;
                _bookingId = state.booking.id;
                context.read<PaymentBloc>().add(CreatePaymentIntentEvent(
                      amount: total,
                      bookingId: _bookingId,
                    ));
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
              _createTicketForBooking(context);
              setState(() => _isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment successful! Booking confirmed.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
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
