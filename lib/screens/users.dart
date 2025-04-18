import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/users_screen_controller.dart';
import '../companents/custom_toast.dart';
import '../../responsive.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final controller = Get.put(UsersScreenController());
  bool _isAdminChecked = false;

  @override
  void initState() {
    super.initState();
    // Sahifa ochilganda admin tekshiruvi amalga oshiriladi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isAdminChecked) {
        controller.checkAdminStatus(context);
        _isAdminChecked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sticky header: Faqat sarlavha va orqaga tugmasi
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor,
                    secondaryColor.withAlpha(229), // 0.9 * 255 ≈ 229
                    secondaryColor.withAlpha(179), // 0.7 * 255 ≈ 179
                    Colors.black.withAlpha(153), // 0.6 * 255 ≈ 153
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.isMobile(context) ? 60 : 80,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Foydalanuvchilar",
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, baseSize: 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                          onPressed: () => context.pop(), // Navigator.pop o‘rniga GoRouter
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Qolgan kontent
          SliverToBoxAdapter(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Qidiruv maydoni
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ism yoki email bo‘yicha qidirish',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                      ),
                      filled: true,
                      fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getFontSize(context, baseSize: 14),
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ),
                // Saralash va qo‘shish tugmasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Saralash',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                            filled: true,
                            fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          ),
                          value: controller.sortOrder.value,
                          dropdownColor: Colors.black.withAlpha(229), // 0.9 * 255 ≈ 229
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Eng yangi')),
                            DropdownMenuItem(value: 'oldest', child: Text('Eng eski')),
                          ],
                          onChanged: controller.setSortOrder,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => _showAddUserDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Yangi foydalanuvchi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Foydalanuvchilar ro‘yxati
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FutureBuilder<List<dynamic>>(
                    future: controller.usersFuture.value,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Xato: ${snapshot.error}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                            ),
                          ),
                        );
                      }
                      final users = snapshot.data ?? [];
                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            "Foydalanuvchilar mavjud emas",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isBlocked = user['is_blocked'] as bool? ?? false;
                          final userId = user['id'] as String?;
                          final fullName = user['full_name'] as String? ?? 'Noma’lum';
                          final email = user['email'] as String? ?? 'Noma’lum';
                          final role = user['role'] as String? ?? 'Noma’lum';
                          final createdAt = user['created_at'] as String?;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(128), // 0.5 * 255 ≈ 128
                                  (role == 'admin'
                                      ? Colors.blueAccent
                                      : role == 'seller'
                                      ? Colors.greenAccent
                                      : role == 'manager'
                                      ? Colors.orangeAccent
                                      : Colors.grey)
                                      .withAlpha(26), // 0.1 * 255 ≈ 26
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: (role == 'admin'
                                      ? Colors.blueAccent
                                      : role == 'seller'
                                      ? Colors.greenAccent
                                      : role == 'manager'
                                      ? Colors.orangeAccent
                                      : Colors.grey)
                                      .withAlpha(77)), // 0.3 * 255 ≈ 77
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51), // 0.2 * 255 ≈ 51
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  color: role == 'admin'
                                      ? Colors.blueAccent
                                      : role == 'seller'
                                      ? Colors.greenAccent
                                      : role == 'manager'
                                      ? Colors.orangeAccent
                                      : Colors.grey,
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            fullName,
                                            style: TextStyle(
                                              color: role == 'admin'
                                                  ? Colors.blueAccent
                                                  : role == 'seller'
                                                  ? Colors.greenAccent
                                                  : role == 'manager'
                                                  ? Colors.orangeAccent
                                                  : Colors.white,
                                              fontSize: Responsive.getFontSize(
                                                  context, baseSize: 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            role,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: Responsive.getFontSize(
                                                  context, baseSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(
                                              context, baseSize: 12),
                                        ),
                                      ),
                                      Text(
                                        createdAt != null
                                            ? DateFormat('yyyy-MM-dd HH:mm')
                                            .format(DateTime.parse(createdAt))
                                            : 'Noma’lum vaqt',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(
                                              context, baseSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: controller.isLoading.value
                                                ? null
                                                : () => controller.toggleUserBlock(
                                                userId, !isBlocked, context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isBlocked
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(8)),
                                            ),
                                            child: Text(
                                              isBlocked ? 'Blokdan ochish' : 'Bloklash',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Responsive.getFontSize(
                                                    context, baseSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, UsersScreenController controller) {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'seller'; // Default rol sifatida seller

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          'Yangi foydalanuvchi qo‘shish',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Ism',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Parol',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Rol',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77), // 0.3 * 255 ≈ 77
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: role,
                dropdownColor: Colors.black.withAlpha(229), // 0.9 * 255 ≈ 229
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'seller', child: Text('Sotuvchi')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'manager', child: Text('Menejer')),
                ],
                onChanged: (value) {
                  if (value != null) role = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
              if (fullNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                CustomToast.show(
                  title: 'Xatolik',
                  context: context,
                  message: "Ma'lumotlar to'liq emas",
                  type: CustomToast.error,
                );
                return;
              }
              await controller.addUser(
                fullName: fullNameController.text,
                email: emailController.text,
                password: passwordController.text,
                role: role,
                context: context,
              );
              context.pop(); // Navigator.pop o‘rniga GoRouter
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Qo‘shish',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}