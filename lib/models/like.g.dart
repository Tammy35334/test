// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LikeAdapter extends TypeAdapter<Like> {
  @override
  final int typeId = 2;

  @override
  Like read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Like(
      storeName: fields[0] as String,
      imageId: fields[1] as String,
      x: fields[2] as double,
      y: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Like obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.storeName)
      ..writeByte(1)
      ..write(obj.imageId)
      ..writeByte(2)
      ..write(obj.x)
      ..writeByte(3)
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
      storeName: json['storeName'] as String,
      imageId: json['imageId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'storeName': instance.storeName,
      'imageId': instance.imageId,
      'x': instance.x,
      'y': instance.y,
    };
