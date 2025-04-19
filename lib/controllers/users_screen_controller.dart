import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:sklad/companents/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersScreenController extends GetxController {
  final ApiService apiService = ApiService();
  final SupabaseClient supabase = Supabase.instance.client;

  var usersFuture = Rxn<Future<List<dynamic>>>();
  var searchQuery = ''.obs;
  var sortOrder = 'newest'.obs;
  var isAdmin = false.obs;
  var isLoading = false.obs;

  // Admin hisob ma‘lumotlari (xavfsiz saqlash uchun o‘zgartirish kerak)
  String? _adminEmail;
  String? _adminPassword;

  @override
  void onInit() {
    super.onInit();
  }

  // Admin hisob ma‘lumotlarini o‘rnatish
  void setAdminCredentials(String email, String password) {
    _adminEmail = email;
    _adminPassword = password;
  }

  void checkAdminStatus(BuildContext context) async {
    isLoading.value = true;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Foydalanuvchi tizimga kirmagan',
        type: CustomToast.error,
      );
      context.go('/login');
      isLoading.value = false;
      return;
    }

    try {
      isAdmin.value = await apiService.isAdmin(userId);
      if (isAdmin.value) {
        _updateUsers();
      } else {
        CustomToast.show(
          title: 'Xatolik',
          context: context,
          message: 'Faqat adminlar bu sahifaga kirishi mumkin',
          type: CustomToast.error,
        );
        context.go('/login');
      }
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Admin tekshiruvida xato: $e',
        type: CustomToast.error,
      );
      context.go('/login');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUsers() {
    usersFuture.value = apiService.getAllUsers(
      searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      sortOrder: sortOrder.value,
    );
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _updateUsers();
  }

  void setSortOrder(String? order) {
    if (order != null) {
      sortOrder.value = order;
      _updateUsers();
    }
  }

  Future<void> _handleSignUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      // Yangi foydalanuvchi qo‘shish
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        // Admin hisobiga qayta kirish
        if (_adminEmail != null && _adminPassword != null) {
          await supabase.auth.signOut();
          final adminResponse = await supabase.auth.signInWithPassword(
            email: _adminEmail!,
            password: _adminPassword!,
          );

          if (adminResponse.user == null) {
            CustomToast.show(
              title: 'Xatolik',
              context: context,
              message: 'Admin hisobiga qayta kirishda xato yuz berdi',
              type: CustomToast.error,
            );
            context.go('/login');
            return;
          }
        } else {
          CustomToast.show(
            title: 'Xatolik',
            context: context,
            message: 'Admin hisob ma‘lumotlari topilmadi, qayta kiring',
            type: CustomToast.error,
          );
          context.go('/login');
          return;
        }

        CustomToast.show(
          title: 'Muvaffaqiyat',
          context: context,
          message: 'Foydalanuvchi muvaffaqiyatli qo‘shildi',
          type: CustomToast.success,
        );
        _updateUsers();
      } else {
        CustomToast.show(
          title: 'Xatolik',
          context: context,
          message: 'Foydalanuvchi qo‘shishda noma‘lum xato yuz berdi',
          type: CustomToast.error,
        );
      }
    } on AuthException catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Ro‘yxatdan o‘tishda xatolik: ${e.message}',
        type: CustomToast.error,
      );
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Kutilmagan xatolik: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    await _handleSignUp(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      context: context,
    );
  }

  Future<void> deleteUser(String? userId, BuildContext context) async {
    if (userId == null) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Foydalanuvchi ID topilmadi',
        type: CustomToast.error,
      );
      return;
    }
    try {
      isLoading.value = true;
      // users jadvalidan foydalanuvchi ma‘lumotlarini o‘chirish
      await supabase.from('users').delete().eq('id', userId);
      // auth.users jadvalidan foydalanuvchi hisobini o‘chirish uchun admin API kerak
      // Hozircha faqat users jadvalidan o‘chiramiz, chunki service_role yo‘q
      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Foydalanuvchi muvaffaqiyatli o‘chirildi',
        type: CustomToast.success,
      );
      _updateUsers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Foydalanuvchi o‘chirishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser({
    required String userId,
    required String fullName,
    required String email,
    String? password, // Parol ixtiyoriy
    required String role,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      // users jadvalida ma‘lumotlarni yangilash
      final updateData = {
        'full_name': fullName,
        'email': email,
        'role': role,
      };
      await supabase.from('users').update(updateData).eq('id', userId);

      // Agar parol kiritilgan bo‘lsa, auth.users da yangilash
      if (password != null && password.isNotEmpty) {
        // Hozircha auth.users ni yangilash uchun admin API kerak
        // Shu sababli, faqat xabar qoldiramiz
        CustomToast.show(
          title: 'Ogohlantirish',
          context: context,
          message: 'Parol yangilash uchun admin API kerak. Faqat boshqa ma‘lumotlar yangilandi.',
          type: CustomToast.error,
        );
      }

      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Foydalanuvchi ma‘lumotlari muvaffaqiyatli yangilandi',
        type: CustomToast.success,
      );
      _updateUsers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Foydalanuvchi ma‘lumotlarini yangilashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserBlock(String? userId, bool isBlocked, BuildContext context) async {
    if (userId == null) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Foydalanuvchi ID topilmadi',
        type: CustomToast.error,
      );
      return;
    }
    try {
      isLoading.value = true;
      await apiService.toggleUserBlock(userId, isBlocked);
      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: isBlocked ? 'Foydalanuvchi bloklandi' : 'Foydalanuvchi blokdan ochildi',
        type: CustomToast.success,
      );
      _updateUsers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Blok holatini o‘zgartirishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}