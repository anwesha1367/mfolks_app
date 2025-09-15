import 'package:flutter/material.dart';
import 'package:mfolks_app/pages/login.dart';
import 'package:mfolks_app/pages/comp-info.dart';
import 'package:mfolks_app/pages/homepage.dart';
import 'package:mfolks_app/pages/settings.dart';
import 'package:mfolks_app/pages/feedback.dart';
import 'package:mfolks_app/pages/EditDetailPage.dart';
import 'package:mfolks_app/pages/reset_password_page.dart';
import 'package:mfolks_app/pages/language_page.dart';
import'package:mfolks_app/pages/shippingAddressPage.dart';
import 'package:mfolks_app/pages/metalCalculatorPage.dart';
import 'package:mfolks_app/pages/notificationPage.dart';
import 'package:mfolks_app/pages/contact_us_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MFolks App",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF00695C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF00695C),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFF00695C).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.teal.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      initialRoute: 'login',
      routes: {
        'login': (context) => const loginScreen(),
        '/login': (context) => const loginScreen(),
        '/companyInfo': (context) => const CompanyInfoPage(),
        '/home': (context) => const HomePage(),
        '/about': (context) => const Scaffold(body: Center(child: Text("About Us Page"))),
        '/analytics': (context) => const Scaffold(body: Center(child: Text("Analytics Page"))),
        '/calculator': (context) => const MetalCalculatorPage(),
        '/quote': (context) => const FeedbackPage(),
        '/shipping': (context) => const ShippingAddressPage(),
        '/orders': (context) => const Scaffold(body: Center(child: Text("Order History Page"))),
        '/settings': (context) => const SettingsPage(),
        '/editProfile': (context) => const EditDetailsPage(),
        '/test': (context) => const Scaffold(body: Center(child: Text('Test Page')),
        ),
        '/resetPassword': (context) => const ResetPasswordPage(),
        '/language': (context) => const LanguagePage(),
        '/feedback': (context) => const FeedbackPage(),
        '/notification':(context)=>const NotificationsPage(),
        '/contact':(context)=>const ContactUsPage(),

      },
    );
  }
}
