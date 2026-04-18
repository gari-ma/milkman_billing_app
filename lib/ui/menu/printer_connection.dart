
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printer_module/db/setting_db.dart';
import 'package:printer_module/extension/snackbar_xn.dart';
import 'package:printer_module/res/colors.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({Key? key}) : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  final AppSettings _appSettings = AppSettings();
  bool isVisibleProgressBar = false;

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thermal Printer Setting"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondaryColor,
          child: const Icon(
            Icons.refresh,
          ),
          onPressed: () {
            getDevices();
          }),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                Text("Currently connected Printer: ${_appSettings.bluetoothName ?? "Not connected"}")
              ]
              ),
            sellerDropdown(),
            const SizedBox(height: 10),
            saveButton(),
            Container(
                padding: const EdgeInsets.only(top: 30),
                child: Visibility(
                    visible: isVisibleProgressBar,
                    child: const CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    printer.disconnect();
    super.dispose();
  }

  Widget sellerDropdown() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.black,
          )),
      child: DropdownButton<BluetoothDevice>(
          borderRadius: BorderRadius.circular(10),
          underline: const SizedBox(),
          isExpanded: true,
          value: selectedDevice,
          hint: const Text("choose Printer from dropdown"),
          items: devices
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name!),
                  ))
              .toList(),
          onChanged: (BluetoothDevice? value) {
            setState(() {
              selectedDevice = value!;
            });
          }),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: () {
          isVisibleProgressBar = true;
          setState(() {});
          if (selectedDevice == null) {
            showErrorSnackBar(
                context: context,
                message: "Please select a printer device from the dropdown.");

            isVisibleProgressBar = false;
            setState(() {});
          } else {
            printer.connect(selectedDevice!).then((value) {
              _appSettings.saveBluetooth(
                  selectedDevice!.name!, selectedDevice!.address!);
              showSuccessSnackBar(
                  context: context, message: "Successfully saved device.");

              isVisibleProgressBar = false;
              setState(() {});
            }).catchError((e) {
              showErrorSnackBar(
                  context: context,
                  message:
                      "Printer connection failed for the selected device.");

              isVisibleProgressBar = false;
              setState(() {});
            });
          }
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
}
