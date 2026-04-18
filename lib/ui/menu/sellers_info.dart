import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printer_module/db/sellers_db.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:printer_module/res/gradient_app_bar.dart';
import 'package:printer_module/res/theme.dart';
import 'package:printer_module/ui/menu/add_sellers.dart';
import 'package:printer_module/ui/menu/seller_more_info.dart';

class SellersInfo extends StatefulWidget {
  const SellersInfo({Key? key}) : super(key: key);

  @override
  State<SellersInfo> createState() => _SellersInfoState();
}

class _SellersInfoState extends State<SellersInfo> {
  late Iterable _sellers;
  final SellersDb sellersDb = SellersDb();

  @override
  void initState() {
    _sellers = sellersDb.getSellers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: const GradientAppBar(title: Text("Sellers")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddSeller())),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box("sellerBox").listenable(),
          builder: (context, Box<dynamic> sBox, _) {
            _sellers = sellersDb.getSellers();
            if (_sellers.isEmpty) return _emptyState();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _sellers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _sellerTile(context, index),
            );
          }),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text("No sellers yet",
            style: GoogleFonts.poppins(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text("Tap + to add a seller",
            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13)),
      ]),
    );
  }

  Widget _sellerTile(BuildContext context, int index) {
    final seller = _sellers.elementAt(index);
    final initials = (seller.sellerName as String)
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.55,
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) => _confirmDelete(context, index),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            flex: 1,
            onPressed: (_) => _showInfo(context, index),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.info_rounded,
            label: 'Details',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SellerMoreInfo(sellerModel: seller))),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: Text(initials,
                style: GoogleFonts.poppins(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          title: Text(seller.sellerName.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(
            seller.sellerAddress?.toString().isNotEmpty == true
                ? seller.sellerAddress.toString()
                : "No address",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) {
    final seller = _sellers.elementAt(index);
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text("Delete Seller"),
              content: Text(
                  "Remove ${seller.sellerName}? This cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () {
                    sellersDb.deleteAt(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
              ],
            ));
  }

  Future<void> _showInfo(BuildContext context, int index) {
    final seller = _sellers.elementAt(index);
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(seller.createdAtEpoch.toString()));
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text(seller.sellerName.toString()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.location_on_rounded, seller.sellerAddress ?? "—"),
                  const SizedBox(height: 6),
                  _infoRow(Icons.phone_rounded,
                      seller.sellerContactDetails ?? "—"),
                  const SizedBox(height: 6),
                  _infoRow(Icons.calendar_today_rounded,
                      "${createdAt.day}/${createdAt.month}/${createdAt.year}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.primary),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(fontSize: 13))),
    ]);
  }
}
