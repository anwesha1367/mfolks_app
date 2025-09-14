import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F1),
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF00695C)),
                  ),
                ),
                accountName: const Text(
                  "John Smith",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text(
                  "loremipsum@email.com",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.business, "My Company Info", () {
              Navigator.pushNamed(context, "/companyInfo");
            }),
            _buildDrawerItem(Icons.local_shipping, "Shipping Details", () {
              Navigator.pushNamed(context, "/shipping");
            }),
            _buildDrawerItem(Icons.history, "Order History", () {
              Navigator.pushNamed(context, "/orders");
            }),
            _buildDrawerItem(Icons.settings, "Settings", () {
              Navigator.pushNamed(context, "/settings");
            }),
            const Divider(height: 20, thickness: 1),
            _buildDrawerItem(Icons.logout, "Logout", () {
              Navigator.pushReplacementNamed(context, "/login");
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red.shade600 : const Color(0xFF00695C),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red.shade600 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: Colors.teal.withOpacity(0.1),
      ),
    );
  }
}
