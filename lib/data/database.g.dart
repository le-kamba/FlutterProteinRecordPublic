// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordModelAdapter extends TypeAdapter<RecordModel> {
  @override
  final typeId = 1;

  @override
  RecordModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordModel(
      fields[0] as String,
      (fields[1] as List)?.cast<int>(),
      (fields[2] as List)?.cast<int>(),
      (fields[3] as List)?.cast<int>(),
      (fields[4] as List)?.cast<int>(),
      (fields[5] as List)?.cast<int>(),
      (fields[6] as List)?.cast<int>(),
      fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecordModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.meat)
      ..writeByte(2)
      ..write(obj.fish)
      ..writeByte(3)
      ..write(obj.milk)
      ..writeByte(4)
      ..write(obj.egg)
      ..writeByte(5)
      ..write(obj.soy)
      ..writeByte(6)
      ..write(obj.etc)
      ..writeByte(7)
      ..write(obj.wentWorkout);
  }
}
