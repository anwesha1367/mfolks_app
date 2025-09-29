import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfolks_app/pages/login.dart';
import 'package:mfolks_app/pages/comp-info.dart';
import 'package:mfolks_app/pages/homepage.dart';
import 'package:mfolks_app/pages/product_details_page.dart';
import 'package:mfolks_app/pages/cart_page.dart';
import 'package:mfolks_app/pages/settings.dart';
import 'package:mfolks_app/pages/feedback.dart';
import 'package:mfolks_app/pages/EditDetailPage.dart';
import 'package:mfolks_app/pages/reset_password_page.dart';
import 'package:mfolks_app/pages/language_page.dart';
import 'package:mfolks_app/pages/shippingAddressPage.dart';
import 'package:mfolks_app/pages/metalCalculatorPage.dart';
import 'package:mfolks_app/pages/notificationPage.dart';
import 'package:mfolks_app/pages/contact_us_page.dart';
import 'package:mfolks_app/pages/signup.dart';
import 'package:mfolks_app/pages/verify_otp_page.dart';
import 'package:mfolks_app/pages/orders_page.dart';
import 'package:mfolks_app/pages/analytics.dart';
import 'package:mfolks_app/pages/search_page.dart';
import 'package:mfolks_app/pages/about_us_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: NoAnimationsPageTransitionsBuilder(),
          TargetPlatform.iOS: NoAnimationsPageTransitionsBuilder(),
          TargetPlatform.windows: NoAnimationsPageTransitionsBuilder(),
          TargetPlatform.linux: NoAnimationsPageTransitionsBuilder(),
          TargetPlatform.macOS: NoAnimationsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: NoAnimationsPageTransitionsBuilder(),
        }),
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
      home: const _RootRouter(),
      routes: {
        'login': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/companyInfo': (context) => const CompanyInfoPage(),
        '/home': (context) => const HomePage(),
        '/product': (context) => const ProductDetailsPage(),
        '/cart': (context) => const CartPage(),
        '/search': (context) => const SearchPage(),
        '/about': (context) => const AboutUsPage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/calculator': (context) => const MetalCalculatorPage(),
        '/quote': (context) => const FeedbackPage(),
        '/shipping': (context) => const ShippingAddressPage(),
        '/orders': (context) => const OrdersPage(),
        '/settings': (context) => const SettingsPage(),
        '/editProfile': (context) => const EditDetailsPage(),
        '/test': (context) =>
            const Scaffold(body: Center(child: Text('Test Page'))),
        '/resetPassword': (context) => const ResetPasswordPage(),
        '/language': (context) => const LanguagePage(),
        '/feedback': (context) => const FeedbackPage(),
        '/notification': (context) => const NotificationsPage(),
        '/contact': (context) => const ContactUsPage(),
        '/signup': (context) => const SignupPage(),
        '/verify-otp': (context) => const VerifyOtpPage(),
      },
    );
  }
}

class NoAnimationsPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationsPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // no animation
  }
}

class _RootRouter extends StatefulWidget {
  const _RootRouter();
  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  Future<bool>? _hasTokenFuture;

  @override
  void initState() {
    super.initState();
    _hasTokenFuture = _checkToken();
  }

  Future<bool> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasTokenFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasToken = snapshot.data == true;
        return hasToken ? const HomePage() : const LoginScreen();
      },
    );
  }
}
