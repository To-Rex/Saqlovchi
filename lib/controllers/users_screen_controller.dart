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

  // onInit da context ishlatishdan qochamiz
  @override
  void onInit() {
    super.onInit();
    // _checkAdminStatus faqat context mavjud bo‘lganda chaqiriladi
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
      context.go('/login'); // Navigator.pop o‘rniga GoRouter
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
        context.go('/login'); // Navigator.pop o‘rniga GoRouter
      }
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Admin tekshiruvida xato: $e',
        type: CustomToast.error,
      );
      context.go('/login'); // Navigator.pop o‘rniga GoRouter
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
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        CustomToast.show(
          title: 'Muvaffaqiyat',
          context: context,
          message: 'Foydalanuvchi muvaffaqiyatli qo‘shildi',
          type: CustomToast.success,
        );
        _updateUsers();
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