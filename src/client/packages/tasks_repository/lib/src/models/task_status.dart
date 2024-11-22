enum TaskStatus {
  created(0),
  queued(1),
  running(2),
  completed(3),
  failed(4),
  ignored(5),
  canceled(6),
  partiallyFailed(7);

  final int value;
  const TaskStatus(
    this.value,
  );

  static TaskStatus getByValue(int value) {
    return TaskStatus.values.firstWhere((x) => x.value == value);
  }
}
