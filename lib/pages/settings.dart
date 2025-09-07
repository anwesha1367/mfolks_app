import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  double _fontSize = 14;
  double _buttonSize = 16;
  bool _touchFeedback = true;
  String _languagePreference = 'English';
  int _feedbackRating = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: [
            Image.asset(
              "assets/mfolks-logo.png", 
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "MFOLKS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.person, color: Colors.black),
          SizedBox(width: 12),
        ],
        leading: const Icon(Icons.notifications_none, color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 35, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("John Smith",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Loremipsum@email.com",
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text("Edit", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("General",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),
            
            // Privacy Section
            _buildPrivacySection(),
            
            const SizedBox(height: 8),
            
            // Notifications toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                },
                title: const Text("Notification"),
                secondary: const Icon(Icons.notifications),
                activeColor: Colors.teal,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Accessibility Section
            _buildAccessibilitySection(),
            
            const SizedBox(height: 8),
            
            // Feedback Section
            _buildFeedbackSection(),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: "About Us"),
          BottomNavigationBarItem(
              icon: Icon(Icons.request_quote_outlined), label: "Quote"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: "Analytics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined), label: "Calculator"),
        ],
      ),
    );
  }


  Widget _buildPrivacySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.lock, color: Colors.teal),
        title: const Text("Privacy", style: TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildPrivacyOption("Reset Password", Icons.lock_reset),
                const Divider(height: 1),
                _buildPrivacyOption("Permission Manager", Icons.admin_panel_settings),
                const Divider(height: 1),
                _buildPrivacyOption("Delete My Account", Icons.delete_forever),
                const Divider(height: 1),
                _buildPrivacyOption("Privacy Policy", Icons.policy),
                const Divider(height: 1),
                _buildPrivacyOption("Log out", Icons.logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        // Handle navigation or action based on the option
        switch (title) {
          case "Reset Password":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Reset Password functionality")),
            );
            break;
          case "Permission Manager":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Permission Manager opened")),
            );
            break;
          case "Delete My Account":
            _showDeleteAccountDialog();
            break;
          case "Privacy Policy":
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Privacy Policy opened")),
            );
            break;
          case "Log out":
            _showLogoutDialog();
            break;
        }
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deletion requested")),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccessibilitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.accessibility, color: Colors.teal),
        title: const Text("Accessibility", style: TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Font Size", style: TextStyle(fontWeight: FontWeight.w500)),
                Slider(
                  value: _fontSize,
                  min: 10,
                  max: 20,
                  divisions: 10,
                  label: _fontSize.round().toString(),
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    setState(() {
                      _fontSize = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text("Button Size", style: TextStyle(fontWeight: FontWeight.w500)),
                Slider(
                  value: _buttonSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: _buttonSize.round().toString(),
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    setState(() {
                      _buttonSize = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text("Touch Feedback"),
                  value: _touchFeedback,
                  activeColor: Colors.teal,
                  onChanged: (val) {
                    setState(() {
                      _touchFeedback = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text("Language Preference", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _languagePreference,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['English', 'Spanish', 'French', 'German', 'Hindi']
                      .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _languagePreference = val!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.feedback, color: Colors.teal),
        title: const Text("Feedback", style: TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rate us", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _feedbackRating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < _feedbackRating ? Icons.star : Icons.star_border,
                        color: Colors.teal,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                const Text("How can we improve", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share your feedback...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thank you for your feedback!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
