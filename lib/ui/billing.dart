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
import 'package:printer_module/res/colors.dart';
import 'package:printer_module/res/strings.dart';
import 'package:printer_module/ui/menu.dart';
import 'package:printer_module/ui/print.dart';

/// [BillingPage] is the home screen of the app
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
  TextEditingController fatCtr = TextEditingController(),
      snfCtr = TextEditingController(),
      weightCtr = TextEditingController();
  SellerModel? sellerModel;
  SellerModel? sellerModelChoice;
  late ValueListenable<Box> boxListener;

  @override
  void initState() {
    super.initState();

    sellersList = sellersDb.getSellers();
    Logger().d(sellersList);

    /// add a listener for syncing [sellersList] for [Dropdown]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                setupError(),
                space(),
                sellerDropdown(),
                space(),
                fatInput(),
                space(),
                snfInput(),
                space(),
                priceInput(),
                space(),
                fatTypeRadio(),
                space(),
                shiftTypeRadio(),
                space(),
                primaryButtons(context)
              ],
            ),
          ),
        ));
  }

  Container space() {
    return Container(
      height: 20,
    );
  }

  Row primaryButtons(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MaterialButton(
            height: 45,
            color: Colors.grey,
            onPressed: () {
              fatCtr.text = "";
              snfCtr.text = "";
              weightCtr.text = "";
              selectedMilkType = MilkType.cow;
              setState(() {});
            },
            child: Text("Reset",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      )),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MaterialButton(
            height: 45,
            color: Colors.green,
            onPressed: () {
              // file exists, do other operations
              if (fatCtr.text.isEmpty ||
                  snfCtr.text.isEmpty ||
                  weightCtr.text.isEmpty ||
                  sellerModelChoice == null) {
                showErrorSnackBar(
                    context: context,
                    message: "Please fill the input forms correctly");
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
                          shift: shiftType
                          )));
            },
            child: Text(
              "PRINT",
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )),
      )),
    ]);
  }

  Column fatTypeRadio() {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          child: Text(
            "FAT Type",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  selectedMilkType = MilkType.cow;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: (selectedMilkType == MilkType.cow)
                        ? AppColors.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                height: 50,
                width: 0.45 * MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🐄",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: (selectedMilkType == MilkType.cow)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (selectedMilkType != MilkType.cow)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                    Text(
                      "  Cow",
                      style: TextStyle(
                        fontWeight: (selectedMilkType == MilkType.cow)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (selectedMilkType != MilkType.cow)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  selectedMilkType = MilkType.buffalo;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: (selectedMilkType != MilkType.cow)
                        ? AppColors.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                height: 50,
                width: 0.45 * MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🐃",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: (selectedMilkType != MilkType.cow)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (selectedMilkType == MilkType.cow)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                    Text(
                      " Buffalo",
                      style: TextStyle(
                        fontWeight: (selectedMilkType != MilkType.cow)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (selectedMilkType == MilkType.cow)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

Column shiftTypeRadio() {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          child: Text(
            "Shift Type",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  shiftType = ShiftType.morning;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: (shiftType == ShiftType.morning)
                        ? AppColors.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                height: 50,
                width: 0.45 * MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🌅",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: (shiftType == ShiftType.morning)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (shiftType != ShiftType.morning)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                    Text(
                      "  Morning",
                      style: TextStyle(
                        fontWeight: (shiftType == ShiftType.morning)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (shiftType != ShiftType.morning)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  shiftType = ShiftType.evening;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: (shiftType != ShiftType.morning)
                        ? AppColors.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                height: 50,
                width: 0.45 * MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🌃",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: (shiftType != ShiftType.morning)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (shiftType == ShiftType.morning)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                    Text(
                      " evening",
                      style: TextStyle(
                        fontWeight: (shiftType != ShiftType.morning)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: (shiftType == ShiftType.morning)
                            ? AppColors.secondaryColor
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  TextField priceInput() {
    return TextField(
      controller: weightCtr,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: const OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          filled: true,
          label: Text(
            "Weight",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
          hintText: "Weight of milk...",
          fillColor: Colors.white70),
    );
  }

  TextField snfInput() {
    return TextField(
      controller: snfCtr,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: const OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          filled: true,
          label: Text(
            "SNF",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
          hintText: "Type SNF amount here...",
          fillColor: Colors.white70),
    );
  }

  TextField fatInput() {
    return TextField(
      controller: fatCtr,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: const OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          filled: true,
          label: Text(
            "FAT",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
          hintText: "Type FAT amount here...",
          fillColor: Colors.white70),
    );
  }

  ValueListenableBuilder<Box<dynamic>> sellerDropdown() {
    return ValueListenableBuilder(
        valueListenable: Hive.box("sellerBox").listenable(),
        builder: (BuildContext context, Box<dynamic> b, d) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                )),
            child: DropdownButton<SellerModel>(
                borderRadius: BorderRadius.circular(10),
                underline: const SizedBox(),
                isExpanded: true,
                value: sellerModelChoice,
                hint: const Text("Select a Seller from the dropdown"),
                items: sellersList
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(e.sellerName.toString())))
                    .toList(),
                onChanged: (dynamic c) {
                  setState(() {
                    sellerModelChoice = c;
                  });
                }),
          );
        });
  }

  ValueListenableBuilder<Box<dynamic>> setupError() {
    return ValueListenableBuilder(
        valueListenable: Hive.box("settingBox").listenable(),
        builder: (BuildContext context, Box<dynamic> b, d) {
          return Visibility(
            visible: !appSettings.hasBeenSetupCheck(),
            child: Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "The app has not been setup correctly. Please Setup by clicking the Eye icon at the Appbar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset("assets/logo.png", width: 20,height: 20,),
      ),
      backgroundColor: const Color(0xff000311),
      title: Text(
        AppStrings.homeTitle,
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MenuUi()));
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(Icons.settings),
          ),
        )
      ],
    );
  }
}
