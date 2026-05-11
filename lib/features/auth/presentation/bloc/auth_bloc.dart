import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:plovy/features/auth/domain/entities/user.dart';
import 'package:plovy/features/auth/domain/repositories/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class RegisterEvent extends AuthEvent {
  const RegisterEvent({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginEvent extends AuthEvent {
  const LoginEvent({required this.email, required this.password});

  final String email;
  final String password;
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  final AuthRepository _authRepository;

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    if (!event.email.contains('@')) {
      emit(const AuthError('Email must contain @'));
      return;
    }

    try {
      await _authRepository.register(
        email: event.email.trim(),
        password: event.password,
      );
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final User user = await _authRepository.login(
        email: event.email.trim(),
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError(error.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final User? user = await _authRepository.getCurrentUser();

    if (user != null) {
      emit(AuthAuthenticated(user));
      return;
    }

    emit(const AuthUnauthenticated());
  }
}
