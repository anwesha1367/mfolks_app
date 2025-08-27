//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {

  bool _obscurePassword = true;
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/mfolks-logo.png',
                    width:180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Partner Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),

                // Email / Mobile field
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: "Email or Mobile No.",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showSnackBar("Forgot Password tapped!");
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      _showSnackBar("Login button tapped!");
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Divider with text
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("- Or Sign in using -"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Social buttons (Google & Apple)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showSnackBar("Google login tapped!");
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        child: Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                          height: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _showSnackBar("Apple login tapped!");
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.apple, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Sign Up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not our partner yet? "),
                      GestureDetector(
                        onTap: () {
                          _showSnackBar("Sign Up tapped!");
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40), // extra space at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
