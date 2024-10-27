import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/main.dart';

import 'Complaints.dart';
import 'InvoiceManagementPage.dart';
import 'OffersManagementPage.dart';
import 'OrderManagementPage.dart';
import 'ProductManagementPage.dart';
import 'SalesManagementPage.dart';
class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mohamed markiting'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildDashboardTile(context, 'ادارة المنتجات', Icons.inventory, const ProductManagementPage()),
          _buildDashboardTile(context, 'المبيعات', Icons.sell_outlined, SalesManagementPage()),
          _buildDashboardTile(context, 'ادارة الطلبات', Icons.list_alt, const OrderManagementPage()), // صفحة المنتجات
          _buildDashboardTile(context, 'الفواتير', Icons.receipt, InvoicePage()),  // صفحة الفواتير
          _buildDashboardTile(context, 'ادارة العروض', Icons.local_offer, OffersManagementPage()),  // صفحة العروض
        // صفحة الأوراق المالية
          _buildDashboardTile(context, 'الشكاوي', Icons.co_present_rounded, const Complaints()),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
