import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/login_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:eventhub/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await loginUseCase.call(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await registerUseCase.call(
        event.name, event.email, event.password, event.role);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await forgotPasswordUseCase.call(event.email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await logoutUseCase.call();
    result.fold(
      (failure) => emit(const AuthError(message: 'Logout failed')),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase.call();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user: user)),
    );
  }
}
