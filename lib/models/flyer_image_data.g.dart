// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flyer_image_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlyerImageDataAdapter extends TypeAdapter<FlyerImageData> {
  @override
  final int typeId = 2;

  @override
  FlyerImageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlyerImageData(
      url: fields[0] as String,
      imageBytes: (fields[1] as List).cast<int>(),
      lastUpdated: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FlyerImageData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.imageBytes)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyerImageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
