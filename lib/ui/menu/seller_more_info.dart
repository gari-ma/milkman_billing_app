import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:printer_module/db/bill_db.dart';
import 'package:printer_module/db/price_db.dart';
import 'package:printer_module/model/bill_model.dart';
import 'package:printer_module/model/seller_model.dart';
import 'package:printer_module/ui/print.dart';

class SellerMoreInfo extends StatefulWidget {
  final SellerModel sellerModel;
  const SellerMoreInfo({Key? key, required this.sellerModel}) : super(key: key);

  @override
  State<SellerMoreInfo> createState() => _SellerMoreInfoState();
}

class _SellerMoreInfoState extends State<SellerMoreInfo> {
  final List<BillModel> _listOfBillModel = [];
  final BillDb _billDb = BillDb();

  @override
  void initState() {
    // add the Seller respective items here
    Iterable<BillModel> tempList = _billDb.getBills().where(
        (element) => (element.sellerSlug == widget.sellerModel.sellerSlug));
    _listOfBillModel.addAll(tempList);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.sellerModel.sellerName!),
        ),
        body: _listOfBillModel.isEmpty ? Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(10),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "No any bil data found fot this seller!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ): ListView.builder(
          itemCount: _listOfBillModel.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PrintUi(
                                sellerModel: widget.sellerModel,
                                fat: _listOfBillModel
                                    .elementAt(index)
                                    .fat
                                    .toString(),
                                snf: _listOfBillModel
                                    .elementAt(index)
                                    .snf
                                    .toString(),
                                milkType: (_listOfBillModel
                                            .elementAt(index)
                                            .milkType ==
                                        0)
                                    ? MilkType.cow
                                    : MilkType.buffalo,
                                weight: _listOfBillModel
                                    .elementAt(index)
                                    .weight
                                    .toString(),
                                    shift: (_listOfBillModel.elementAt(index).shift == 0) ? ShiftType.morning: ShiftType.evening,
                                isSaveEnabled: false)));
                  },
                  leading: const Icon(CupertinoIcons.money_dollar),
                  title: Text(
                      "Invoice No. ${_listOfBillModel.elementAt(index).invoiceNumber}"),
                  subtitle: Text(
                      "Rs. ${_listOfBillModel.elementAt(index).price} | ${DateTime.fromMillisecondsSinceEpoch(int.parse(_listOfBillModel.elementAt(index).dateEpoch.toString()))}"),
                ),
                const Divider()
              ],
            );
          },
        ));
  }
}
