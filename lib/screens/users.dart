import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/users_screen_controller.dart';
import '../../responsive.dart';
import '../companents/custom_toast.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersScreenController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
        // Sticky header: Qidiruv va qo‘shish tugmasi
        SliverAppBar(
        pinned: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor,
                secondaryColor.withOpacity(0.9),
                secondaryColor.withOpacity(0.7),
                Colors.black.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Responsive.isMobile(context) ? 300 : 550,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sarlavha va orqaga tugmasi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Foydalanuvchilar",
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, baseSize: 20),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                  // Qidiruv maydoni
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ism yoki email bo‘yicha qidirish',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: Responsive.getFontSize(context, baseSize: 14),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
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
                ],
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
            // Filtr va qo‘shish tugmasi
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
                        fillColor: Colors.black.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      value: controller.sortOrder.value,
                      dropdownColor: Colors.black.withOpacity(0.9),
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
                              Colors.black.withOpacity(0.5),
                              (role == 'admin' ? Colors.blueAccent : Colors.grey)
                                  .withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: (role == 'admin'
                                  ? Colors.blueAccent
                                  : Colors.grey)
                                  .withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                              color:
                              role == 'admin' ? Colors.blueAccent : Colors.grey,
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
                                            : () =>
                                            controller.toggleUserBlock(
                                                userId, !isBlocked),
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
    String role = 'user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
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
                  fillColor: Colors.black.withOpacity(0.3),
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
                  fillColor: Colors.black.withOpacity(0.3),
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
                  fillColor: Colors.black.withOpacity(0.3),
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
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: role,
                dropdownColor: Colors.black.withOpacity(0.9),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Foydalanuvchi')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
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
            onPressed: () => Get.back(),
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
                  type: CustomToast.error
                );
                return;
              }
              await controller.addUser(
                fullName: fullNameController.text,
                email: emailController.text,
                password: passwordController.text,
                role: role,
              );
              Get.back();
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