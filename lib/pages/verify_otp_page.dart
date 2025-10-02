import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/signup_service.dart';
import 'package:flutter/widgets.dart';

class VerifyOtpPage extends StatefulWidget {
  final bool isSocialAuth;
  final String? userId;
  final String? provider;
  final String? providerUserId;

  const VerifyOtpPage({
    Key? key,
    this.isSocialAuth = false,
    this.userId,
    this.provider,
    this.providerUserId,
  }) : super(key: key);

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '91');

  bool _loading = false;
  bool _resendLoading = false;
  String _error = '';
  String _success = '';
  String _step = 'email'; // email | phone | done

  // Social auth params
  bool _isSocialAuth = false;
  String? _socialUserId;
  String? _socialProvider;
  String? _socialProviderUserId;

  int _emailTimer = 0;
  int _phoneTimer = 0;

  @override
  void initState() {
    super.initState();
    _readQueryParamsIfAny();
    _prefillFromStorage();
    _startTimersLoop();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _emailOtpController.dispose();
    _phoneOtpController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  void _readQueryParamsIfAny() {
    try {
      final uri = Uri.base;
      final userId = uri.queryParameters['user_id'];
      final provider = uri.queryParameters['provider'];
      final providerUserId = uri.queryParameters['provider_user_id'];
      setState(() {
        _isSocialAuth = (userId != null && provider != null) || widget.isSocialAuth;
        _socialUserId = userId ?? widget.userId;
        _socialProvider = provider ?? widget.provider;
        _socialProviderUserId = providerUserId ?? widget.providerUserId;
        _step = _isSocialAuth ? 'phone' : 'email';
      });
    } catch (_) {
      setState(() {
        _isSocialAuth = widget.isSocialAuth;
        _socialUserId = widget.userId;
        _socialProvider = widget.provider;
        _socialProviderUserId = widget.providerUserId;
        _step = _isSocialAuth ? 'phone' : 'email';
      });
    }
  }

  void _startTimersLoop() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_step == 'email' && _emailTimer > 0) _emailTimer -= 1;
        if (_step == 'phone' && _phoneTimer > 0) _phoneTimer -= 1;
      });
      return true;
    });
  }

  Future<void> _prefillFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationData = prefs.getString('verificationData');
      if (verificationData != null && verificationData.isNotEmpty) {
        // Very small parser since we stored a tiny JSON string
        final emailMatch = RegExp('"email":"(.*?)"').firstMatch(verificationData);
        final phoneMatch = RegExp('"phone":"(.*?)"').firstMatch(verificationData);
        final ccMatch = RegExp('"country_code":"(.*?)"').firstMatch(verificationData);
        if (emailMatch != null) _emailController.text = emailMatch.group(1) ?? '';
        if (phoneMatch != null) _phoneController.text = phoneMatch.group(1) ?? '';
        if (ccMatch != null) _countryCodeController.text = ccMatch.group(1) ?? '91';
      }
    } catch (_) {}
  }

  Future<void> _handleResendEmail() async {
    setState(() {
      _resendLoading = true;
      _error = '';
      _success = '';
    });
    try {
      await SignupService.instance.sendEmailOtp(_emailController.text.trim());
      setState(() {
        _success = 'OTP resent to your email';
        _emailTimer = 30;
      });
    } catch (e) {
      setState(() => _error = 'Failed to resend email OTP');
    } finally {
      setState(() => _resendLoading = false);
    }
  }

  Future<void> _handleResendPhone() async {
    setState(() {
      _resendLoading = true;
      _error = '';
      _success = '';
    });
    try {
      await SignupService.instance.sendPhoneOtp(
        phone: _phoneController.text.trim(),
        countryCode: int.tryParse(_countryCodeController.text.trim()) ?? 91,
        userId: _isSocialAuth ? _socialUserId : null,
      );
      setState(() {
        _success = 'OTP resent to your WhatsApp';
        _phoneTimer = 30;
      });
    } catch (e) {
      setState(() => _error = 'Failed to resend phone OTP');
    } finally {
      setState(() => _resendLoading = false);
    }
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _loading = true;
      _error = '';
      _success = '';
    });
    try {
      await SignupService.instance.verifyEmailOtp(
        email: _emailController.text.trim(),
        otp: _emailOtpController.text.trim(),
      );
      setState(() {
        _success = 'Email verified! Now verify your phone number.';
        _step = 'phone';
      });
    } catch (e) {
      setState(() => _error = 'Verification failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyPhone() async {
    setState(() {
      _loading = true;
      _error = '';
      _success = '';
    });
    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      if (_isSocialAuth) {
        await SignupService.instance.verifyPhoneOtp(
          phone: cleanPhone,
          otp: _phoneOtpController.text.trim(),
          countryCode: int.tryParse(_countryCodeController.text.trim()) ?? 91,
          userId: _socialUserId,
        );
        final response = await SignupService.instance.completeSocialAuthPhoneVerification(
          userId: _socialUserId ?? '',
          phone: cleanPhone,
          countryCode: int.tryParse(_countryCodeController.text.trim()) ?? 91,
          provider: _socialProvider ?? '',
          providerUserId: _socialProviderUserId ?? '',
        );
        if (response['success'] == true) {
          setState(() {
            _success = 'Phone verified! Account setup complete. Redirecting...';
            _step = 'done';
          });
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        await SignupService.instance.verifyPhoneOtp(
          phone: cleanPhone,
          otp: _phoneOtpController.text.trim(),
          countryCode: int.tryParse(_countryCodeController.text.trim()) ?? 91,
        );
        setState(() {
          _success = 'Phone verified! Registration complete. You can now log in.';
          _step = 'done';
        });
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      setState(() => _error = 'Verification failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/mfolks-logo-1.png', height: 64),
              const SizedBox(height: 16),
              Text(
                widget.isSocialAuth ? 'Complete Your Account Setup' : 'Verify Your Account',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_step == 'email') ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                  enabled: !_loading,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailOtpController,
                  decoration: const InputDecoration(hintText: 'Enter Email OTP'),
                  enabled: !_loading,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: (_resendLoading || _emailTimer > 0) ? null : _handleResendEmail,
                      child: Text(_emailTimer > 0 ? 'Resend OTP in ${_emailTimer}s' : 'Resend OTP'),
                    ),
                  ],
                ),
                if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
                if (_success.isNotEmpty) Text(_success, style: const TextStyle(color: Colors.green, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyEmail,
                    child: Text(_loading ? 'Verifying...' : 'Verify Email'),
                  ),
                ),
              ] else if (_step == 'phone') ...[
                if (widget.isSocialAuth) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Country Code', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _countryCodeController,
                    decoration: const InputDecoration(hintText: 'Country Code'),
                    enabled: !_loading,
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                  enabled: !_loading,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneOtpController,
                  decoration: const InputDecoration(hintText: 'Enter WhatsApp OTP'),
                  enabled: !_loading,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: (_resendLoading || _phoneTimer > 0) ? null : _handleResendPhone,
                      child: Text(_phoneTimer > 0 ? 'Resend OTP in ${_phoneTimer}s' : 'Resend OTP'),
                    ),
                  ],
                ),
                if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
                if (_success.isNotEmpty) Text(_success, style: const TextStyle(color: Colors.green, fontSize: 12)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyPhone,
                    child: Text(_loading ? 'Verifying...' : 'Verify Phone'),
                  ),
                ),
              ] else ...[
                const Text('Verification complete! Redirecting...'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


