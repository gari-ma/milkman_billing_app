// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerModelAdapter extends TypeAdapter<SellerModel> {
  @override
  final int typeId = 0;

  @override
  SellerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellerModel(
      sellerName: fields[0] as String?,
      sellerAddress: fields[1] as String?,
      sellerContactDetails: fields[2] as String?,
      sellerSlug: fields[4] as String?,
      createdAtEpoch: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SellerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sellerName)
      ..writeByte(1)
      ..write(obj.sellerAddress)
      ..writeByte(2)
      ..write(obj.sellerContactDetails)
      ..writeByte(3)
      ..write(obj.createdAtEpoch)
      ..writeByte(4)
      ..write(obj.sellerSlug);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
