// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawn_line.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawnLineAdapter extends TypeAdapter<DrawnLine> {
  @override
  final int typeId = 2;

  @override
  DrawnLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawnLine(
      points: (fields[0] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, DrawnLine obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawnLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
