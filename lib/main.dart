/*
  @Author https://github.com/imp-sike
*/

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printer_module/model/bill_model.dart';
import 'package:printer_module/model/price_model.dart';
import 'package:printer_module/model/seller_model.dart';
import 'package:printer_module/res/strings.dart';
import 'package:printer_module/res/theme.dart';
import 'package:printer_module/ui/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupHive();
  runApp(const BaseApp());
}

void setupHive() async {
  /// sets up Hive as the project database
  ///
  /// https://pub.dev/packages/hive

  await Hive.initFlutter();
  Hive.registerAdapter(SellerModelAdapter());
  Hive.registerAdapter(PriceModelAdapter());
  Hive.registerAdapter(BillModelAdapter());

  /// Settings & Configurations (company name, buyer's name, logo, etc.)
  await Hive.openBox('settingBox');

  /// seller information, for items see [SellerModel]
  await Hive.openBox('sellerBox');

  /// price from csv, see [PriceModel]
  await Hive.openBox('cowBox');
  await Hive.openBox('buffaloBox');

  /// receipt/invoice, see [BillModel]
  await Hive.openBox('billBox');
}

class BaseApp extends StatelessWidget {
  const BaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.globalAppTheme(),
        home: const SplashUi());
  }
}
