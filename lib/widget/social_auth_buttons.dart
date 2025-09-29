// ignore_for_file: uri_does_not_exist, undefined_function, undefined_identifier
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../config/env.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  Future<void> _launchSocial(String provider) async {
    final url = '${EnvConfig.apiBaseUrl.replaceFirst('/api', '')}/auth/social/$provider';
    final uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => _launchSocial('google'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Image.asset('assets/google_logo.png', height: 20, width: 20),
                const SizedBox(width: 8),
                const Text('Continue with Google'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _launchSocial('apple'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Image.asset('assets/apple_logo.png', height: 20, width: 20),
                const SizedBox(width: 8),
                const Text('Continue with Apple'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


