import 'package:hive_flutter/hive_flutter.dart';

part 'bill_model.g.dart';

@HiveType(typeId: 2)
class BillModel {
  @HiveField(0)
  double? fat;

  @HiveField(1)
  double? snf;

  @HiveField(2)
  double? price;

  @HiveField(3)
  String? sellerSlug;

  @HiveField(4)
  int? invoiceNumber;

  @HiveField(5)
  String? dateEpoch;

  @HiveField(6)
  int? milkType;

  @HiveField(7)
  double? weight;

  @HiveField(8)
  int? shift;

  BillModel(
      {this.fat,
      this.snf,
      this.weight,
      this.price,
      this.sellerSlug,
      this.invoiceNumber,
      this.dateEpoch,
      this.milkType,
      this.shift});
}
