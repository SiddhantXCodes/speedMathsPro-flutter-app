// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizSessionModelAdapter extends TypeAdapter<QuizSessionModel> {
  @override
  final int typeId = 4;

  @override
  QuizSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizSessionModel(
      topic: fields[0] as String,
      category: fields[1] as String,
      correct: fields[2] as int,
      incorrect: fields[3] as int,
      score: fields[4] as int,
      total: fields[5] as int,
      avgTime: fields[6] as double,
      timeSpentSeconds: fields[7] as int,
      questions: (fields[8] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      userAnswers: (fields[9] as Map).cast<int, String>(),
      difficulty: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuizSessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.correct)
      ..writeByte(3)
      ..write(obj.incorrect)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.avgTime)
      ..writeByte(7)
      ..write(obj.timeSpentSeconds)
      ..writeByte(8)
      ..write(obj.questions)
      ..writeByte(9)
      ..write(obj.userAnswers)
      ..writeByte(10)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
