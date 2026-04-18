
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/db/bill_db.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/db/setting_db.dart';
import 'package:printer_module/extension/snackbar_xn.dart';
import 'package:printer_module/model/bill_model.dart';
import 'package:printer_module/model/seller_model.dart';
import 'package:printer_module/res/strings.dart';

/// [PrintUi] shows the bill in viewable format before printing
///
/// * [isSaveEnabled] flag is used to dictate whether to save the receipt after print or not
class PrintUi extends StatefulWidget {
  final String fat, snf, weight;
  final SellerModel sellerModel;
  final MilkType milkType;
  final bool isSaveEnabled;
  final ShiftType shift;

  const PrintUi(
      {Key? key,
      required this.fat,
      required this.snf,
      required this.weight,
      required this.sellerModel,
      required this.milkType,
      this.isSaveEnabled = true,
      required this.shift})
      : super(key: key);

  @override
  State<PrintUi> createState() => _PrintUiState();
}

class _PrintUiState extends State<PrintUi> {
  final AppSettings _appSettings = AppSettings();
  final BillDb _billDb = BillDb();
  final DateTime _dateTime = DateTime.now();
  final PriceDb _priceDb = PriceDb();
  late double price;
  late double completePrice;
  late double sgstPrice, cgstPrice, grandTotal;
  bool _connected = false;
  late BluetoothDevice? bluetoothDevice;
  late BlueThermalPrinter blueThermalPrinter;

  @override
  void dispose() {
    super.dispose();
    blueThermalPrinter.disconnect();
  }

  @override
  void initState() {
    blueThermalPrinter = BlueThermalPrinter.instance;
    bluetoothDevice = BluetoothDevice(
        _appSettings.bluetoothName, _appSettings.bluetoothAddress);

    blueThermalPrinter.connect(bluetoothDevice!).then((value) {
      _connected = true;
      setState(() {});
    }).catchError((e) {
      showErrorSnackBar(
          context: context,
          message: "Error connecting to Printer. Please see the settings tab.");
    });

    price = _priceDb.getPriceFromTable(
        fat: widget.fat, snf: widget.snf, milkType: widget.milkType);
    completePrice = double.parse(
        (double.parse(widget.weight) * price).toStringAsFixed(2)); // Milk Price
    sgstPrice = double.parse(
        ((_appSettings.sgst / 100) * completePrice).toStringAsFixed(2));
    cgstPrice = double.parse(
        ((_appSettings.cgst / 100) * completePrice).toStringAsFixed(2));
    grandTotal = double.parse(
        (completePrice + cgstPrice + sgstPrice).toStringAsFixed(2));

    super.initState();
  }

