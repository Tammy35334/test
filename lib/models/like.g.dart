// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikeAdapter extends TypeAdapter<Like> {
  @override
  final int typeId = 0;

  @override
  Like read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Like(
      id: fields[0] as String,
      storeName: fields[1] as String,
      imageId: fields[2] as String,
      x: fields[3] as double,
      y: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Like obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.imageId)
      ..writeByte(3)
      ..write(obj.x)
      ..writeByte(4)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
