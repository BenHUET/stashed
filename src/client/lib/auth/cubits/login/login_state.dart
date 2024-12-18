part of 'login_cubit.dart';

class LoginState extends Equatable {
  final Email email;
  final Password password;
  final bool isValid;
  final FormzSubmissionStatus status;
  final Object? error;

  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  LoginState copyWith({
    Email? email,
    Password? password,
    bool? isValid,
    FormzSubmissionStatus? status,
    Object? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [email, password, status, isValid, error];
}
