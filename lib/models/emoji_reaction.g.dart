// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_reaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmojiReactionAdapter extends TypeAdapter<EmojiReaction> {
  @override
  final int typeId = 6;

  @override
  EmojiReaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmojiReaction(
      storeId: fields[0] as String,
      pageNumber: fields[1] as int,
      xNorm: fields[2] as double,
      yNorm: fields[3] as double,
      emojiType: fields[4] as EmojiType,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EmojiReaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.storeId)
      ..writeByte(1)
      ..write(obj.pageNumber)
      ..writeByte(2)
      ..write(obj.xNorm)
      ..writeByte(3)
      ..write(obj.yNorm)
      ..writeByte(4)
      ..write(obj.emojiType)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiReactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmojiTypeAdapter extends TypeAdapter<EmojiType> {
  @override
  final int typeId = 5;

  @override
  EmojiType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmojiType.heart;
      case 1:
        return EmojiType.thumbsUp;
      case 2:
        return EmojiType.neutral;
      case 3:
        return EmojiType.thumbsDown;
      default:
        return EmojiType.heart;
    }
  }

  @override
  void write(BinaryWriter writer, EmojiType obj) {
    switch (obj) {
      case EmojiType.heart:
        writer.writeByte(0);
        break;
      case EmojiType.thumbsUp:
        writer.writeByte(1);
        break;
      case EmojiType.neutral:
        writer.writeByte(2);
        break;
      case EmojiType.thumbsDown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
