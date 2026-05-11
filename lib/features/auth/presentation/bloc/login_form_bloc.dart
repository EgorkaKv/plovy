import 'package:flutter_bloc/flutter_bloc.dart';

// Events

abstract class LoginFormEvent {
  const LoginFormEvent();
}

class LoginEmailChanged extends LoginFormEvent {
  const LoginEmailChanged(this.email);
  final String email;
}

class LoginPasswordChanged extends LoginFormEvent {
  const LoginPasswordChanged(this.password);
  final String password;
}

// State

class LoginFormState {
  const LoginFormState({this.email = '', this.password = ''});

  final String email;
  final String password;

  LoginFormState copyWith({String? email, String? password}) => LoginFormState(
        email: email ?? this.email,
        password: password ?? this.password,
      );
}

// Bloc

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc() : super(const LoginFormState()) {
    on<LoginEmailChanged>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<LoginPasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
  }
}
