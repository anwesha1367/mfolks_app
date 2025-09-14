import 'package:flutter/material.dart';

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final List<Map<String, String>> addresses = [
    {
      "pincode": "450116",
      "address": "216 St Paul's Rd,",
      "city": "London",
      "state": "N1 2LL",
      "country": "United Kingdom"
    }
  ];

  void addNewAddress() {
    setState(() {
      addresses.add({
        "pincode": "",
        "address": "",
        "city": "",
        "state": "",
        "country": ""
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Address"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              for (int i = 0; i < addresses.length; i++)
                addressForm(i),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: addNewAddress,
                child: const Text("Add New Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addressForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Address ${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        TextFormField(
          decoration: const InputDecoration(labelText: "Pincode"),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Address"),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "City"),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "State"),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Country"),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
