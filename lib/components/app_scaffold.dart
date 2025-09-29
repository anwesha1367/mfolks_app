import 'package:flutter/material.dart';
import '../widget/custom_footer.dart';
import 'app_header.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool isHomeHeader;
  final int currentIndex;
  final Widget? drawer;

  const AppScaffold({
    super.key,
    required this.body,
    this.isHomeHeader = false,
    required this.currentIndex,
    this.drawer,
  });

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return; // avoid reloading same tab
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/quote');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/calculator');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      drawer: drawer,
      appBar: AppHeader(isHome: isHomeHeader),
      body: body,
      bottomNavigationBar: CustomFooter(
        currentIndex: currentIndex,
        onTap: (i) => _handleTap(context, i),
      ),
    );
  }
}


