import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/core/network/api_client.dart';
import 'package:eventhub/core/network/network_info.dart';
import 'package:eventhub/core/utils/token_manager.dart';
import 'package:eventhub/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:eventhub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eventhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventhub/features/auth/domain/usecases/login_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/register_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/events/data/datasources/event_remote_datasource.dart';
import 'package:eventhub/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';
import 'package:eventhub/features/events/domain/usecases/get_events_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/create_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/update_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:eventhub/features/events/domain/usecases/get_event_by_id_usecase.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/bookings/data/datasources/booking_remote_datasource.dart';
import 'package:eventhub/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:eventhub/features/bookings/domain/repositories/booking_repository.dart';
import 'package:eventhub/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:eventhub/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/tickets/data/datasources/ticket_remote_datasource.dart';
import 'package:eventhub/features/tickets/data/repositories/ticket_repository_impl.dart';
import 'package:eventhub/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:eventhub/features/tickets/domain/usecases/get_user_tickets_usecase.dart';
import 'package:eventhub/features/tickets/domain/usecases/validate_ticket_usecase.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:eventhub/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:eventhub/features/payments/domain/repositories/payment_repository.dart';
import 'package:eventhub/features/payments/domain/usecases/create_payment_intent_usecase.dart';
import 'package:eventhub/features/payments/domain/usecases/confirm_payment_usecase.dart';
import 'package:eventhub/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:eventhub/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:eventhub/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:eventhub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:eventhub/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:eventhub/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eventhub/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:eventhub/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:eventhub/features/profile/domain/repositories/profile_repository.dart';
import 'package:eventhub/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:eventhub/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:eventhub/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initCore();
  _initAuth();
  _initEvents();
  _initBookings();
  _initTickets();
  _initPayments();
  _initNotifications();
  _initProfile();
}

void _initCore() {
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(storage: sl()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenManager: sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: Connectivity()),
  );
}

void _initAuth() {
  sl.registerLazySingleton<AuthSupabaseDataSource>(
    () => AuthSupabaseDataSourceImpl(
      auth: Supabase.instance.client.auth,
      supabase: Supabase.instance.client,
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        forgotPasswordUseCase: sl(),
        logoutUseCase: sl(),
      ));
}

void _initEvents() {
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetEventsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetEventByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateEventUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteEventUseCase(repository: sl()));
  sl.registerFactory(() => EventBloc(
        getEventsUseCase: sl(),
        getEventByIdUseCase: sl(),
        createEventUseCase: sl(),
        updateEventUseCase: sl(),
        deleteEventUseCase: sl(),
      ));
}

void _initBookings() {
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateBookingUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUserBookingsUseCase(repository: sl()));
  sl.registerFactory(() => BookingBloc(
        createBookingUseCase: sl(),
        getUserBookingsUseCase: sl(),
      ));
}

void _initTickets() {
  sl.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetUserTicketsUseCase(repository: sl()));
  sl.registerLazySingleton(() => ValidateTicketUseCase(repository: sl()));
  sl.registerFactory(() => TicketBloc(
        getUserTicketsUseCase: sl(),
        validateTicketUseCase: sl(),
      ));
}

void _initPayments() {
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreatePaymentIntentUseCase(repository: sl()));
  sl.registerLazySingleton(() => ConfirmPaymentUseCase(repository: sl()));
  sl.registerFactory(() => PaymentBloc(
        createPaymentIntentUseCase: sl(),
        confirmPaymentUseCase: sl(),
      ));
}

void _initNotifications() {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(repository: sl()));
  sl.registerFactory(() => NotificationBloc(
        getNotificationsUseCase: sl(),
      ));
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(repository: sl()));
  sl.registerFactory(() => ProfileBloc(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));
}
