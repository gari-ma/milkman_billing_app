import 'package:hive_flutter/hive_flutter.dart';
import 'package:printer_module/model/seller_model.dart';

class SellersDb {
  Box sellerBox = Hive.box("sellerBox");

  Future<void> addNewSeller(SellerModel sellerModel) async {
    await sellerBox.add(sellerModel);
  }

  Iterable<SellerModel> getSellers() {
    return List<SellerModel>.from(sellerBox.values);
  }

  void deleteAt(int index) {
    sellerBox.deleteAt(index);
  }
}
