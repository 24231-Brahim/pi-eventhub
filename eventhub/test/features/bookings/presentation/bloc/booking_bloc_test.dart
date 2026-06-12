import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateBookingUseCase mockCreateBookingUseCase;
  late MockGetUserBookingsUseCase mockGetUserBookingsUseCase;
  late MockConfirmBookingUseCase mockConfirmBookingUseCase;
  late MockCancelBookingUseCase mockCancelBookingUseCase;

  setUp(() {
    mockCreateBookingUseCase = MockCreateBookingUseCase();
    mockGetUserBookingsUseCase = MockGetUserBookingsUseCase();
    mockConfirmBookingUseCase = MockConfirmBookingUseCase();
    mockCancelBookingUseCase = MockCancelBookingUseCase();
  });

  BookingBloc createBloc() => BookingBloc(
        createBookingUseCase: mockCreateBookingUseCase,
        getUserBookingsUseCase: mockGetUserBookingsUseCase,
        confirmBookingUseCase: mockConfirmBookingUseCase,
        cancelBookingUseCase: mockCancelBookingUseCase,
      );

  group('BookingBloc', () {
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingCreated] when createBooking succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreateBookingUseCase.call('1', 2, 50.0))
            .thenAnswer((_) async => const Right(tBooking));
        bloc.add(const CreateBookingEvent(eventId: '1', quantity: 2, amount: 50.0));
      },
      expect: () => [isA<BookingLoading>(), isA<BookingCreated>()],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingError] when createBooking fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreateBookingUseCase.call('1', 2, 50.0))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const CreateBookingEvent(eventId: '1', quantity: 2, amount: 50.0));
      },
      expect: () => [isA<BookingLoading>(), isA<BookingError>()],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, UserBookingsLoaded] when getUserBookings succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetUserBookingsUseCase.call())
            .thenAnswer((_) async => const Right([tBooking]));
        bloc.add(const GetUserBookingsEvent());
      },
      expect: () => [isA<BookingLoading>(), isA<UserBookingsLoaded>()],
    );

    blocTest<BookingBloc, BookingState>(
      'removes booking from list when cancelBooking succeeds',
      build: createBloc,
      seed: () => UserBookingsLoaded(bookings: const [tBooking]),
      act: (bloc) {
        when(() => mockCancelBookingUseCase.call('1'))
            .thenAnswer((_) async => const Right(null));
        bloc.add(const CancelBookingEvent(bookingId: '1'));
      },
      expect: () => [isA<BookingLoading>(), isA<UserBookingsLoaded>()],
      verify: (bloc) {
        final state = bloc.state as UserBookingsLoaded;
        expect(state.bookings.length, 0);
      },
    );
  });
}
