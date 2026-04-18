import 'package:hive_flutter/hive_flutter.dart';

part 'price_model.g.dart';

@HiveType(typeId: 1)
class PriceModel {
  @HiveField(0)
  double? fat;

  @HiveField(1)
  double? snf;

  @HiveField(2)
  double? price;

  PriceModel({this.fat, this.snf, this.price});
}
