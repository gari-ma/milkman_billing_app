import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/extension/csv_to_table.dart';
import 'package:printer_module/model/price_model.dart';
import 'package:printer_module/res/colors.dart';

import '../../extension/snackbar_xn.dart';

class PricingInfo extends StatefulWidget {
  final MilkType type;
  const PricingInfo({Key? key, required this.type}) : super(key: key);

  @override
  State<PricingInfo> createState() => _PricingInfoState();
}

class _PricingInfoState extends State<PricingInfo> {
  File? file;
  late CsvConverter csvConverter;
  List<TableRow> items = [];
  late MilkType milkType;
  bool isLoading = true;
  final PriceDb _priceDb = PriceDb();

  @override
  void initState() {
    milkType = widget.type;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print("started gathering price");
      }
      _priceDb.getAll(type: milkType).forEach((element) {
        items.add(TableRow(children: [
          Text(
            element.fat.toString(),
            textAlign: TextAlign.center,
          ),
          Text(
            element.snf.toString(),
            textAlign: TextAlign.center,
          ),
          Text(
            element.price.toString(),
            textAlign: TextAlign.center,
          ),
        ]));
      });

      if (kDebugMode) {
        print("finished gathering price");
      }
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pricing Information"),
      ),
      body: Stack(
        children: [
          ListView(physics: const BouncingScrollPhysics(), children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: InkWell(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });

                  FilePickerResult? result =
                      await FilePicker.pickFiles();

                  if (result != null) {
                    File newFile = File(result.files.single.path!);
                    setState(() {
                      file = newFile;
                    });
                    csvConverter = CsvConverter(filePath: newFile);
                    csvConverter.convert().then((value) async {
                      await _priceDb.addAll(
                          priceModelList: value as List<PriceModel>,
                          type: milkType);

                      if (!context.mounted) return;

                      showSuccessSnackBar(
                          context: context, message: "Successfully Saved");

                      items.clear();
                      _priceDb.getAll(type: milkType).forEach((element) {
                        items.add(TableRow(children: [
                          Text(
                            element.fat.toString(),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            element.snf.toString(),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            element.price.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ]));
                      });

                      setState(() {
                        isLoading = false;
                      });
                    });
                  } else {
                    // User canceled the picker
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                      filled: true,
                      label: Center(
                        child: Text(
                          "Import From CSV",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
                      fillColor: AppColors.secondaryColor),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(120.0),
                border: TableBorder.all(
                    color: Colors.grey, style: BorderStyle.solid, width: 2),
                children: [
                  const TableRow(children: [
                    Text('FAT',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0)),
                    Text('SNF',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0)),
                    Text("Price",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0)),
                  ]),
                  ...items
                ],
              ),
            )
          ]),
          Visibility(
              visible: isLoading,
              child: const Center(child: CircularProgressIndicator()))
        ],
      ),
    );
  }
}
