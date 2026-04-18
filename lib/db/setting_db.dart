import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  late Box _settingBox;

  bool hasBeenSetup = false;
  String buyerName = "";
  double sgst = 0;
  double cgst = 0;
  String filePath = "";
  String businessName = "";
  String businessAddress = "";
  String businessPhone = "";
  String logoPath = "";

  // bluetooth connection params
  String? bluetoothName;
  String? bluetoothAddress;

  AppSettings() {
    _settingBox = Hive.box("settingBox");
    _setAppSettings();
  }

  void _setAppSettings() {
    hasBeenSetup = _settingBox.get("hasBeenSetup") ?? false;
    buyerName = _settingBox.get("buyerName") ?? "";
    sgst = _settingBox.get("sgst") ?? 0;
    cgst = _settingBox.get("cgst") ?? 0;
    filePath = _settingBox.get("filePath") ?? "";
    businessName = _settingBox.get("businessName") ?? "";
    businessAddress = _settingBox.get("businessAddress") ?? "";
    businessPhone = _settingBox.get("businessPhone") ?? "";
    logoPath = _settingBox.get("logoPath") ?? "";
    bluetoothName = _settingBox.get("bluetoothName");
    bluetoothAddress = _settingBox.get("bluetoothAddress");
  }

  int saveSettings(
      String buyerName,
      double sgst,
      double cgst,
      String filePath, {
      String businessName = "",
      String businessAddress = "",
      String businessPhone = "",
      String logoPath = ""}) {
    _settingBox.put("hasBeenSetup", true);
    _settingBox.put("buyerName", buyerName);
    _settingBox.put("sgst", sgst);
    _settingBox.put("cgst", cgst);
    _settingBox.put("filePath", filePath);
    _settingBox.put("businessName", businessName);
    _settingBox.put("businessAddress", businessAddress);
    _settingBox.put("businessPhone", businessPhone);
    _settingBox.put("logoPath", logoPath);
    return 1;
  }

  int saveBluetooth(String bluetoothName, String bluetoothAddress) {
    _settingBox.put('bluetoothName', bluetoothName);
    _settingBox.put('bluetoothAddress', bluetoothAddress);
    return 1;
  }

  bool hasBeenSetupCheck() {
    return _settingBox.get("hasBeenSetup") ?? false;
  }
}
