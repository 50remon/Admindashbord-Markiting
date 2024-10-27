import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];
  Map<int, int> selectedProducts = {}; // يحدد الكمية المطلوبة لكل منتج
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadInvoices();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsData = prefs.getString('products');
    if (productsData != null) {
      setState(() {
        products = List<Map<String, dynamic>>.from(json.decode(productsData));
      });
    }
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

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('products', json.encode(products));
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('invoices', json.encode(invoices));
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final profitController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: profitController,
                decoration: const InputDecoration(labelText: "Profit"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                setState(() {
                  products.add({
                    "name": nameController.text,
                    "price": double.parse(priceController.text),
                    "quantity": int.parse(quantityController.text),
                    "profit": double.parse(profitController.text),
                  });
                });
                _saveProducts();
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

  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
      selectedProducts.remove(index);
    });
    _saveProducts();
  }

  void _increaseQuantity(int index) {
    setState(() {
      selectedProducts[index] = (selectedProducts[index] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (selectedProducts[index] != null && selectedProducts[index]! > 0) {
        selectedProducts[index] = selectedProducts[index]! - 1;
      }
    });
  }

  void _paySelectedProducts() {
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
          content: SingleChildScrollView(
            child: Column(
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
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                final invoice = {
                  "customerName": customerController.text,
                  "date": DateTime.now().toString(),
                  "products": selectedProductDetails,
                  "totalAmount": totalAmount,
                };
                setState(() {
                  invoices.add(invoice);
                  selectedProducts.clear();
                });
                _saveInvoices();
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

  void _showInvoices() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => InvoiceList(invoices: invoices),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("قائمة المنتاجات"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: _showInvoices,
          ),
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: selectedProducts.isEmpty ? null : _paySelectedProducts,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Checkbox(
              value: selectedProducts.containsKey(index),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedProducts[index] = 1;
                  } else {
                    selectedProducts.remove(index);
                  }
                });
              },
            ),
            title: Text(product["name"]),
            subtitle: Text(
                "Price: ${product["price"]} - Available Quantity: ${product["quantity"]} - Profit: ${product["profit"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _decreaseQuantity(index),
                ),
                Text('${selectedProducts[index] ?? 0}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _increaseQuantity(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InvoiceList extends StatelessWidget {
  final List<Map<String, dynamic>> invoices;

  InvoiceList({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoices")),
      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text("Customer: ${invoice["customerName"]}"),
            subtitle: Text("Total: \$${invoice["totalAmount"]}"),
            trailing: Text(invoice["date"]),
            onTap: () {
              // عرض تفاصيل الفاتورة
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Invoice Details"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Customer: ${invoice["customerName"]}"),
                        Text("Date: ${invoice["date"]}"),
                        const Divider(),
                        ...invoice["products"].map<Widget>((product) {
                          return ListTile(
                            title: Text(product["name"]),
                            subtitle: Text("Quantity: ${product["quantity"]}"),
                            trailing: Text("Total: \$${product["total"]}"),
                          );
                        }).toList(),
                        const Divider(),
                        Text("Total Amount: \$${invoice["totalAmount"]}"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
