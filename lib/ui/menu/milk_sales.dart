import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printer_module/db/bill_db.dart';

import '../../db/price_db.dart';
import '../../model/bill_model.dart';

class MilkSales extends StatefulWidget {
  const MilkSales({Key? key}) : super(key: key);

  @override
  State<MilkSales> createState() => _MilkSalesState();
}

class _MilkSalesState extends State<MilkSales> {
  final BillDb _billDb = BillDb();
  late List<BillModel> _listOfBillModelMorning;
  DateFormat? formatter;
  late List<BillModel> _listOfBillModelEvening;
  DateTime dateTime = DateTime.now();
  String? formatted;
  double? morningShiftMoney;
  double? eveningShiftMoney;

  @override
  void initState() {
    _listOfBillModelMorning =
        _billDb.getBillFromShift(shift: ShiftType.morning, date: dateTime);
    _listOfBillModelEvening =
        _billDb.getBillFromShift(shift: ShiftType.evening, date: dateTime);

        morningShiftMoney = _billDb.getTotal(billModelList: _listOfBillModelMorning);
        eveningShiftMoney = _billDb.getTotal(billModelList: _listOfBillModelEvening);

    formatter = DateFormat('yyyy-MM-dd');
    formatted = formatter?.format(dateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Milk Sales"),
          actions: [
            Center(
              child: Text(formatted.toString()),
            ),
            GestureDetector(
              onTap: () {
                showDatePicker(
                        context: context,
                        initialDate: dateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2090))
                    .then((value) {
                  setState(() {
                    dateTime = value!;
                    formatter = DateFormat('yyyy-MM-dd');
                    formatted = formatter?.format(dateTime);
                    _listOfBillModelMorning = _billDb.getBillFromShift(
                        shift: ShiftType.morning, date: dateTime);
                    _listOfBillModelEvening = _billDb.getBillFromShift(
                        shift: ShiftType.evening, date: dateTime);
                  });
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.date_range_rounded),
              ),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.sunny),
                child: Text("Morning"),
              ),
              Tab(
                icon: Icon(Icons.sunny_snowing),
                child: Text("Evening"),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [morningScreen(), eveningScreen()],
        ),
      ),
    );
  }

  Widget morningScreen() {
    return (_listOfBillModelMorning.isEmpty)
        ? Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(10),
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "No any bil data found fot this seller!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Total Sales: "),
                  subtitle: const Text("Morning Shift"),
                  trailing: Text("Rs. $morningShiftMoney"),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _listOfBillModelMorning.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.money),
                          title: Text(
                              "Invoice No. ${_listOfBillModelMorning.elementAt(index).invoiceNumber}"),
                          subtitle: Text(
                              "Rs. ${_listOfBillModelMorning.elementAt(index).price} | ${_listOfBillModelMorning.elementAt(index).milkType == MilkType.cow.index ? "Cow": "Buffallo"}"),
                        ),
                        const Divider()
                      ],
                    );
                  },
                ),
              ],
            ),
          );
  }

  Widget eveningScreen() {
    return (_listOfBillModelEvening.isEmpty)
        ? Container(
            height: 20,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(10),
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "No any bil data found fot this seller!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Total Sales: "),
                  subtitle: const Text("Evening Shift"),
                  trailing: Text("Rs. $eveningShiftMoney"),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _listOfBillModelEvening.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.money),
                          title: Text(
                              "Invoice No. ${_listOfBillModelEvening.elementAt(index).invoiceNumber}"),
                          subtitle: Text(
                              "Rs. ${_listOfBillModelEvening.elementAt(index).price} | ${_listOfBillModelEvening.elementAt(index).milkType == MilkType.cow.index ? "Cow": "Buffallo"}"),
                        ),
                        const Divider()
                      ],
                    );
                  },
                ),
              ],
            ),
          );
  }
}
