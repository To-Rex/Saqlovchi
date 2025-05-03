import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Image.asset("assets/images/logo.png"),
                const Text(
                  'Saqlovchi',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          DrawerListTile(
            title: "Uy",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => GoRouter.of(context).go('/home'),
          ),
          DrawerListTile(
            title: "O‘tkazmalar",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () => GoRouter.of(context).go('/transfers'),
          ),
          DrawerListTile(
            title: "Vazifalar",
            svgSrc: "assets/icons/menu_task.svg",
            press: () => GoRouter.of(context).go('/tasks'),
          ),
          DrawerListTile(
            title: "Mijozlar",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () => GoRouter.of(context).go('/documents'),
          ),
          DrawerListTile(
            title: "Sotuvlar",
            svgSrc: "assets/icons/menu_store.svg",
            press: () => GoRouter.of(context).go('/sales'),
          ),
          DrawerListTile(
            title: "Bildirishnomalar",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () => GoRouter.of(context).go('/notifications'),
          ),
          DrawerListTile(
            title: "Foydalanuvchilar",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () => GoRouter.of(context).go('/users'),
          ),
          DrawerListTile(
            title: "Sozlamalar",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () => GoRouter.of(context).go('/settings'),
          ),
          DrawerListTile(
            title: "Chiqish",
            color: Colors.red,
            icon: Icons.logout,
            press: () async {
              await Supabase.instance.client.auth.signOut();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    this.svgSrc,
    required this.press,
    this.color,
    this.icon,
  });

  final String? title, svgSrc;
  final Color? color;
  final VoidCallback press;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: svgSrc == null
          ? Icon(icon, color: color ?? Colors.white54)
          : SvgPicture.asset(
        svgSrc!,
        colorFilter: ColorFilter.mode(color ?? Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        ' $title',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color ?? Colors.white54),
      ),
    );
  }
}