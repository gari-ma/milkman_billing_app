import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/extension/csv_to_table.dart';
import 'package:printer_module/model/price_model.dart';
import 'package:printer_module/res/colors.dart';
import 'package:printer_module/res/gradient_app_bar.dart';

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

  final TextEditingController _fatCtr = TextEditingController();
  final TextEditingController _snfCtr = TextEditingController();
  final TextEditingController _priceCtr = TextEditingController();

  @override
  void initState() {
    milkType = widget.type;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) print("started gathering price");
      _loadTable();
      if (kDebugMode) print("finished gathering price");
    });
    super.initState();
  }

  void _loadTable() {
    items.clear();
    _priceDb.getAll(type: milkType).forEach((element) {
      items.add(TableRow(children: [
        Text(element.fat.toString(), textAlign: TextAlign.center),
        Text(element.snf.toString(), textAlign: TextAlign.center),
        Text(element.price.toString(), textAlign: TextAlign.center),
      ]));
    });
    setState(() => isLoading = false);
  }

  void _addManualEntry() {
    final fat = double.tryParse(_fatCtr.text.trim());
    final snf = double.tryParse(_snfCtr.text.trim());
    final price = double.tryParse(_priceCtr.text.trim());

    if (fat == null || snf == null || price == null) {
      showErrorSnackBar(
          context: context, message: "Please enter valid FAT, SNF and Price");
      return;
    }

    _priceDb.addNew(
        priceModel: PriceModel(fat: fat, snf: snf, price: price),
        type: milkType);

    _fatCtr.clear();
    _snfCtr.clear();
    _priceCtr.clear();
    FocusScope.of(context).unfocus();

    showSuccessSnackBar(context: context, message: "Entry added");
    setState(() => isLoading = true);
    _loadTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
            "${milkType == MilkType.cow ? 'Cow' : 'Buffalo'} Pricing Info"),
      ),
      body: Stack(
        children: [
          ListView(physics: const BouncingScrollPhysics(), children: [
            // ── CSV Import ─────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
              child: InkWell(
                onTap: () async {
                  setState(() => isLoading = true);
                  FilePickerResult? result = await FilePicker.pickFiles();
                  if (result != null) {
                    File newFile = File(result.files.single.path!);
                    setState(() => file = newFile);
                    csvConverter = CsvConverter(filePath: newFile);
                    csvConverter.convert().then((value) async {
                      await _priceDb.addAll(
                          priceModelList: value as List<PriceModel>,
                          type: milkType);
                      if (!context.mounted) return;
                      showSuccessSnackBar(
                          context: context, message: "CSV imported successfully");
                      _loadTable();
                    });
                  } else {
                    setState(() => isLoading = false);
                  }
                },
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      label: Center(
                        child: Text(
                          "Import From CSV",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                      fillColor: AppColors.secondaryColor),
                ),
              ),
            ),

            // ── Manual Entry ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Add Entry Manually",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _entryField(_fatCtr, "FAT")),
                        const SizedBox(width: 8),
                        Expanded(child: _entryField(_snfCtr, "SNF")),
                        const SizedBox(width: 8),
                        Expanded(child: _entryField(_priceCtr, "Price")),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton.icon(
                          onPressed: _addManualEntry,
                          icon: const Icon(Icons.add),
                          label: Text("Add Entry",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Price Table ────────────────────────────────────────────────
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

  Widget _entryField(TextEditingController ctr, String label) {
    return TextField(
      controller: ctr,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}
