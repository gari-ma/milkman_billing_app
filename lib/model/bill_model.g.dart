// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillModelAdapter extends TypeAdapter<BillModel> {
  @override
  final int typeId = 2;

  @override
  BillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillModel(
      fat: fields[0] as double?,
      snf: fields[1] as double?,
      weight: fields[7] as double?,
      price: fields[2] as double?,
      sellerSlug: fields[3] as String?,
      invoiceNumber: fields[4] as int?,
      dateEpoch: fields[5] as String?,
      milkType: fields[6] as int?,
      shift: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BillModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.fat)
      ..writeByte(1)
      ..write(obj.snf)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.sellerSlug)
      ..writeByte(4)
      ..write(obj.invoiceNumber)
      ..writeByte(5)
      ..write(obj.dateEpoch)
      ..writeByte(6)
      ..write(obj.milkType)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.shift);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
