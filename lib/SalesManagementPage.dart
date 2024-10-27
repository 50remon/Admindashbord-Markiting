import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesManagementPage extends StatefulWidget {
  @override
  _SalesManagementPageState createState() => _SalesManagementPageState();
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  List<Map<String, dynamic>> offers = [];
  List<Map<String, dynamic>> invoices = [];
  double totalProfit = 0.0; // متغير لتخزين الربح الكلي

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _loadInvoices();
  }

  Future<void> _loadOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? offersData = prefs.getString('offers');
    if (offersData != null) {
      setState(() {
        offers = List<Map<String, dynamic>>.from(json.decode(offersData));
      });
    }
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? invoicesData = prefs.getString('invoices');
    if (invoicesData != null) {
      setState(() {
        invoices = List<Map<String, dynamic>>.from(json.decode(invoicesData));
        _calculateTotalProfit(); // حساب الربح الكلي عند تحميل الفواتير
      });
    }
  }

  void _calculateTotalProfit() {
    totalProfit = invoices.fold(0.0, (sum, invoice) {
      final offerDetails = invoice['offers'] as List? ?? [];
      return sum + offerDetails.fold(0.0, (total, item) {
        final offer = offers.firstWhere((offer) => offer['name'] == item['name'], orElse: () => {'price': 0.0});
        return total + (offer['price'] * item['quantity']); // الربح لكل عملية بيع
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المبيعات"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "الربح الكلي: ${totalProfit.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final offerName = offer['name'];

                // حساب الكمية المباعة
                final totalSold = invoices.fold(0, (sum, invoice) {
                  final offerDetails = invoice['offers'] as List? ?? [];
                  return sum + offerDetails.where((item) => item['name'] == offerName).fold(0, (sum, item) => sum + (item['quantity'] as int));
                });

                // حساب الكمية المتبقية
                final totalQuantity = offer['quantity'] as int; // الكمية الكلية
                final remainingQuantity = totalQuantity - totalSold; // الكمية المتبقية

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "السعر: ${offer['price']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "الكمية المباعة: $totalSold",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "الكمية الكلية: $totalQuantity",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "الكمية المتبقية: $remainingQuantity",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
