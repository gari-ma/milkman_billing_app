/*
! takes CSV file as input and outputs the [List<PriceModel>]
*/
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'package:printer_module/model/price_model.dart';

class CsvConverter {
  File? filePath;
  late PriceModel priceModel;
  List snf = [];
  List<PriceModel> priceModelList = [];

  CsvConverter({this.filePath});

  Future<List> convert() async {
    final input = filePath!.openRead();
    List<List<dynamic>> fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    snf.addAll(fields.first);
    snf.removeAt(0);
    fields.removeAt(0);
    fields.removeLast();

    _convert(fields);

    Logger().wtf(priceModelList.first.price);
    Logger().wtf(priceModelList.last.price);
    return priceModelList;
  }

  void _convert(List<List<dynamic>> fields) {
    int index = 0;
    for (var element in fields) {
      double fat = double.parse(element.first.toString().replaceAll(",", ""));
      element.removeAt(0);
      for (var item in element) {
        PriceModel priceModel = PriceModel(
            fat: fat,
            snf: double.parse(snf.elementAt(index).toString()),
            price: double.parse(item.toString()));
        // Logger().d(
        //     "FAT: ${priceModel.fat}\nSNF: ${priceModel.snf}\nPrice: ${priceModel.price}");
        priceModelList.add(priceModel);
        index++;
      }
      index = 0;
    }
  }
}
