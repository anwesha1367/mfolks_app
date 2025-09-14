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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Color(0xFF00695C)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "John Smith",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Loremipsum@email.com",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('Edit button pressed - navigating to editProfile');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigating to Edit Profile...')),
                      );
                      Navigator.pushNamed(context, '/editProfile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "General",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy Section
            _buildPrivacySection(),

            const SizedBox(height: 12),

            // Notifications toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                },
                title: const Text(
                  "Notification",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                secondary: const Icon(Icons.notifications, color: Color(0xFF00695C)),
                activeColor: const Color(0xFF00695C),
              ),
            ),

            const SizedBox(height: 12),

            // Accessibility Section
            _buildAccessibilitySection(),

            const SizedBox(height: 12),

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
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/about');
              break;
            case 1:
              Navigator.pushNamed(context, '/quote');
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.lock, color: Color(0xFF00695C)),
        title: const Text(
          "Privacy",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        title,
        style:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        switch (title) {
          case "Reset Password":
            Navigator.pushNamed(context, "/resetPassword");
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

  // 🔹 Delete Account Dialog (MFOLKS style)
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Image.asset(
                "assets/mfolks-logo.png",
                height: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to delete your Account permanently?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted permanently")),
                );
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("Confirm"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }

  // Accessibility section
  Widget _buildAccessibilitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.accessibility, color: Color(0xFF00695C)),
        title: const Text(
          "Accessibility",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Font Size",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _fontSize,
                  min: 10,
                  max: 20,
                  divisions: 10,
                  label: _fontSize.round().toString(),
                  activeColor: const Color(0xFF00695C),
                  onChanged: (val) {
                    setState(() {
                      _fontSize = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  "Button Size",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _buttonSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: _buttonSize.round().toString(),
                  activeColor: const Color(0xFF00695C),
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
                  activeColor: const Color(0xFF00695C),
                  onChanged: (val) {
                    setState(() {
                      _touchFeedback = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  "Language Preference",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/language');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _languagePreference,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF00695C)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Feedback section
  Widget _buildFeedbackSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.feedback, color: Color(0xFF00695C)),
        title: const Text(
          "Feedback",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rate us",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
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
                        index < _feedbackRating
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFF00695C),
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                const Text(
                  "How can we improve",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share your feedback...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thank you for your feedback!"),
                          backgroundColor: Color(0xFF00695C),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
