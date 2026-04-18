
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/setting_db.dart';
import '../../extension/snackbar_xn.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //late File file;
  late AppSettings appSettings;
  TextEditingController buyerNameCtr = TextEditingController(),
      sgstCtr = TextEditingController(),
      cgstCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    appSettings = AppSettings();

    _setupInputs();
  }

  void _setupInputs() {
    // file = File(appSettings.filePath);
    buyerNameCtr.text = appSettings.buyerName;
    sgstCtr.text = appSettings.sgst.toString();
    cgstCtr.text = appSettings.cgst.toString();
  }

  void _checkAndSaveData(BuildContext context) {
    // file exists, do other operations
    if (sgstCtr.text.isEmpty || cgstCtr.text.isEmpty) {
      showErrorSnackBar(
          context: context,
          message: "Error, Please fill out the input correctly!");
      return;
    }

    if (appSettings.saveSettings(
            buyerNameCtr.text.trim(),
            double.parse(sgstCtr.text.trim()),
            double.parse(cgstCtr.text.trim()),
            "") ==
        1) {
      // success saved
      showSuccessSnackBar(context: context, message: "Successfully Saved");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const ListTile(
            title: Text("Company's Information"),
          ),
          buyersName(),
          Container(
            height: 20,
          ),
          sgstInput(),
          Container(
            height: 20,
          ),
          cgstInput(),
          Container(
            height: 20,
          ),
          saveButton(),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () {
          _checkAndSaveData(context);
        },
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: const OutlineInputBorder(
                // width: 0.0 produces a thin "hairline" border
                borderSide: BorderSide(color: Colors.green, width: 1.5),
              ),
              filled: true,
              label: Center(
                child: Text(
                  "Save",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
              hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
              fillColor: Colors.green),
        ),
      ),
    );
  }

  Padding cgstInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: cgstCtr,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            label: Text(
              "CGST",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "CGST Percentage",
            fillColor: Colors.white70),
      ),
    );
  }

  Padding sgstInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: sgstCtr,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            label: Text(
              "SGST",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "SGST Percentage",
            fillColor: Colors.white70),
      ),
    );
  }

  Padding buyersName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: buyerNameCtr,
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
              "Buyer`s name",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "Buyer`s Name",
            fillColor: Colors.white70),
      ),
    );
  }
}
