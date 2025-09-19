import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/user_notifier.dart';
import '../models/user.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(userProvider);
    final String displayName = user?.fullname?.trim().isNotEmpty == true ? user!.fullname!.trim() : 'Guest';
    final String displayEmail = user?.email?.trim().isNotEmpty == true ? user!.email!.trim() : 'No email';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
      UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
      color: Colors.teal,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: (user?.profilePictureUrl != null && (user!.profilePictureUrl!.isNotEmpty))
            ? NetworkImage(user.profilePictureUrl!)
            : null,
        child: (user?.profilePictureUrl == null || (user!.profilePictureUrl!.isEmpty))
            ? const Icon(Icons.person, size: 40, color: Colors.teal)
            : null,
      ),
      accountName: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(displayEmail),
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
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await ref.read(userProvider.notifier).clear();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
