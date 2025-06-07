import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sklad/controllers/get_controller.dart';
import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../responsive.dart';

/// Dashboard sarlavhasi
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: Responsive.getFontSize(context, baseSize: 24),
            ),
            onPressed: context.read<MenuAppController>().controlMenu,
            padding: EdgeInsets.all(defaultPadding / 2),
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Dashboard",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: Responsive.getFontSize(context, baseSize: 20),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard(),
      ],
    );
  }
}

/// Foydalanuvchi profil kartasi
class ProfileCard extends StatelessWidget {
  ProfileCard({super.key});
  final GetController controller = Get.put(GetController());

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(left: Responsive.isMobile(context) ? defaultPadding / 2 : defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding / 3,
      ),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Colors.white70,
            size: Responsive.getFontSize(context, baseSize: 18),
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding / 4),
              child: Obx(
                    () => Text(
                  controller.fullName.value,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 13),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
            size: Responsive.getFontSize(context, baseSize: 16),
          ),
        ],
      ),
    );
  }
}


class SearchField extends StatelessWidget {
  SearchField({super.key});
  final GetController controller = Get.put(GetController());

  void _handleSearch() {
    print('Qidirish tugmasi bosildi: ${controller.search.value}');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(maxHeight: Responsive.isMobile(context) ? 30 : 36),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3, offset: const Offset(0, 1))]
            ),
            child: TextField(
              onChanged: (value) {
                controller.search.value = value.trim();
                print('SearchField: Yangi qidirish qiymati: ${controller.search.value}');
              },
              onSubmitted: (value) => _handleSearch(), // Enter tugmasi bosilganda
              style: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 12)),
              decoration: InputDecoration(
                hintText: "Nomi yoki kodi bo‘yicha qidiring",
                hintStyle: TextStyle(color: Colors.white54, fontSize: Responsive.getFontSize(context, baseSize: 11)),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade300, width: 1), borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? defaultPadding / 2 : defaultPadding / 1.5, vertical: defaultPadding / 3)
              )
            )
          )
        ),
        SizedBox(width: defaultPadding / 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(maxHeight: Responsive.isMobile(context) ? 30 : 32, minWidth: Responsive.isMobile(context) ? 30 : 32),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: _handleSearch,
            borderRadius: BorderRadius.circular(16),
            child: Center(child: Icon(Icons.search, color: Colors.white, size: Responsive.getFontSize(context, baseSize: 23)))
          )
        )
      ]
    );
  }
}