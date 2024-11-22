// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../dtos/queued_work_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueuedWorkResultDto _$QueuedWorkResultDtoFromJson(Map<String, dynamic> json) =>
    QueuedWorkResultDto(
      tasksIds:
          (json['tasksIds'] as List<dynamic>).map((e) => e as String).toSet(),
    );
