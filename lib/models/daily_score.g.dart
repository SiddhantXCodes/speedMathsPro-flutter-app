// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyScoreAdapter extends TypeAdapter<DailyScore> {
  @override
  final int typeId = 6;

  @override
  DailyScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DailyScore(
      date: fields[0] as DateTime? ?? DateTime.now(),
      score: (fields[1] ?? 0) is int
          ? fields[1] ?? 0
          : int.tryParse(fields[1]?.toString() ?? '0') ?? 0,
      totalQuestions: (fields[2] ?? 0) is int
          ? fields[2] ?? 0
          : int.tryParse(fields[2]?.toString() ?? '0') ?? 0,
      timeTakenSeconds: (fields[3] ?? 0) is int
          ? fields[3] ?? 0
          : int.tryParse(fields[3]?.toString() ?? '0') ?? 0,
      isRanked: fields[4] is bool
          ? fields[4] as bool
          : (fields[4]?.toString().toLowerCase() == 'true'),
    );
  }

  @override
  void write(BinaryWriter writer, DailyScore obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.totalQuestions)
      ..writeByte(3)
      ..write(obj.timeTakenSeconds)
      ..writeByte(4)
      ..write(obj.isRanked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
