import 'dart:math';

class RandomGenerator {
  final String _chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890/*-+?.,()%#@!";
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String randomIndexGenerator() {
    DateTime dateTime = DateTime.now();
    return dateTime.millisecondsSinceEpoch.toString() + getRandomString(5);
  }
}
