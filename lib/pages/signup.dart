import 'dart:async';
import 'dart:io' show Platform; // For Apple sign-in platform check
import 'package:mfolks_app/pages/homepage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../widget/custom_header.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedIndustry;
  final List<String> _industries = ['IT', 'Manufacturing', 'Medical'];

  bool _isSocialLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Signup Successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _googleAuth() async {
    if (_isSocialLoading) return;
    setState(() => _isSocialLoading = true);
    try {
      // Configure scopes as needed
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

      final account = await googleSignIn.signIn();
      if (account == null) {
        _showSnackBar('Google sign-in cancelled');
        return;
      }

      final auth = await account.authentication;
      final idToken = auth
          .idToken; // Send this to your backend to verify and create/login user
      final accessToken = auth.accessToken;

      if (idToken == null && accessToken == null) {
        _showSnackBar('Failed to retrieve Google tokens');
        return;
      }

      // TODO: Exchange idToken/accessToken with your backend to obtain your app token
      // Example:
      // await AuthService.instance.loginWithGoogle(idToken: idToken, accessToken: accessToken);

      _showSnackBar('Google sign-in successful: ${account.email}');
      // Optionally navigate on success
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackBar('Google sign-in error');
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  Future<void> _appleAuth() async {
    if (_isSocialLoading) return;

    // Apple Sign In is available on iOS/macOS (not on Android/Web)
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) {
      _showSnackBar('Apple Sign-In not supported on this platform');
      return;
    }

    setState(() => _isSocialLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken; // JWT from Apple
      final authorizationCode =
          credential.authorizationCode; // Short-lived code

      if (identityToken == null && authorizationCode.isEmpty) {
        _showSnackBar('Failed to retrieve Apple credentials');
        return;
      }

      // TODO: Send identityToken/authorizationCode to your backend to verify and create/login user
      // Example:
      // await AuthService.instance.loginWithApple(identityToken: identityToken, authorizationCode: authorizationCode);

      _showSnackBar('Apple sign-in successful');
      // Optionally navigate on success
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackBar('Apple sign-in error');
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pop(); // Assuming you pushed SignupPage from LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(isHome: false),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white, Color(0xFFF1F8E9)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/mfolks-logo-1.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Signup card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Partner Signup',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00695C),
                          ),
                        ),
                        const SizedBox(height: 30),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Enter first name'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Enter last name'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    value == null || !value.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _numberController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                    value == null || value.length < 8
                                    ? 'Enter a valid number'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedIndustry,
                                decoration: const InputDecoration(
                                  labelText: 'Industry',
                                  prefixIcon: Icon(
                                    Icons.business_outlined,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                items: _industries
                                    .map(
                                      (industry) => DropdownMenuItem(
                                        value: industry,
                                        child: Text(industry),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIndustry = value;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Select industry' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'Password too short'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF00695C),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) =>
                                    value != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00695C),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                  onPressed: _signup,
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
                  ),

                  const SizedBox(height: 30),

                  // Divider with text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.teal.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Or Sign up using',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isSocialLoading ? null : _googleAuth,
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                          child: const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _isSocialLoading ? null : _appleAuth,
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                          child: const Icon(
                            Icons.apple,
                            size: 28,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Back to Login link
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF00695C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
