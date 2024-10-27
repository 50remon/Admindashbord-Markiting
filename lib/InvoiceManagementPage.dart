import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InvoicePage extends StatefulWidget {
  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  List<Map<String, dynamic>> invoices = [];
  Map<int, bool> selectedInvoices = {};

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? invoicesData = prefs.getString('invoices');
    if (invoicesData != null) {
      setState(() {
        invoices = List<Map<String, dynamic>>.from(json.decode(invoicesData));
      });
    }
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('invoices', json.encode(invoices));
  }

  void _deleteSelectedInvoices() async {
    setState(() {
      invoices.removeWhere((invoice) => selectedInvoices[invoices.indexOf(invoice)] ?? false);
      selectedInvoices.clear();
    });
    await _saveInvoices();
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تفاصيل الفاتورة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer: ${invoice["customerName"]}"),
              Text("Date: ${invoice["date"]}"),
              Text("Total: \$${invoice["totalAmount"].toStringAsFixed(2)}"),
              const Divider(),
              ...invoice["products"].map<Widget>((product) {
                return Text(
                    "${product["name"]} - Qty: ${product["quantity"]}, Total: \$${product["total"]}");
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الفواتير"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: selectedInvoices.values.any((isSelected) => isSelected)
                ? _deleteSelectedInvoices
                : null,
          ),
        ],
      ),
      body: invoices.isEmpty
          ? const Center(child: Text("No invoices available"))
          : ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text("Customer: ${invoice["customerName"]}"),
            subtitle: Text("Date: ${invoice["date"]}"),
            trailing: Checkbox(
              value: selectedInvoices[index] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  selectedInvoices[index] = value ?? false;
                });
              },
            ),
            onTap: () {
              _showInvoiceDetails(invoice);
            },
          );
        },
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];
  Map<int, int> selectedProducts = {}; // الكمية المحددة لكل منتج

  Future<void> _saveInvoices(List<Map<String, dynamic>> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('invoices', json.encode(invoices));
  }

  void _paySelectedProducts() async {
    double totalAmount = 0.0;
    List<Map<String, dynamic>> selectedProductDetails = [];

    selectedProducts.forEach((index, quantity) {
      final product = products[index];
      double totalProductPrice = product["price"] * quantity;
      totalAmount += totalProductPrice;
      selectedProductDetails.add({
        "name": product["name"],
        "price": product["price"],
        "quantity": quantity,
        "total": totalProductPrice,
      });
    });

    final customerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invoice Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: "Customer Name"),
              ),
              const SizedBox(height: 10),
              ...selectedProductDetails.map((product) {
                return ListTile(
                  title: Text(product["name"]),
                  subtitle: Text("Quantity: ${product["quantity"]}"),
                  trailing: Text("Total: \$${product["total"]}"),
                );
              }).toList(),
              const Divider(),
              Text("Total Amount: \$${totalAmount.toStringAsFixed(2)}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Confirm"),
              onPressed: () async {
                final invoice = {
                  "customerName": customerController.text,
                  "date": DateTime.now().toString(),
                  "products": selectedProductDetails,
                  "totalAmount": totalAmount,
                };
                final prefs = await SharedPreferences.getInstance();
                final String? invoicesData = prefs.getString('invoices');
                List<Map<String, dynamic>> invoices = invoicesData != null
                    ? List<Map<String, dynamic>>.from(json.decode(invoicesData))
                    : [];
                invoices.add(invoice);
                await _saveInvoices(invoices);
                setState(() {
                  selectedProducts.clear();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: selectedProducts.isEmpty ? null : _paySelectedProducts,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]["name"]),
            subtitle: Text("\$${products[index]["price"]}"),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  selectedProducts[index] =
                      (selectedProducts[index] ?? 0) + 1; // زيادة الكمية
                });
              },
              child: const Text("Add Quantity"),
            ),
          );
        },
      ),
    );
  }
}
