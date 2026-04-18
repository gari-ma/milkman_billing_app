import 'package:flutter/material.dart';
import 'package:printer_module/db/price_db.dart';
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
        appBar: AppBar(
          title: const Text("Menu"),
        ),
        body: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15.0, top: 10),
              child: Text(
                "General Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              title: const Text("Setting & Configuration"),
              subtitle:
                  const Text("For configuring logo, company details and more"),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SellersInfo()));
              },
              title: const Text("Seller`s Informations"),
              subtitle:
                  const Text("View, Add, Delete, Edit Seller Informations"),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const PrintScreen()));
              },
              title: const Text("Setup Bluetooth Device"),
              subtitle: const Text(
                  "Setup and test bluetooth device"),

                  
            ),

                        const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const MilkSales()));
              },
              title: const Text("Milk Sales"),
              subtitle: const Text(
                  "View all the sales according to shift."),

                  
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15.0, top: 10),
              child: Text(
                "Milk Pricing Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PricingInfo(type: MilkType.cow)));
              },
              title: const Text("Cow Milk pricing"),
              subtitle: const Text(
                  "View, Add, Delete, Edit Cow Milk Pricing Informations"),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const PricingInfo(type: MilkType.buffalo)));
              },
              title: const Text("Buffalo Milk Pricing"),
              subtitle: const Text(
                  "View, Add, Delete, Edit Buffallo Milk Pricing Informations"),
            )
          ],
        ));
  }
}
