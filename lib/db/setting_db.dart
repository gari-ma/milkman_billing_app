import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  late Box _settingBox;

  bool hasBeenSetup = false;
  String buyerName = "";
  double sgst = 0;
  double cgst = 0;
  String filePath = "";

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
    bluetoothName = _settingBox.get("bluetoothName");
    bluetoothAddress = _settingBox.get("bluetoothAddress");
  }

  int saveSettings(
      String buyerName,
      double sgst,
      double cgst,
      String filePath) {
    _settingBox.put("hasBeenSetup", true);
    _settingBox.put("buyerName", buyerName);
    _settingBox.put("sgst", sgst);
    _settingBox.put("cgst", cgst);
    _settingBox.put("filePath", filePath);
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
