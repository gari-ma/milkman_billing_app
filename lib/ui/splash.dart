import 'package:flutter/material.dart';
import 'package:printer_module/res/config.dart';
import 'package:printer_module/ui/billing.dart';

// splash screen, change as your choice

class SplashUi extends StatelessWidget {
  const SplashUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: AppConfig.splashDuration), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const BillingPage()));
    });

    return Scaffold(
        backgroundColor: const Color(0xff000311),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              "assets/logo.png",
              width: AppConfig.splashLogoWidth,
            )),
       
          ],
        ));
  }
}
