import 'package:flutter_bloc/flutter_bloc.dart';

// Events

abstract class RegisterFormEvent {
  const RegisterFormEvent();
}

class RegisterEmailChanged extends RegisterFormEvent {
  const RegisterEmailChanged(this.email);
  final String email;
}

class RegisterPasswordChanged extends RegisterFormEvent {
  const RegisterPasswordChanged(this.password);
  final String password;
}

class RegisterConfirmPasswordChanged extends RegisterFormEvent {
  const RegisterConfirmPasswordChanged(this.confirmPassword);
  final String confirmPassword;
}

// State

class RegisterFormState {
  const RegisterFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  final String email;
  final String password;
  final String confirmPassword;

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
  }) =>
      RegisterFormState(
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
      );
}

// Bloc

class RegisterFormBloc extends Bloc<RegisterFormEvent, RegisterFormState> {
  RegisterFormBloc() : super(const RegisterFormState()) {
    on<RegisterEmailChanged>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<RegisterPasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
    on<RegisterConfirmPasswordChanged>(
      (event, emit) =>
          emit(state.copyWith(confirmPassword: event.confirmPassword)),
    );
  }
}
