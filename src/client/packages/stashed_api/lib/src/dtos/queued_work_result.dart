import 'package:json_annotation/json_annotation.dart';

part '../_generated/dtos/queued_work_result.g.dart';

@JsonSerializable(createToJson: false)
class QueuedWorkResultDto {
  final Set<String> tasksIds;

  const QueuedWorkResultDto({
    required this.tasksIds,
  });

  factory QueuedWorkResultDto.fromJson(Map<String, dynamic> json) => _$QueuedWorkResultDtoFromJson(json);
}
