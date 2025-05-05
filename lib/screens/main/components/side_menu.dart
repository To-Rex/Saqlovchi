import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/get_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // GetController dan foydalanuvchi rolini olish
    final GetController controller = Get.find<GetController>();

    // Log qo‘shish: foydalanuvchi roli
    print('SideMenu ochildi: role=${controller.role.value}');

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Obx(() {
        // Foydalanuvchi roliga qarab menyuni shakllantirish
        final String role = controller.role.value;
        print('SideMenu ochildi: role=$role');
        final bool isSeller = role == 'seller' ? true : false;

        // Agar role bo‘sh bo‘lsa, xato ko‘rsatish yoki kirish sahifasiga yo‘naltirish
        if (role.isEmpty) {
          print('Xato: Foydalanuvchi roli aniqlanmadi, /login ga yo‘naltirilmoqda');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).replace('/login');
          });
          return const Center(
            child: Text(
              'Foydalanuvchi roli aniqlanmadi',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        // Menyu elementlari ro‘yxati
        final List<Widget> menuItems = [
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
        ];

        // Seller uchun faqat Sotuvlar va Mijozlar
        if (isSeller) {
          menuItems.addAll([
            DrawerListTile(
              title: "Mijozlar",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                print('Navigatsiya: /documents ga replace');
                GoRouter.of(context).replace('/documents');
              },
            ),
            DrawerListTile(
              title: "Sotuvlar",
              svgSrc: "assets/icons/menu_store.svg",
              press: () {
                print('Navigatsiya: /sales ga replace');
                GoRouter.of(context).replace('/sales');
              },
            ),
          ]);
        } else {
          // Boshqa rollar (admin, manager) uchun barcha menyular
          menuItems.addAll([
            DrawerListTile(
              title: "Uy",
              svgSrc: "assets/icons/menu_dashboard.svg",
              press: () {
                print('Navigatsiya: /home ga replace');
                GoRouter.of(context).replace('/home');
              },
            ),
            DrawerListTile(
              title: "O‘tkazmalar",
              svgSrc: "assets/icons/menu_tran.svg",
              press: () {
                print('Navigatsiya: /transfers ga replace');
                GoRouter.of(context).replace('/transfers');
              },
            ),
            DrawerListTile(
              title: "Vazifalar",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                print('Navigatsiya: /tasks ga replace');
                GoRouter.of(context).replace('/tasks');
              },
            ),
            DrawerListTile(
              title: "Mijozlar",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                print('Navigatsiya: /documents ga replace');
                GoRouter.of(context).replace('/documents');
              },
            ),
            DrawerListTile(
              title: "Sotuvlar",
              svgSrc: "assets/icons/menu_store.svg",
              press: () {
                print('Navigatsiya: /sales ga replace');
                GoRouter.of(context).replace('/sales');
              },
            ),
            DrawerListTile(
              title: "Foydalanuvchilar",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                print('Navigatsiya: /users ga replace');
                GoRouter.of(context).replace('/users');
              },
            ),
            DrawerListTile(
              title: "Sozlamalar",
              svgSrc: "assets/icons/menu_setting.svg",
              press: () {
                print('Navigatsiya: /settings ga replace');
                GoRouter.of(context).replace('/settings');
              },
            ),
          ]);
        }

        // Chiqish har qanday rol uchun doim ko‘rinadi
        menuItems.add(
          DrawerListTile(
            title: "Chiqish",
            color: Colors.red,
            icon: Icons.logout,
            press: () async {
              print('Chiqish: /login ga replace');
              await Supabase.instance.client.auth.signOut();
              GoRouter.of(context).replace('/login');
            },
          ),
        );

        // Log qo‘shish: ko‘rsatilgan menyular
        print('Ko‘rsatilgan menyular: ${menuItems.whereType<DrawerListTile>().map((item) => item.title).toList()}');

        return ListView(
          children: menuItems,
        );
      }),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({super.key, required this.title, this.svgSrc, required this.press, this.color, this.icon});

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