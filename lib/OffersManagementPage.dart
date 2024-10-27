import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/Someofproduct.dart';
import 'InvoiceManagementPage.dart';

class OffersManagementPage extends StatefulWidget {
  @override
  _OffersManagementPageState createState() => _OffersManagementPageState();
}

class _OffersManagementPageState extends State<OffersManagementPage> {
  List<Map<String, dynamic>> offers = [];
  Map<int, int> selectedOffers = {};
  List<Map<String, dynamic>> invoices = [];

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

  Future<void> _saveOffers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('offers', json.encode(offers));
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

  void _decreaseQuantity(int index) {
    setState(() {
      if (selectedOffers.containsKey(index) && selectedOffers[index]! > 1) {
        selectedOffers[index] = selectedOffers[index]! - 1;
      } else {
        selectedOffers.remove(index);
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      selectedOffers[index] = (selectedOffers[index] ?? 0) + 1;
    });
  }

  void _deleteOffer(int index) {
    setState(() {
      offers.removeAt(index);
      _saveOffers();
    });
  }

  void _showAddOfferDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("إضافة عرض"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم المنتج"),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "السعر"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("إضافة"),
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  setState(() {
                    offers.add({
                      "name": nameController.text,
                      "price": double.parse(priceController.text),
                      "discount": 0.0,
                      "quantity": 0,
                    });
                  });
                  _saveOffers();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("يرجى ملء جميع الحقول")),
                  );
                }
              },
            ),
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _paySelectedOffers() {
    double totalAmount = 0.0;
    List<Map<String, dynamic>> selectedOfferDetails = [];

    selectedOffers.forEach((index, quantity) {
      if (index >= 0 && index < offers.length) {
        final offer = offers[index];
        double totalOfferPrice = offer["price"] * quantity;
        totalAmount += totalOfferPrice;
        selectedOfferDetails.add({
          "name": offer["name"],
          "price": offer["price"],
          "quantity": quantity,
          "total": totalOfferPrice,
        });
      }
    });

    if (selectedOfferDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يوجد عروض محددة للدفع")),
      );
      return;
    }

    final customerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تفاصيل الفاتورة"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerController,
                  decoration: const InputDecoration(labelText: "اسم العميل"),
                ),
                const SizedBox(height: 10),
                ...selectedOfferDetails.map((offer) {
                  return ListTile(
                    title: Text(offer["name"]),
                    subtitle: Text("الكمية: ${offer["quantity"]}"),
                    trailing: Text("المجموع: \$${offer["total"]}"),
                  );
                }).toList(),
                const Divider(),
                Text("إجمالي المبلغ: \$${totalAmount.toStringAsFixed(2)}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("تأكيد"),
              onPressed: () {
                final invoice = {
                  "customer": customerController.text.isNotEmpty ? customerController.text : "Unnamed Customer",
                  "totalAmount": totalAmount,
                  "offers": selectedOfferDetails,
                  "date": DateTime.now().toString(),
                };

                setState(() {
                  invoices.add(invoice);
                  selectedOffers.clear();
                });
                _saveInvoices();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("إلغاء"),
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
        title: const Text("إدارة العروض"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvoiceList(invoices: invoices)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: selectedOffers.isEmpty ? null : _paySelectedOffers,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return ListTile(
            leading: Checkbox(
              value: selectedOffers.containsKey(index),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedOffers[index] = 1;
                  } else {
                    selectedOffers.remove(index);
                  }
                });
              },
            ),
            title: Text(offer["name"]),
            subtitle: Text(
                "السعر: ${offer["price"]} - الخصم: ${offer["discount"]} - الكمية المتاحة: ${offer["quantity"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _decreaseQuantity(index),
                ),
                Text('${selectedOffers[index] ?? 0}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _increaseQuantity(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteOffer(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOfferDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
