import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const GetUserBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookings)),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingWidget();
          }
          if (state is BookingError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<BookingBloc>().add(const GetUserBookingsEvent()),
            );
          }
          if (state is UserBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return EmptyWidget(message: l10n.noNotifications);
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      booking.status.name == 'confirmed'
                          ? Icons.check_circle
                          : Icons.pending,
                      color: booking.status.name == 'confirmed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(booking.eventTitle ?? 'Event'),
                    subtitle: Text(
                      '${booking.quantity} x ${booking.totalAmount} TND\n${booking.status.name}',
                    ),
                    trailing: booking.status.name != 'cancelled'
                        ? IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () {
                              context.read<BookingBloc>().add(
                                    CancelBookingEvent(bookingId: booking.id),
                                  );
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
