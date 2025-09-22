import 'package:flutter/material.dart';
import '../widget/custom_footer.dart';
import '../widget/custom_header.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool showUnread = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(isHome: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const Text(
                "Notifications",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Tabs (All / Unread)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTabButton("All", !showUnread),
                  const SizedBox(width: 12),
                  _buildTabButton("Unread", showUnread),
                ],
              ),
              const SizedBox(height: 16),

              // Notification List
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomFooter(
        currentIndex: 3, // Analytics tab
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

  Widget _buildTabButton(String text, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showUnread = text == "Unread";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.teal.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.message_outlined, color: Colors.teal),
        title: const Text("Notification"),
        trailing: const Icon(Icons.more_horiz),
      ),
    );
  }
}
