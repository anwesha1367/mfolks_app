import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key, required this.isHome});

  final bool isHome; // true = show hamburger; false = show back

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF00695C);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: isHome
          ? Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu, color: primary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : IconButton(
              tooltip: 'Back',
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: primary,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          'assets/mfolks-logo-1.png',
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded, color: primary),
          onPressed: () => Navigator.pushNamed(context, '/notification'),
        ),
        IconButton(
          tooltip: 'Cart',
          icon: const Icon(Icons.shopping_cart_outlined, color: primary),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.person_outline_rounded, color: primary),
            onPressed: () => Navigator.pushNamed(context, '/editProfile'),
          ),
        ),
      ],
    );
  }
}
