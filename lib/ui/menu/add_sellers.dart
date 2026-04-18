import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:printer_module/db/sellers_db.dart';
import 'package:printer_module/extension/random_index_generator.dart';
import 'package:printer_module/extension/snackbar_xn.dart';
import 'package:printer_module/model/seller_model.dart';

class AddSeller extends StatefulWidget {
  const AddSeller({Key? key}) : super(key: key);

  @override
  State<AddSeller> createState() => _AddSellerState();
}

class _AddSellerState extends State<AddSeller> {
  final SellersDb _sellersDb = SellersDb();
  TextEditingController sellerNameCtr = TextEditingController(),
      sellerAddressctr = TextEditingController(),
      sellerContactDetailsCtr = TextEditingController(),
      createdAtEpochCtr = TextEditingController(),
      sellerSlugCtr = TextEditingController();

  Future<void> addNewSeller() async {
    if (sellerNameCtr.text.isEmpty) {
      showErrorSnackBar(
          context: context,
          message: "Error, Please at least input seller name!");
      return;
    }

    SellerModel sellerModel = SellerModel(
        sellerName: sellerNameCtr.text.trim(),
        sellerAddress: sellerAddressctr.text.trim(),
        sellerContactDetails: sellerContactDetailsCtr.text.trim(),
        sellerSlug: RandomGenerator().randomIndexGenerator(),
        createdAtEpoch: DateTime.now().millisecondsSinceEpoch.toString());
    await _sellersDb.addNewSeller(sellerModel);
    Logger().d("SellerSlug ${sellerModel.sellerSlug}");
    showSuccessSnackBar(
        context: context, message: "New seller added successfully!");
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Seller"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: mainListView(),
      ),
    );
  }

  ListView mainListView() {
    return ListView(
      children: [
        sellerName(),
        Container(
          height: 20,
        ),
        selelrAddress(),
        Container(
          height: 20,
        ),
        selelrDetails(),
        Container(
          height: 20,
        ),
        addBtn(),
      ],
    );
  }

  Padding addBtn() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: MaterialButton(
          color: Colors.green,
          splashColor: Colors.grey,
          onPressed: addNewSeller,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "ADD",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }

  Padding selelrDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: sellerContactDetailsCtr,
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
              "Seller Contact Details and Remarks",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "Eg. a@b.com, +0000000000",
            fillColor: Colors.white70),
      ),
    );
  }

  Padding selelrAddress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: sellerAddressctr,
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
              "Seller Address",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "Seller`s address",
            fillColor: Colors.white70),
      ),
    );
  }

  Padding sellerName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: sellerNameCtr,
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
              "Seller Name",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[800]),
            hintText: "Seller Name",
            fillColor: Colors.white70),
      ),
    );
  }
}
