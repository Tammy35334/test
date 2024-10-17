// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreAdapter extends TypeAdapter<Store> {
  @override
  final int typeId = 1;

  @override
  Store read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Store(
      storeId: fields[0] as int,
      storeName: fields[1] as String,
      province: fields[2] as String,
      flyerImages: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Store obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.storeId)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.province)
      ..writeByte(3)
      ..write(obj.flyerImages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      storeId: (json['storeId'] as num).toInt(),
      storeName: json['storeName'] as String,
      province: json['province'] as String,
      flyerImages: (json['flyerImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'province': instance.province,
      'flyerImages': instance.flyerImages,
    };
