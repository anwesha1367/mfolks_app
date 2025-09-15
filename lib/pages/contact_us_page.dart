import 'package:flutter/material.dart';
import '../widget/custom_footer.dart';
import '../widget/custom_drawer.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),
      drawer: const CustomDrawer(), // ✅ Drawer added
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How can we help you?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Contact list
              Expanded(
                child: ListView(
                  children: [
                    _buildContactTile(
                      icon: Icons.headset_mic_outlined,
                      title: "Customer Service",
                      details: ["📞 +91 9876543210", "✉️ support@example.com"],
                    ),
                    _buildContactTile(
                      icon: Icons.language,
                      title: "Website",
                      details: ["🌐 https://www.placeholder.com"],
                    ),
                    _buildContactTile(
                      icon: Icons.chat_outlined,
                      title: "WhatsApp",
                      details: ["📱 +91 9876543210"],
                    ),
                    _buildContactTile(
                      icon: Icons.facebook_outlined,
                      title: "Facebook",
                      details: ["🔗 https://facebook.com/placeholder"],
                    ),
                    _buildContactTile(
                      icon: Icons.camera_alt_outlined,
                      title: "Instagram",
                      details: ["🔗 https://instagram.com/placeholder"],
                    ),
                    _buildContactTile(
                      icon: Icons.linked_camera_outlined,
                      title: "LinkedIn",
                      details: ["🔗 https://linkedin.com/in/placeholder"],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),


      bottomNavigationBar: CustomFooter(
        currentIndex: 0, // You can keep About Us highlighted or set -1 for none
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/about');
              break;
            case 1:
              Navigator.pushNamed(context, '/feedback');
              break;
            case 2:
              Navigator.pushNamed(context, '/home');
              break;
            case 3:
              Navigator.pushNamed(context, '/analytics');
              break;
            case 4:
              Navigator.pushNamed(context, '/calculator');
              break;
          }
        },
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required List<String> details,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: details
            .map((detail) => ListTile(
          title: Text(detail),
          onTap: () {
            // Later: launch URL or dial number
          },
        ))
            .toList(),
      ),
    );
  }
}
