import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printer_module/db/bill_db.dart';
import 'package:printer_module/res/gradient_app_bar.dart';
import 'package:printer_module/res/theme.dart';

import '../../db/price_db.dart';
import '../../model/bill_model.dart';

class MilkSales extends StatefulWidget {
  const MilkSales({Key? key}) : super(key: key);

  @override
  State<MilkSales> createState() => _MilkSalesState();
}

class _MilkSalesState extends State<MilkSales> {
  final BillDb _billDb = BillDb();
  late List<BillModel> _morning;
  late List<BillModel> _evening;
  DateTime _date = DateTime.now();
  double _morningTotal = 0.0;
  double _eveningTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _morning = _billDb.getBillFromShift(shift: ShiftType.morning, date: _date);
    _evening = _billDb.getBillFromShift(shift: ShiftType.evening, date: _date);
    _morningTotal = _billDb.getTotal(billModelList: _morning) ?? 0.0;
    _eveningTotal = _billDb.getTotal(billModelList: _evening) ?? 0.0;
  }

  String get _formattedDate => DateFormat('dd MMM yyyy').format(_date);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2090));
    if (picked != null) {
      setState(() {
        _date = picked;
        _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: GradientAppBar(
          title: const Text("Milk Sales"),
          actions: [
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded,
                  color: Colors.white70, size: 16),
              label: Text(_formattedDate,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 13)),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.wb_sunny_rounded), text: "Morning"),
              Tab(icon: Icon(Icons.nights_stay_rounded), text: "Evening"),
            ],
          ),
        ),
        body: TabBarView(children: [
          _shiftView(_morning, _morningTotal, ShiftType.morning),
          _shiftView(_evening, _eveningTotal, ShiftType.evening),
        ]),
      ),
    );
  }

  Widget _shiftView(
      List<BillModel> bills, double total, ShiftType shift) {
    final isMorning = shift == ShiftType.morning;
    if (bills.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_rounded,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("No sales for $_formattedDate",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
        ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isMorning
                  ? [const Color(0xFFF57F17), const Color(0xFFFF8F00)]
                  : [const Color(0xFF283593), const Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isMorning ? "Morning Shift" : "Evening Shift",
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                Text("Rs. ${total.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text("${bills.length} transaction${bills.length == 1 ? '' : 's'}",
                    style:
                        GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              ]),
              Icon(
                isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 44,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...bills.map((bill) => _billTile(bill)),
      ],
    );
  }

  Widget _billTile(BillModel bill) {
    final isCow = bill.milkType == MilkType.cow.index;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_rounded,
              color: AppTheme.primary, size: 20),
        ),
        title: Text("Invoice #${bill.invoiceNumber}",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(isCow ? "Cow Milk" : "Buffalo Milk",
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.grey[600])),
        trailing: Text("Rs. ${bill.price?.toStringAsFixed(2) ?? '—'}",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.accent)),
      ),
    );
  }
}
