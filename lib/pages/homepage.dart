import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widget/custom_footer.dart';
import '../widget/custom_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Home selected
  late List<Product> products;

  @override
  void initState() {
    super.initState();
    // Placeholder products until API is connected
    products = [
      Product(
        name: "Ferrous Metals",
        description: "Strongest structure known. Trusted for your trust.",
        imageUrl: "https://via.placeholder.com/100x80.png?text=Ferrous",
      ),
      Product(
        name: "Non Ferrous Metals",
        description: "Light, strong, and versatile materials.",
        imageUrl: "https://via.placeholder.com/100x80.png?text=Non+Ferrous",
      ),
      Product(
        name: "Polymers",
        description: "Durable & dynamic. Shaping the future.",
        imageUrl: "https://via.placeholder.com/100x80.png?text=Polymers",
      ),
      Product(
        name: "Other Products",
        description: "Shoes, accessories & more.",
        imageUrl: "https://via.placeholder.com/100x80.png?text=Others",
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/about");
        break;
      case 1:
        Navigator.pushNamed(context, "/home");
        break;
      case 2:
        Navigator.pushNamed(context, "/analytics");
        break;
      case 3:
        Navigator.pushNamed(context, "/calculator");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset("assets/mfolks-logo.png", height: 40),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.person_outline, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Image.network(product.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(product.description),
              trailing: ElevatedButton(
                onPressed: () {
                  // later connect product details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Explore →"),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomFooter(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
