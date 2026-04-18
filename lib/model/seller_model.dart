import 'package:hive_flutter/hive_flutter.dart';

part 'seller_model.g.dart';

@HiveType(typeId: 0)
class SellerModel {
  @HiveField(0)
  String? sellerName;

  @HiveField(1)
  String? sellerAddress;

  @HiveField(2)
  String? sellerContactDetails;

  @HiveField(3)
  String? createdAtEpoch;

  @HiveField(4)
  String? sellerSlug; //? `slugs` are used for getting the records of the user

  SellerModel(
      {this.sellerName,
      this.sellerAddress,
      this.sellerContactDetails,
      this.sellerSlug,
      this.createdAtEpoch});
}
