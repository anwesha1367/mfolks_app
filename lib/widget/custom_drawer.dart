import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
      UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
      color: Colors.teal,
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 40, color: Colors.teal),
      ),
      accountName: const Text(
        "John Smith",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: const Text("loremipsum@email.com"),
    ),
    ListTile(
    leading: const Icon(Icons.business),
    title: const Text("My Company Info"),
    onTap: () {
    Navigator.pushNamed(context, "/companyInfo");
    },
    ),
    ListTile(
    leading: const Icon(Icons.local_shipping),
    title: const Text("Shipping Details"),
    onTap: () {
    Navigator.pushNamed(context, "/shipping");
    },
    ),
    ListTile(
    leading: const Icon(Icons.history),
    title: const Text("Order History"),
    onTap: () {
    Navigator.pushNamed(context, "/orders");
    },
    ),
    ListTile(
    leading: const Icon(Icons.settings),
    title: const Text("Settings"),
    onTap: () {
    Navigator.pushNamed(context, "/settings");
    },
    ),
          ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: const Text("Contact Us"),
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            onTap: () {
              Navigator.pushNamed(context, '/language');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout,color: Colors.red),
            title: const Text("Logout",style:TextStyle(color: Colors.red) ),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
