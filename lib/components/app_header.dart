import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_notifier.dart';
import '../models/user.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(userProvider);
    final String displayName = (user?.fullname?.trim().isNotEmpty == true)
        ? user!.fullname!.trim()
        : 'MFolks Partner';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset("assets/mfolks-logo.png", height: 32),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF00695C),
            ),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  color: Color(0xFF00695C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE0F2F1),
                backgroundImage: (user?.profilePictureUrl != null && (user!.profilePictureUrl!.isNotEmpty))
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: (user?.profilePictureUrl == null || (user!.profilePictureUrl!.isEmpty))
                    ? const Icon(Icons.person_outline, color: Color(0xFF00695C))
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



