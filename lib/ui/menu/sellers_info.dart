import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printer_module/db/sellers_db.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:printer_module/res/colors.dart';
import 'package:printer_module/ui/menu/add_sellers.dart';
import 'package:printer_module/ui/menu/seller_more_info.dart';

class SellersInfo extends StatefulWidget {
  const SellersInfo({Key? key}) : super(key: key);

  @override
  State<SellersInfo> createState() => _SellersInfoState();
}

class _SellersInfoState extends State<SellersInfo> {
  late Iterable _sellers;
  SellersDb sellersDb = SellersDb();


  @override
  void initState() {
    _sellers = sellersDb.getSellers();

    super.initState();
  }

  Widget noDataWidget() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
      decoration: BoxDecoration(
          color: (Platform.isAndroid) ?  Colors.green: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Text(
        "No any Sellers found. You can add them from the + Button located at the bottom right corner.",
        style: TextStyle(color: (Platform.isAndroid) ?  Colors.white: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sellers Info"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondaryColor,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddSeller()));
          },
          child: const Icon(Icons.add),
        ),
        body: ValueListenableBuilder(
            valueListenable: Hive.box("sellerBox").listenable(),
            builder: (context, Box<dynamic> sBox, _) {
              _sellers = sellersDb.getSellers();
              return (_sellers.isEmpty)
                  ? noDataWidget()
                  : mainListView(context);
            }));
  }

  ListView mainListView(BuildContext context) {
    return ListView.builder(
        itemCount: _sellers.length,
        itemBuilder: (BuildContext contex, int index) {
          return Column(
            children: [
              Slidable(
                // The end action pane is the one at the right or the bottom side.
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 2,
                      onPressed: (BuildContext d) {
                        showDialogBar(context, index);
                      },
                      backgroundColor: const Color(0xFF7BC043),
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (BuildContext c) {
                         showUserInfo(context, index);
                      },
                      flex: 2,
                      backgroundColor: const Color(0xFF0392CF),
                      foregroundColor: Colors.white,
                      icon: Icons.view_agenda,
                      label: 'View',
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SellerMoreInfo(
                                sellerModel: _sellers.elementAt(index))));
                  },
                  leading: const Icon(Icons.person),
                  title: Text(_sellers.elementAt(index).sellerName.toString()),
                  subtitle: Text((_sellers
                          .elementAt(index)
                          .sellerAddress
                          .toString()
                          .isNotEmpty)
                      ? _sellers.elementAt(index).sellerAddress.toString()
                      : "Address: NaN"),
                ),
              ),
              const Divider()
            ],
          );
        });
  }

  Future<dynamic> showDialogBar(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return AlertDialog(
            title: Text(
                "Are you sure you want to delete ${_sellers.elementAt(index).sellerName} record?"),
            actions: [
              MaterialButton(
                child: const Text("Cancil", style: TextStyle()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.red,
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  sellersDb.deleteAt(index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


   Future<dynamic> showUserInfo(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return AlertDialog(
            title: Text(
                "${_sellers.elementAt(index).sellerName} record"),
            content: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Seller Name: ${_sellers.elementAt(index).sellerName}"),
                  Text("Seller Address: ${_sellers.elementAt(index).sellerAddress}"),
                  Text("Seller Contact Details: ${_sellers.elementAt(index).sellerContactDetails}"),
                  Text("Regestered at: ${DateTime.fromMillisecondsSinceEpoch(int.parse(_sellers.elementAt(index).createdAtEpoch.toString()))}"),
                ]
                ),
            ),
            actions: [
              MaterialButton(
                child: const Text("Cancil", style: TextStyle()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
