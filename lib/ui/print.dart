
import 'dart:io';
import 'dart:ui' as ui;

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printer_module/db/bill_db.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/db/setting_db.dart';
import 'package:printer_module/extension/snackbar_xn.dart';
import 'package:printer_module/model/bill_model.dart';
import 'package:printer_module/model/seller_model.dart';
import 'package:printer_module/res/strings.dart';
import 'package:share_plus/share_plus.dart';

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
  final GlobalKey _invoiceKey = GlobalKey();

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
      // Bluetooth not available — user can still save without printing
    });

    price = _priceDb.getPriceFromTable(
        fat: widget.fat, snf: widget.snf, milkType: widget.milkType);
    completePrice = double.parse(
        (double.parse(widget.weight) * price).toStringAsFixed(2));
    sgstPrice = double.parse(
        ((_appSettings.sgst / 100) * completePrice).toStringAsFixed(2));
    cgstPrice = double.parse(
        ((_appSettings.cgst / 100) * completePrice).toStringAsFixed(2));
    grandTotal = double.parse(
        (completePrice + cgstPrice + sgstPrice).toStringAsFixed(2));

    super.initState();
  }

  // ── Print function: DO NOT MODIFY ──────────────────────────────────────────
  Future<dynamic> printInvoice() async {
    await blueThermalPrinter.printNewLine();
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
  // ───────────────────────────────────────────────────────────────────────────

  void _saveBill() {
    if (!widget.isSaveEnabled) return;
    _billDb.addNewBill(BillModel(
        fat: double.parse(widget.fat),
        snf: double.parse(widget.snf),
        weight: double.parse(widget.weight),
        price: completePrice,
        sellerSlug: widget.sellerModel.sellerSlug,
        invoiceNumber: _billDb.getLength(),
        dateEpoch: _dateTime.millisecondsSinceEpoch.toString(),
        shift: widget.shift.index,
        milkType: widget.milkType.index));
  }

  Future<void> _shareAsImage() async {
    try {
      final boundary = _invoiceKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Milk Bill',
      );
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context: context, message: "Could not share bill: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: RepaintBoundary(
                  key: _invoiceKey,
                  child: invoiceWidget(),
                ),
              ),
            ),
            _buttons(context),
          ],
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text("Cancel",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        // Share to WhatsApp button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
          onPressed: _shareAsImage,
          child: const Icon(Icons.share, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              _saveBill();
              showSuccessSnackBar(
                  context: context, message: "Recorded successfully");
              Navigator.pop(context);
            },
            child: Text("Save",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              if (_connected) {
                await printInvoice().then((value) {
                  if (!mounted) return;
                  if (value == true) {
                    _saveBill();
                    showSuccessSnackBar(
                        context: context, message: "Printed Successfully");
                    Navigator.pop(context);
                  }
                });
              } else {
                showErrorSnackBar(
                    context: context,
                    message: "Printer not connected! Use Save to record only.");
              }
            },
            child: Text("Print",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget invoiceWidget() {
    final String bizName = _appSettings.businessName.isNotEmpty
        ? _appSettings.businessName
        : AppStrings.companyName;
    final String bizAddress = _appSettings.businessAddress.isNotEmpty
        ? _appSettings.businessAddress
        : AppStrings.address;
    final String bizPhone = _appSettings.businessPhone.isNotEmpty
        ? _appSettings.businessPhone
        : AppStrings.phoneNumber;
    final String logoPath = _appSettings.logoPath;

    final timeOfDay = TimeOfDay.fromDateTime(_dateTime);
    final String timeStr =
        "${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period == DayPeriod.pm ? 'PM' : 'AM'}";
    final String dateStr =
        "${_dateTime.day.toString().padLeft(2, '0')}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.year}";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            if (logoPath.isNotEmpty && File(logoPath).existsSync())
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.file(File(logoPath), height: 72, fit: BoxFit.contain),
              ),
            Text(bizName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (bizAddress.isNotEmpty)
              Text(bizAddress,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
            if (bizPhone.isNotEmpty)
              Text(bizPhone,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1.5),
            ),

            // ── Buyer / Seller info ─────────────────────────────────────────
            _infoRow(Icons.business, "Buyer", _appSettings.buyerName),
            const SizedBox(height: 6),
            _infoRow(Icons.person, "Seller",
                "${widget.sellerModel.sellerName}  ·  ${widget.sellerModel.sellerAddress}"),
            _infoRow(Icons.phone, "Phone",
                widget.sellerModel.sellerContactDetails ?? ""),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1.5),
            ),

            // ── Invoice meta ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _chip(Icons.receipt_long,
                    "Invoice #${_billDb.getLength()}", Colors.indigo),
                _chip(Icons.calendar_today, dateStr, Colors.teal),
                _chip(Icons.access_time, timeStr, Colors.orange),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shiftChip(),
                const SizedBox(width: 8),
                _milkTypeChip(),
              ],
            ),

            const SizedBox(height: 16),

            // ── Items table ──────────────────────────────────────────────────
            _invoiceTable(),

            const SizedBox(height: 16),

            // ── Grand total banner ───────────────────────────────────────────
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF000311),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Grand Total",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text("Rs. $grandTotal",
                      style: GoogleFonts.poppins(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceTable() {
    final rows = [
      {"label": "FAT", "qty": widget.fat, "price": "—"},
      {"label": "SNF", "qty": widget.snf, "price": "Rs. $price"},
      {"label": "Weight", "qty": "${widget.weight} L", "price": "Rs. $completePrice"},
      {"label": "SGST (${_appSettings.sgst}%)", "qty": "", "price": "Rs. $sgstPrice"},
      {"label": "CGST (${_appSettings.cgst}%)", "qty": "", "price": "Rs. $cgstPrice"},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text("ITEM",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text("QTY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 12))),
                Expanded(
                    flex: 3,
                    child: Text("PRICE",
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 12))),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: i.isEven ? Colors.white : Colors.grey.shade50,
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(row["label"]!,
                          style: GoogleFonts.poppins(fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Text(row["qty"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey[600]))),
                  Expanded(
                      flex: 3,
                      child: Text(row["price"]!,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w500))),
                ],
              ),
            );
          }),
          // Subtotal row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text("Subtotal",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 13))),
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                    flex: 3,
                    child: Text("Rs. $completePrice",
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text("$label: ",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _shiftChip() {
    final isMorning = widget.shift == ShiftType.morning;
    return _chip(
        isMorning ? Icons.wb_sunny : Icons.nights_stay,
        isMorning ? "Morning" : "Evening",
        isMorning ? Colors.orange : Colors.indigo);
  }

  Widget _milkTypeChip() {
    final isCow = widget.milkType == MilkType.cow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCow ? "🐄 Cow Milk" : "🐃 Buffalo Milk",
        style: GoogleFonts.poppins(
            fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600),
      ),
    );
  }
}
