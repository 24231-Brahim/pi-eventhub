import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateBookingUseCase mockCreateBookingUseCase;
  late MockGetUserBookingsUseCase mockGetUserBookingsUseCase;

  setUp(() {
    mockCreateBookingUseCase = MockCreateBookingUseCase();
    mockGetUserBookingsUseCase = MockGetUserBookingsUseCase();
  });

  BookingBloc createBloc() => BookingBloc(
        createBookingUseCase: mockCreateBookingUseCase,
        getUserBookingsUseCase: mockGetUserBookingsUseCase,
      );

  group('BookingBloc', () {
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingCreated] when createBooking succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreateBookingUseCase.call('1', 2, 50.0))
            .thenAnswer((_) async => Right(tBooking));
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
            .thenAnswer((_) async => Right([tBooking]));
        bloc.add(const GetUserBookingsEvent());
      },
      expect: () => [isA<BookingLoading>(), isA<UserBookingsLoaded>()],
    );
  });
}
