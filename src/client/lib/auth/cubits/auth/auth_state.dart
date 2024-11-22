part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, unauthenticated, authenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState({this.status = AuthStatus.initial, this.user});

  AuthState copyWith({AuthStatus? status, ValueGetter<User?>? user}) {
    return AuthState(
      status: status ?? this.status,
      user: user != null ? user() : this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}
