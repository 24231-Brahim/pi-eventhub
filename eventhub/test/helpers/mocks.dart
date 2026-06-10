import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';
import 'package:eventhub/features/admin/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_all_events_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eventhub/core/network/network_info.dart';
import 'package:eventhub/core/errors/failures.dart';
export 'package:dartz/dartz.dart';
export 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/core/utils/token_manager.dart';
import 'package:eventhub/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventhub/features/auth/domain/usecases/login_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/register_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';
import 'package:eventhub/features/events/domain/usecases/get_events_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_event_by_id_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/create_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/update_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/toggle_favorite_usecase.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';
import 'package:eventhub/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:eventhub/features/tickets/domain/usecases/create_ticket_usecase.dart';
import 'package:eventhub/features/tickets/domain/usecases/get_user_tickets_usecase.dart';
import 'package:eventhub/features/tickets/domain/usecases/validate_ticket_usecase.dart';
import 'package:eventhub/features/payments/domain/entities/payment.dart';
import 'package:eventhub/features/payments/domain/repositories/payment_repository.dart';
import 'package:eventhub/features/payments/domain/usecases/create_payment_intent_usecase.dart';
import 'package:eventhub/features/payments/domain/usecases/confirm_payment_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MockAuthSupabaseDataSource extends Mock implements AuthSupabaseDataSource {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockTokenManager extends Mock implements TokenManager {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockEventRepository extends Mock implements EventRepository {}
class MockGetEventsUseCase extends Mock implements GetEventsUseCase {}
class MockGetEventByIdUseCase extends Mock implements GetEventByIdUseCase {}
class MockCreateEventUseCase extends Mock implements CreateEventUseCase {}
class MockUpdateEventUseCase extends Mock implements UpdateEventUseCase {}
class MockDeleteEventUseCase extends Mock implements DeleteEventUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

class MockBookingRepository extends Mock implements BookingRepository {}
class MockCreateBookingUseCase extends Mock implements CreateBookingUseCase {}
class MockGetUserBookingsUseCase extends Mock implements GetUserBookingsUseCase {}

class MockConnectivity extends Mock implements Connectivity {}

class MockAdminRepository extends Mock implements AdminRepository {}
class MockGetDashboardStatsUseCase extends Mock implements GetDashboardStatsUseCase {}
class MockGetAllEventsUseCase extends Mock implements GetAllEventsUseCase {}
class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockTicketRepository extends Mock implements TicketRepository {}
class MockCreateTicketUseCase extends Mock implements CreateTicketUseCase {}
class MockGetUserTicketsUseCase extends Mock implements GetUserTicketsUseCase {}
class MockValidateTicketUseCase extends Mock implements ValidateTicketUseCase {}

class MockPaymentRepository extends Mock implements PaymentRepository {}
class MockCreatePaymentIntentUseCase extends Mock implements CreatePaymentIntentUseCase {}
class MockConfirmPaymentUseCase extends Mock implements ConfirmPaymentUseCase {}

class SupabaseMock extends Mock implements SupabaseClient {
  @override
  GoTrueClient get auth => MockGoTrueClient();
}

class MockGoTrueClient extends Mock implements GoTrueClient {}

const tUser = User(
  id: '1',
  email: 'test@test.com',
  name: 'Test User',
  role: UserRole.participant,
);

final tEvent = Event(
  id: '1',
  title: 'Test Event',
  description: 'Test Description',
  date: DateTime(2026, 12, 25),
  location: 'Test Location',
  maxParticipants: 100,
  category: EventCategory.conference,
  organizerId: 'org1',
  organizerName: 'Organizer',
  price: 0,
  status: EventStatus.published,
);

const tBooking = Booking(
  id: '1',
  eventId: '1',
  userId: '1',
  eventTitle: 'Test Event',
  quantity: 2,
  totalAmount: 50.0,
  status: BookingStatus.confirmed,
);

const tTicket = Ticket(
  id: '1',
  eventId: '1',
  userId: '1',
  bookingId: '1',
  eventTitle: 'Test Event',
  eventDate: '2026-12-25',
  eventLocation: 'Test Location',
  qrCode: 'qr-test-123',
  status: TicketStatus.active,
);

const tPayment = Payment(
  id: '1',
  bookingId: '1',
  amount: 50.0,
  currency: 'TND',
  status: PaymentStatus.completed,
);

const tFailure = ServerFailure(message: 'Server error');
