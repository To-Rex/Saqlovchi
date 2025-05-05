import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/get_controller.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    // GoRouter routerDelegate yo‘nalish o‘zgarishini kuzatish
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    // Listener ni o‘chirish
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  // Yo‘nalish o‘zgarganda setState chaqirish
  void _onRouteChanged() {
    setState(() {
      print('Yo‘nalish o‘zgardi: ${GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString()}');
    });
  }

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
        final bool isSeller = role == 'seller';

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
              route: '/documents',
              press: () {
                print('Navigatsiya: /documents ga replace');
                GoRouter.of(context).replace('/documents');
              },
            ),
            DrawerListTile(
              title: "Sotuvlar",
              svgSrc: "assets/icons/menu_store.svg",
              route: '/sales',
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
              route: '/home',
              press: () {
                print('Navigatsiya: /home ga replace');
                GoRouter.of(context).replace('/home');
              },
            ),
            DrawerListTile(
              title: "O‘tkazmalar",
              svgSrc: "assets/icons/menu_tran.svg",
              route: '/transfers',
              press: () {
                print('Navigatsiya: /transfers ga replace');
                GoRouter.of(context).replace('/transfers');
              },
            ),
            DrawerListTile(
              title: "Mijozlar",
              svgSrc: "assets/icons/menu_doc.svg",
              route: '/documents',
              press: () {
                print('Navigatsiya: /documents ga replace');
                GoRouter.of(context).replace('/documents');
              },
            ),
            DrawerListTile(
              title: "Sotuvlar",
              svgSrc: "assets/icons/menu_store.svg",
              route: '/sales',
              press: () {
                print('Navigatsiya: /sales ga replace');
                GoRouter.of(context).replace('/sales');
              },
            ),
            DrawerListTile(
              title: "Foydalanuvchilar",
              svgSrc: "assets/icons/menu_profile.svg",
              route: '/users',
              press: () {
                print('Navigatsiya: /users ga replace');
                GoRouter.of(context).replace('/users');
              },
            ),
            DrawerListTile(
              title: "Sozlamalar",
              svgSrc: "assets/icons/menu_setting.svg",
              route: '/settings',
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
            route: '/login',
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
  const DrawerListTile({
    super.key,
    required this.title,
    this.svgSrc,
    required this.press,
    this.color,
    this.icon,
    required this.route,
  });

  final String? title, svgSrc;
  final Color? color;
  final VoidCallback press;
  final IconData? icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    // Joriy yo‘nalishni aniqlash
    final bool isSelected = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() == route;

    // Log qo‘shish: faol holatni tekshirish
    print('DrawerListTile: title=$title, route=$route, isSelected=$isSelected');

    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      selected: isSelected, // Faol holatni belgilash
      selectedTileColor: Colors.white.withOpacity(0.1), // Faol fon rangi
      leading: svgSrc == null
          ? Icon(
        icon,
        color: isSelected ? Colors.white : color ?? Colors.white54,
      )
          : SvgPicture.asset(
        svgSrc!,
        colorFilter: ColorFilter.mode(
          isSelected ? Colors.white : color ?? Colors.white54,
          BlendMode.srcIn,
        ),
        height: 16,
      ),
      title: Text(
        ' $title',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSelected ? Colors.white : color ?? Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}