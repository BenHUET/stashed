part of 'new_server_cubit.dart';

class NewServerState extends Equatable {
  final Label label;
  final Endpoint endpoint;
  final bool isValid;
  final FormzSubmissionStatus status;
  final Object? error;

  const NewServerState({
    this.label = const Label.pure(),
    this.endpoint = const Endpoint.pure(),
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
    this.error,
  });

  NewServerState.fromServer({required Server server})
      : label = Label.pure(server.label),
        endpoint = Endpoint.pure(server.address.toString()),
        isValid = true,
        status = FormzSubmissionStatus.initial,
        error = null;

  NewServerState copyWith({
    Label? label,
    Endpoint? endpoint,
    bool? isValid,
    FormzSubmissionStatus? status,
    Object? error,
  }) {
    return NewServerState(
      label: label ?? this.label,
      endpoint: endpoint ?? this.endpoint,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [label, endpoint, status, isValid, error];
}
