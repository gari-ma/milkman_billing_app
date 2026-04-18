// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceModelAdapter extends TypeAdapter<PriceModel> {
  @override
  final int typeId = 1;

  @override
  PriceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceModel(
      fat: fields[0] as double?,
      snf: fields[1] as double?,
      price: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PriceModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fat)
      ..writeByte(1)
      ..write(obj.snf)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
