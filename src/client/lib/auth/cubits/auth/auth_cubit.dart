import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  void getUser() {
    emit(state.copyWith(status: AuthStatus.loading));

    _authRepository.getUser().listen((user) {
      if (user == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      } else {
        emit(state.copyWith(status: AuthStatus.authenticated, user: () => user));
      }
    }, onError: (_, __) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: () => null));
    });
  }

  Future<void> logout() async {
    _authRepository.logout();
  }
}
