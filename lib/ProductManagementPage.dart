import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/Homescreen.dart';
import 'package:untitled2/main.dart';
import 'package:untitled2/ProductManagementPage.dart';

import 'Collectproduct.dart';
import 'Someofproduct.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildDashboardTile(context, 'جملة', Icons.inventory, ProductPage()),
          _buildDashboardTile(context, 'تجزئه', Icons.add_business_outlined, SomeofProduct()),
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