  Future<dynamic> printInvoice() async {
    // size
    // 0 => normal
    // 1 => normal bold
    // 2 => medium bold
    // 3 => high bold

    // align
    // 0 => left
    // 1 => center
    // 2 => right

    await blueThermalPrinter.printNewLine();
    // blueThermalPrinter.printImage(_appSettings.filePath);
    await blueThermalPrinter.printCustom(AppStrings.companyName, 3, 1);
    await blueThermalPrinter.printCustom(AppStrings.address, 1, 1);
    await blueThermalPrinter.printCustom(AppStrings.phoneNumber, 1, 1);
    await blueThermalPrinter.printCustom(
        "Buyer: ${_appSettings.buyerName}", 0, 0);
    await blueThermalPrinter.printCustom(
        "------------------------------", 0, 0);
    await blueThermalPrinter.printCustom(
        "Seller: ${widget.sellerModel.sellerName}   (${widget.sellerModel.sellerAddress})", 0, 0);

    await blueThermalPrinter.printCustom(
        "Phone: ${widget.sellerModel.sellerContactDetails}", 0, 0);
        
    await blueThermalPrinter.printCustom(
        "------------------------------", 0, 0);
    await blueThermalPrinter.printCustom(
        "Invoice Number: ${_billDb.getLength()}", 1, 0);
    await blueThermalPrinter.printLeftRight(
        "Date: ${_dateTime.year}-${_dateTime.month}-${_dateTime.day}",
        "Time: ${TimeOfDay.fromDateTime(_dateTime).hourOfPeriod}:${TimeOfDay.fromDateTime(_dateTime).minute} ${(TimeOfDay.fromDateTime(_dateTime).period == DayPeriod.pm) ? "PM" : "AM"}",
        0);
    await blueThermalPrinter.printNewLine();
    await blueThermalPrinter.print3Column("ITEM", "Quantity", "Price", 1);
    await blueThermalPrinter.print3Column("FAT", "[${widget.fat}]", "..", 1);
    await blueThermalPrinter.print3Column(
        "SNF", "[${widget.snf}]", "Rs. $price", 1);
    await blueThermalPrinter.print3Column(
        "Weight", "[${widget.weight}]", "Rs. $completePrice", 1);
    await blueThermalPrinter.print3Column(
        "SGST", "${_appSettings.sgst}%", "Rs. $sgstPrice", 1);
    await blueThermalPrinter.print3Column(
        "CGST", "${_appSettings.cgst}%", "Rs. $cgstPrice", 1);
    await blueThermalPrinter.printNewLine();
    await blueThermalPrinter.printLeftRight(
        "Total Price", "Rs. $grandTotal", 1);
    await blueThermalPrinter.printNewLine();
    await blueThermalPrinter.printCustom(
        (widget.milkType == MilkType.cow)
            ? "Milk Type: [*] Cow       []Buffalo"
            : "Milk Type: [] Cow       [*]Buffalo",
        0,
        0);
    await blueThermalPrinter.paperCut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Card(
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [invoiceWidget(), buttons(context)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row buttons(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MaterialButton(
            height: 45,
            color: Colors.grey,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      )),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MaterialButton(
            height: 45,
            color: Colors.green,
            onPressed: () async {
              if (_connected) {
                await printInvoice().then((value) {
                  if (value == true) {
                    if (widget.isSaveEnabled) {
                      _billDb.addNewBill(BillModel(
                          fat: double.parse(widget.fat),
                          snf: double.parse(widget.snf),
                          weight: double.parse(widget.weight),
                          price: completePrice,
                          sellerSlug: widget.sellerModel.sellerSlug,
                          invoiceNumber: _billDb.getLength(),
                          dateEpoch:
                              _dateTime.millisecondsSinceEpoch.toString(),
                          shift: widget.shift.index,
                          milkType: widget.milkType.index));
                    }

                    showSuccessSnackBar(
                        context: context, message: "Printed Successfully");

                    Navigator.pop(context);
                  }
                });
              } else {

                  //  _billDb.addNewBill(BillModel(
                  //         fat: double.parse(widget.fat),
                  //         snf: double.parse(widget.snf),
                  //         weight: double.parse(widget.weight),
                  //         price: completePrice,
                  //         sellerSlug: widget.sellerModel.sellerSlug,
                  //         invoiceNumber: _billDb.getLength(),
                  //         dateEpoch:
                  //             _dateTime.millisecondsSinceEpoch.toString(),
                  //         shift: widget.shift.index,
                  //         milkType: widget.milkType.index));
                showErrorSnackBar(
                    context: context,
                    message: "Failed: Printer not connected!");
              }
            },
            child: Text(
              "PRINT",
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )),
      )),
    ]);
  }

  Padding invoiceWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(children: [
        Container(
          height: 10,
        ),
        Text(
          AppStrings.companyName,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Text(
          AppStrings.address,
          style: GoogleFonts.poppins(fontSize: 17),
        ),
        (AppStrings.phoneNumber.isNotEmpty)
            ? Text(
                AppStrings.phoneNumber,
                style: GoogleFonts.poppins(fontSize: 17),
              )
            : Container(),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Buyer: ${_appSettings.buyerName}",
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              Text(
                "-------------------------------------------------",
                style: GoogleFonts.poppins(fontSize: 10),
              ),
              Text(
                "Seller: ${widget.sellerModel.sellerName!}  (${widget.sellerModel.sellerAddress})   Phone: ${widget.sellerModel.sellerContactDetails}",
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              Text(
                "-------------------------------------------------",
                style: GoogleFonts.poppins(fontSize: 10),
              ),
              Text(
                "Invoice number: ${_billDb.getLength()}",
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                "Date: ${_dateTime.year}-${_dateTime.month}-${_dateTime.day}          Time: ${TimeOfDay.fromDateTime(_dateTime).hourOfPeriod}:${TimeOfDay.fromDateTime(_dateTime).minute} ${(TimeOfDay.fromDateTime(_dateTime).period == DayPeriod.pm) ? "PM" : "AM"}",
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 10),
                child: DataTable(
                    headingRowHeight: 35,
                    dataRowHeight: 35,
                    dataTextStyle: GoogleFonts.ubuntu(color: Colors.black),
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey),
                    columns: [
                      DataColumn(
                          label: Text(
                        "ITEM",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      )),
                      DataColumn(
                          label: Text(
                        "Quantity",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      )),
                      DataColumn(
                          label: Text(
                        "Price",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ))
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text("FAT")),
                        DataCell(Text("[${widget.fat}]")),
                        const DataCell(Text("..."))
                      ]),
                      DataRow(cells: [
                        const DataCell(Text("SNF")),
                        DataCell(Text("[${widget.snf}]")),
                        DataCell(Text(price.toString()))
                      ]),
                      DataRow(cells: [
                        const DataCell(Text("Weight")),
                        DataCell(Text("[${widget.weight} ltr]")),
                        DataCell(Text(completePrice.toString()))
                      ]),
                      DataRow(
                          color: MaterialStateProperty.resolveWith(
                              (states) => const Color.fromARGB(255, 187, 150, 150)),
                          cells: [
                            DataCell(Text("TOTAL",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                            const DataCell(Text("                 ")),
                            DataCell(Text(
                              "Rs. $completePrice",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                          ]),
                      DataRow(
                          color: MaterialStateProperty.resolveWith(
                              (states) => const Color.fromARGB(255, 144, 115, 115)),
                          cells: [
                            DataCell(Text("SGST",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(
                              "${_appSettings.sgst}%",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              "Rs. $sgstPrice",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                          ]),
                      DataRow(
                          color: MaterialStateProperty.resolveWith(
                              (states) => const Color.fromARGB(255, 121, 105, 105)),
                          cells: [
                            DataCell(Text("CGST",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text(
                              "${_appSettings.cgst}%",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              "Rs. $cgstPrice",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                          ]),
                      DataRow(
                          color: MaterialStateProperty.resolveWith(
                              (states) => const Color.fromARGB(255, 11, 0, 0)),
                          cells: [
                            DataCell(Text("Price",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                            const DataCell(Text(
                              " ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              "Rs. $grandTotal",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                          ]),
                      DataRow(cells: [
                        const DataCell(Text("Type: ")),
                        DataCell(Text((widget.milkType == MilkType.cow)
                            ? "[✔️] Cow"
                            : "[ ] Cow", style: TextStyle(fontSize: 0.035 * MediaQuery.of(context).size.width),)),
                        DataCell(Text((widget.milkType == MilkType.buffalo)
                            ? "[✔️] Buffallo"
                            : "[ ] Buffallo", style: TextStyle(fontSize: 0.035 * MediaQuery.of(context).size.width),)),
                      ]),
                    ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
