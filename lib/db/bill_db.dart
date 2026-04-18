import 'package:hive_flutter/hive_flutter.dart';
import 'package:printer_module/model/bill_model.dart';

enum ShiftType { morning, evening }

class BillDb {
  Box billBox = Hive.box("billBox");

  Future<void> addNewBill(BillModel billModel) async {
    await billBox.add(billModel);
  }

  List<BillModel> getBills() {
    return List<BillModel>.from(billBox.values);
  }

  List<BillModel> getBillFromShift(
      {required ShiftType shift, required DateTime date}) {
    return List<BillModel>.from(billBox.values.where((element) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(element.dateEpoch));
      return element.shift == shift.index &&
          (dateTime.year == date.year &&
              dateTime.month == date.month &&
              dateTime.day == date.day);
    }));
  }

  void deleteAt(int index) {
    billBox.deleteAt(index);
  }

  int getLength() {
    return billBox.values.length + 1;
  }

  double? getTotal({required List<BillModel> billModelList}) {
    double price = 0;
    for (var element in billModelList) {
      price += element.price!.toDouble(); 
    }
    return price; 
  }
}
