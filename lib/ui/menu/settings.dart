import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/res/gradient_app_bar.dart';
import '../../db/setting_db.dart';
import '../../extension/snackbar_xn.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings appSettings;
  TextEditingController buyerNameCtr = TextEditingController(),
      sgstCtr = TextEditingController(),
      cgstCtr = TextEditingController(),
      businessNameCtr = TextEditingController(),
      businessAddressCtr = TextEditingController(),
      businessPhoneCtr = TextEditingController();
  String _logoPath = "";

  @override
  void initState() {
    super.initState();
    appSettings = AppSettings();
    _setupInputs();
  }

  void _setupInputs() {
    buyerNameCtr.text = appSettings.buyerName;
    sgstCtr.text = appSettings.sgst.toString();
    cgstCtr.text = appSettings.cgst.toString();
    businessNameCtr.text = appSettings.businessName;
    businessAddressCtr.text = appSettings.businessAddress;
    businessPhoneCtr.text = appSettings.businessPhone;
    _logoPath = appSettings.logoPath;
  }

  void _pickLogo() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _logoPath = result.files.single.path!;
      });
    }
  }

  void _checkAndSaveData(BuildContext context) {
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
          "",
          businessName: businessNameCtr.text.trim(),
          businessAddress: businessAddressCtr.text.trim(),
          businessPhone: businessPhoneCtr.text.trim(),
          logoPath: _logoPath,
        ) ==
        1) {
      showSuccessSnackBar(context: context, message: "Successfully Saved");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: Text("Settings")),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const ListTile(
            title: Text("Business Information"),
          ),
          _logoPickerWidget(),
          const SizedBox(height: 16),
          _field(businessNameCtr, "Business Name", "Your business name..."),
          const SizedBox(height: 16),
          _field(businessAddressCtr, "Business Address", "Business address..."),
          const SizedBox(height: 16),
          _field(businessPhoneCtr, "Business Phone", "Phone number...",
              type: TextInputType.phone),
          const Divider(height: 32),
          const ListTile(
            title: Text("Buyer & Tax Information"),
          ),
          _field(buyerNameCtr, "Buyer's Name", "Buyer's name..."),
          const SizedBox(height: 16),
          _field(sgstCtr, "SGST %", "SGST Percentage",
              type: TextInputType.number),
          const SizedBox(height: 16),
          _field(cgstCtr, "CGST %", "CGST Percentage",
              type: TextInputType.number),
          const SizedBox(height: 20),
          _saveButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _logoPickerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Business Logo",
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: double.maxFinite,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[100],
              ),
              child: _logoPath.isNotEmpty && File(_logoPath).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(_logoPath), fit: BoxFit.contain))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: Colors.grey[500]),
                        const SizedBox(height: 6),
                        Text("Tap to select logo",
                            style: GoogleFonts.poppins(color: Colors.grey[600]))
                      ],
                    ),
            ),
          ),
          if (_logoPath.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _logoPath = ""),
              child: Text("Remove logo",
                  style: GoogleFonts.poppins(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Padding _field(TextEditingController ctr, String label, String hint,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: ctr,
        keyboardType: type,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            filled: true,
            label: Text(label, style: GoogleFonts.poppins(color: Colors.black)),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: hint,
            fillColor: Colors.white70),
      ),
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () => _checkAndSaveData(context),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              label: Center(
                child: Text(
                  "Save",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
              fillColor: Colors.green),
        ),
      ),
    );
  }
}
