import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_notifier.dart';
import '../models/user.dart';

class AppHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key, this.isHome = true});
  
  final bool isHome;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + (kToolbarHeight * 0.5));

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {


  Widget _buildCategoryButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryButton(
            title: 'Ferrous',
            icon: Icons.construction,
            onTap: () {
              Navigator.pushNamed(context, '/search', arguments: {'category': 'Ferrous'});
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCategoryButton(
            title: 'Non-Ferrous',
            icon: Icons.build,
            onTap: () {
              Navigator.pushNamed(context, '/search', arguments: {'category': 'Non-Ferrous'});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00695C), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF00695C),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF00695C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final AppUser? user = ref.watch(userProvider);
    final String displayName = (user?.fullname?.trim().isNotEmpty == true)
        ? user!.fullname!.trim()
        : 'MFolks Partner';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Top row with logo and actions
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            leadingWidth: 56,
            leading: widget.isHome
                ? Builder(
                    builder: (ctx) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu, color: Color(0xFF00695C)),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  )
                : IconButton(
                    tooltip: 'Back',
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF00695C),
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
          ),
          // Category buttons row (only for home page)
          if (widget.isHome)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildCategoryButtons(),
            ),
        ],
      ),
    );
  }
}



