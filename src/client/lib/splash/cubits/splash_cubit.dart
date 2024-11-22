import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servers_repository/servers_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final ServersRepository _serversRepository;
  final AuthRepository _authRepository;

  SplashCubit(this._serversRepository, this._authRepository) : super(const SplashState()) {
    initializeApp();
  }

  Future<void> initializeApp() async {
    emit(state.copyWith(status: SplashStatus.initializing));

    try {
      await _serversRepository.init();
      await _authRepository.init();
      emit(state.copyWith(status: SplashStatus.success));
    } catch (e) {
      emit(state.copyWith(status: SplashStatus.failure));
      addError(e);
    }
  }
}
