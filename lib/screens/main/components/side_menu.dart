import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
      child: ListView(
        children: [
          DrawerHeader(
            //child: Image.asset("assets/images/logo.png"),
            child: Row(
              children: [
                Image.asset("assets/images/logo.png"),
                Text(
                  'Saqlovchi',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            )
          ),
          DrawerListTile(
            title: "Uy",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "O‘tkazmalar",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Vazifalar",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Hujjatlar",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Sotuvlar",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Bildirishnomalar",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Foydalanuvchilar",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Sozlamalar",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Chiqish",
            color: Colors.red,
            svgSrc: "assets/icons/menu_setting.svg",
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
  const DrawerListTile({super.key, required this.title, required this.svgSrc, required this.press, this.color});

  final String title, svgSrc;
  final Color? color;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(svgSrc, colorFilter: ColorFilter.mode(color ?? Colors.white54, BlendMode.srcIn), height: 16),
      title: Text(' $title', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color ?? Colors.white54))
    );
  }
}
