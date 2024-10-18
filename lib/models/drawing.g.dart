// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingAdapter extends TypeAdapter<Drawing> {
  @override
  final int typeId = 3;

  @override
  Drawing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drawing(
      id: fields[0] as String,
      imageId: fields[1] as String,
      centerX: fields[2] as double,
      centerY: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Drawing obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageId)
      ..writeByte(2)
      ..write(obj.centerX)
      ..writeByte(3)
      ..write(obj.centerY);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
