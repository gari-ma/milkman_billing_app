import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:printer_module/model/price_model.dart';

enum MilkType { cow, buffalo }

class PriceDb {
  Box cowBox = Hive.box("cowBox");
  Box buffaloBox = Hive.box("buffaloBox");

  Iterable getAll({required MilkType type}) {
    return (type == MilkType.cow) ? cowBox.values : buffaloBox.values;
  }

  void deleteAll({required MilkType type}) {
    (type == MilkType.cow) ? cowBox.clear() : buffaloBox.clear();
  }

  void addNew({required PriceModel priceModel, required MilkType type}) {
    (type == MilkType.cow)
        ? cowBox.add(priceModel)
        : buffaloBox.add(priceModel);
  }

  Future addAll(
      {required List<PriceModel> priceModelList, required MilkType type}) async {
    if (kDebugMode) {
      print(
        "PriceModelList Size ${priceModelList.length} ||| MilkType: ${type.index}");
    }
    (type == MilkType.cow) ? await cowBox.clear() : await buffaloBox.clear();
    return  (type == MilkType.cow)
        ? await cowBox.addAll(priceModelList)
        : await buffaloBox.addAll(priceModelList);
  }

  double getPriceFromTable(
      {required String fat, required String snf, required MilkType milkType}) {
    /// filter price based on [fat] and [snf]
    Logger().wtf("$snf - $fat");
    PriceModel priceModel = getAll(type: milkType).firstWhere(
        (element) => (element.snf.toString().trim() == snf.trim() &&
            element.fat.toString().trim() == fat.trim()),
        orElse: () => PriceModel(fat: 0.0, snf: 0.0, price: 1.1));
    return priceModel.price!;
  }
}
