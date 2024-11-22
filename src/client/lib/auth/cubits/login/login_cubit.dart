import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:stashed/auth/auth.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  void onEmailChanged(String value) {
    final email = Email.dirty(value);

    emit(
      state.copyWith(
        email: email.isValid ? Email.pure(value) : email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);

    emit(
      state.copyWith(
        password: password.isValid ? Password.pure(value) : password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> submitForm() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, error: null));

    try {
      await _authRepository.login(state.email.value, state.password.value);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, error: e));
    }
  }
}
