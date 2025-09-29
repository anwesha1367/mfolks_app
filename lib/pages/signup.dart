import 'dart:async';
import 'package:mfolks_app/pages/verify_otp_page.dart';
import 'package:flutter/material.dart';
import '../widget/custom_header.dart';
import '../services/signup_service.dart';
import '../widget/social_auth_buttons.dart';
// Removed direct Google/Apple SDK flows in favor of server-driven social auth

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
  List<Map<String, dynamic>> _industries = [];
  bool _industriesLoading = true;
  String _industriesError = '';
  // Social auth is handled via SocialAuthButtons now
  bool _isSignupLoading = false;
  String _signupError = '';

  @override
  void initState() {
    super.initState();
    _fetchIndustries();
  }

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

  Future<void> _fetchIndustries() async {
    setState(() {
      _industriesLoading = true;
      _industriesError = '';
    });
    
    try {
      final industries = await SignupService.instance.getIndustries();
      setState(() {
        _industries = industries;
        _industriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _industriesError = 'Failed to load industries';
        _industriesLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIndustry == null) {
      _showSnackBar('Please select industry');
      return;
    }

    final String fullname = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    if (fullname.isEmpty) {
      _showSnackBar('Full name is required');
      return;
    }

    setState(() {
      _isSignupLoading = true;
      _signupError = '';
    });

    try {
      final response = await SignupService.instance.register(
        fullname: fullname,
        email: _emailController.text.trim(),
        phone: _numberController.text.trim(),
        countryCode: 91,
        password: _passwordController.text,
        industryId: int.tryParse(_selectedIndustry!) ?? 0,
      );

      if (!mounted) return;

      if (response['error'] != null) {
        setState(() => _signupError = response['error'].toString());
        _showSnackBar(_signupError);
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const VerifyOtpPage(),
        ),
      );
    } catch (e) {
      setState(() => _signupError = 'Signup failed');
      _showSnackBar(_signupError);
    } finally {
      if (mounted) setState(() => _isSignupLoading = false);
    }
  }

  // Social auth handled by SocialAuthButtons component

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
                                      (industry) => DropdownMenuItem<String>(
                                        value: (industry['id'] ?? '').toString(),
                                        child: Text((industry['name'] ?? '').toString()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _industriesLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedIndustry = value;
                                        });
                                      },
                                validator: (value) =>
                                    value == null ? 'Select industry' : null,
                              ),
                              if (_industriesLoading)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: LinearProgressIndicator(minHeight: 2),
                                ),
                              if (_industriesError.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _industriesError,
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
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
                                  onPressed: _isSignupLoading ? null : _signup,
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

                  const SocialAuthButtons(),

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
