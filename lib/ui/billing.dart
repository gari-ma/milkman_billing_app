import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:printer_module/db/bill_db.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/db/sellers_db.dart';
import 'package:printer_module/db/setting_db.dart';
import 'package:printer_module/extension/snackbar_xn.dart';
import 'package:printer_module/model/seller_model.dart';
import 'package:printer_module/res/gradient_app_bar.dart';
import 'package:printer_module/res/theme.dart';
import 'package:printer_module/ui/menu.dart';
import 'package:printer_module/ui/print.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  MilkType selectedMilkType = MilkType.cow;
  ShiftType shiftType = ShiftType.morning;
  AppSettings appSettings = AppSettings();
  SellersDb sellersDb = SellersDb();
  Iterable<SellerModel> sellersList = [];
  final TextEditingController fatCtr = TextEditingController();
  final TextEditingController snfCtr = TextEditingController();
  final TextEditingController weightCtr = TextEditingController();
  SellerModel? sellerModelChoice;
  late ValueListenable<Box> boxListener;

  @override
  void initState() {
    super.initState();
    sellersList = sellersDb.getSellers();
    Logger().d(sellersList);

    // Auto-select shift by system time
    final hour = DateTime.now().hour;
    shiftType = (hour < 12) ? ShiftType.morning : ShiftType.evening;

    boxListener = Hive.box("sellerBox").listenable();
    boxListener.addListener(() {
      sellerModelChoice = null;
      sellersList = sellersDb.getSellers();
      setState(() {});
    });
  }

  @override
  void dispose() {
    boxListener.removeListener(() {});
    super.dispose();
  }

  void _reset() {
    fatCtr.clear();
    snfCtr.clear();
    weightCtr.clear();
    setState(() {
      selectedMilkType = MilkType.cow;
      sellerModelChoice = null;
    });
  }

  void _proceed() {
    if (fatCtr.text.isEmpty ||
        snfCtr.text.isEmpty ||
        weightCtr.text.isEmpty ||
        sellerModelChoice == null) {
      showErrorSnackBar(
          context: context, message: "Please fill all fields and select a seller");
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PrintUi(
                  sellerModel: sellerModelChoice!,
                  fat: fatCtr.text.trim(),
                  snf: snfCtr.text.trim(),
                  milkType: selectedMilkType,
                  weight: weightCtr.text.trim(),
                  shift: shiftType,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(children: [
          _setupWarning(),
          _dateShiftHeader(),
          const SizedBox(height: 16),
          _sellerCard(),
          const SizedBox(height: 12),
          _measurementsCard(),
          const SizedBox(height: 12),
          _milkTypeCard(),
          const SizedBox(height: 12),
          _shiftCard(),
          const SizedBox(height: 24),
          _actionButtons(),
        ]),
      ),
    );
  }

  GradientAppBar _appBar() {
    return GradientAppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/logo.png"),
      ),
      title: const Text("Dashboard"),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MenuUi())),
        )
      ],
    );
  }

  Widget _setupWarning() {
    return ValueListenableBuilder(
        valueListenable: Hive.box("settingBox").listenable(),
        builder: (context, Box<dynamic> b, _) {
          if (appSettings.hasBeenSetupCheck()) return const SizedBox.shrink();
          return Container(
            width: double.maxFinite,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "App not configured. Tap the menu icon to set up.",
                  style: GoogleFonts.poppins(
                      color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ]),
          );
        });
  }

  Widget _dateShiftHeader() {
    final now = DateTime.now();
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${now.day} ${months[now.month]} ${now.year}";
    final isAM = shiftType == ShiftType.morning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dateStr,
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 12)),
          Text("New Bill",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Icon(isAM ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                color: isAM ? Colors.amber : Colors.indigo.shade200, size: 16),
            const SizedBox(width: 6),
            Text(isAM ? "Morning" : "Evening",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  Widget _sellerCard() {
    return _sectionCard(
      icon: Icons.person_rounded,
      title: "Seller",
      child: ValueListenableBuilder(
          valueListenable: Hive.box("sellerBox").listenable(),
          builder: (context, Box<dynamic> b, _) {
            return DropdownButtonHideUnderline(
              child: DropdownButton<SellerModel>(
                isExpanded: true,
                value: sellerModelChoice,
                hint: Text("Select a seller",
                    style: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 14)),
                borderRadius: BorderRadius.circular(10),
                items: sellersList
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.sellerName.toString(),
                            style: GoogleFonts.poppins(fontSize: 14))))
                    .toList(),
                onChanged: (c) => setState(() => sellerModelChoice = c),
              ),
            );
          }),
    );
  }

  Widget _measurementsCard() {
    return _sectionCard(
      icon: Icons.science_rounded,
      title: "Measurements",
      child: Column(children: [
        _inputField(fatCtr, "FAT", "e.g. 3.5"),
        const SizedBox(height: 10),
        _inputField(snfCtr, "SNF", "e.g. 8.2"),
        const SizedBox(height: 10),
        _inputField(weightCtr, "Weight (litres)", "e.g. 10.0"),
      ]),
    );
  }

  Widget _inputField(
      TextEditingController ctr, String label, String hint) {
    return TextField(
      controller: ctr,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _milkTypeCard() {
    return _sectionCard(
      icon: Icons.water_drop_rounded,
      title: "Milk Type",
      child: Row(children: [
        _toggleOption(
          selected: selectedMilkType == MilkType.cow,
          label: "🐄  Cow",
          onTap: () => setState(() => selectedMilkType = MilkType.cow),
        ),
        const SizedBox(width: 10),
        _toggleOption(
          selected: selectedMilkType == MilkType.buffalo,
          label: "🐃  Buffalo",
          onTap: () => setState(() => selectedMilkType = MilkType.buffalo),
        ),
      ]),
    );
  }

  Widget _shiftCard() {
    return _sectionCard(
      icon: Icons.access_time_rounded,
      title: "Shift",
      child: Row(children: [
        _toggleOption(
          selected: shiftType == ShiftType.morning,
          label: "🌅  Morning",
          onTap: () => setState(() => shiftType = ShiftType.morning),
        ),
        const SizedBox(width: 10),
        _toggleOption(
          selected: shiftType == ShiftType.evening,
          label: "🌃  Evening",
          onTap: () => setState(() => shiftType = ShiftType.evening),
        ),
      ]),
    );
  }

  Widget _toggleOption(
      {required bool selected,
      required String label,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
      {required IconData icon,
      required String title,
      required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text("Reset"),
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: _proceed,
          icon: const Icon(Icons.receipt_long_rounded, size: 18),
          label: const Text("Generate Bill"),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ),
    ]);
  }
}
