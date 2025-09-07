import 'package:flutter/material.dart';
import 'package:mfolks_app/pages/login.dart';
import 'package:mfolks_app/pages/comp-info.dart';
import 'package:mfolks_app/pages/homepage.dart';
import 'package:mfolks_app/pages/settings.dart';

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
      ),
      initialRoute: 'login',
      routes: {
        'login': (context) => const loginScreen(),
        '/login': (context) => const loginScreen(),
        '/companyInfo': (context) => const CompanyInfoPage(),
        '/home': (context) => const HomePage(),
        '/about': (context) => const Scaffold(body: Center(child: Text("About Us Page"))),
        '/analytics': (context) => const Scaffold(body: Center(child: Text("Analytics Page"))),
        '/calculator': (context) => const Scaffold(body: Center(child: Text("Calculator Page"))),
        '/quote': (context) => const Scaffold(body: Center(child: Text("Quote Page"))),
        '/shipping': (context) => const Scaffold(body: Center(child: Text("Shipping Details Page"))),
        '/orders': (context) => const Scaffold(body: Center(child: Text("Order History Page"))),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
