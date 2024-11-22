import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/connect/connect.dart';

part 'new_server_state.dart';

class NewServerCubit extends Cubit<NewServerState> {
  final ServersRepository _serversRepository;
  final Server? _server;

  NewServerCubit._({
    required ServersRepository serversRepository,
    Server? server,
    required NewServerState state,
  })  : _serversRepository = serversRepository,
        _server = server,
        super(state);

  NewServerCubit.add({required ServersRepository serversRepository})
      : this._(
          serversRepository: serversRepository,
          server: null,
          state: const NewServerState(),
        );

  NewServerCubit.edit({required ServersRepository serversRepository, required Server server})
      : this._(
          serversRepository: serversRepository,
          server: server,
          state: NewServerState.fromServer(server: server),
        );

  void onLabelChanged(String value) {
    final label = Label.dirty(value);

    emit(
      state.copyWith(
        label: label.isValid ? Label.pure(value) : label,
        isValid: Formz.validate([label, state.endpoint]),
      ),
    );
  }

  void onEndpointChanged(String value) {
    final endpoint = Endpoint.dirty(value);

    emit(
      state.copyWith(
        endpoint: endpoint.isValid ? Endpoint.pure(value) : endpoint,
        isValid: Formz.validate([state.label, endpoint]),
      ),
    );
  }

  Future<void> submitForm() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, error: null));

    final server = Server(
      id: _server?.id ?? UniqueKey().toString(),
      label: state.label.value,
      address: Uri.parse(state.endpoint.value),
    );

    try {
      await _serversRepository.saveServer(server);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, error: e));
    }
  }
}
