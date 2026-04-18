import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/res/gradient_app_bar.dart';
import 'package:printer_module/res/theme.dart';
import 'package:printer_module/ui/menu/milk_sales.dart';
import 'package:printer_module/ui/menu/pricing_info.dart';
import 'package:printer_module/ui/menu/printer_connection.dart';
import 'package:printer_module/ui/menu/sellers_info.dart';
import 'package:printer_module/ui/menu/settings.dart';

class MenuUi extends StatelessWidget {
  const MenuUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: const GradientAppBar(title: Text("Menu")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel("General"),
          const SizedBox(height: 8),
          _menuGrid(context, [
            _MenuItem(
              icon: Icons.settings_rounded,
              label: "Settings &\nConfiguration",
              color: const Color(0xFF1565C0),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _MenuItem(
              icon: Icons.people_rounded,
              label: "Sellers\nInfo",
              color: const Color(0xFF00897B),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SellersInfo())),
            ),
            _MenuItem(
              icon: Icons.bluetooth_rounded,
              label: "Bluetooth\nPrinter",
              color: const Color(0xFF5E35B1),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrintScreen())),
            ),
            _MenuItem(
              icon: Icons.bar_chart_rounded,
              label: "Milk\nSales",
              color: const Color(0xFFE65100),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MilkSales())),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel("Milk Pricing"),
          const SizedBox(height: 8),
          _menuGrid(context, [
            _MenuItem(
              icon: Icons.price_change_rounded,
              label: "Cow Milk\nPricing",
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const PricingInfo(type: MilkType.cow))),
            ),
            _MenuItem(
              icon: Icons.price_change_outlined,
              label: "Buffalo Milk\nPricing",
              color: const Color(0xFF4527A0),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const PricingInfo(type: MilkType.buffalo))),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1.0));
  }

  Widget _menuGrid(BuildContext context, List<_MenuItem> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((item) => _menuCard(context, item)).toList(),
    );
  }

  Widget _menuCard(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            Text(item.label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}
