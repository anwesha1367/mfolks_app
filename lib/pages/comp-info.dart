import 'package:flutter/material.dart';
import 'package:mfolks_app/widget/custom_footer.dart';
import 'package:mfolks_app/widget/custom_header.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  int _selectedIndex = 2; // Home is selected by default

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/about");
        break;
      case 1:
        Navigator.pushNamed(context, "/quote");
        break;
      case 2:
        Navigator.pushNamed(context, "/home");
        break;
      case 3:
        Navigator.pushNamed(context, "/analytics");
        break;
      case 4:
        Navigator.pushNamed(context, "/calculator");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(isHome: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Company Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            const Text(
              "Company Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),
            _buildTextField("Name"),
            _buildTextField("Email ID"),
            _buildTextField("Mobile No."),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Upload GST Details",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Address Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),
            _buildTextField("Pincode", initialValue: "450116"),
            _buildTextField("Address", initialValue: "216 St Paul’s Rd,"),
            _buildTextField("City", initialValue: "N1 2LL,"),
            _buildTextField("State", initialValue: "London"),
            _buildTextField("Country", initialValue: "United Kingdom"),
          ],
        ),
      ),

      // ✅ Reusable Footer
      bottomNavigationBar: CustomFooter(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Reusable TextField Builder
  Widget _buildTextField(String label, {String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
