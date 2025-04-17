import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersScreenController extends GetxController {
  final ApiService apiService = ApiService();
  final SupabaseClient supabase = Supabase.instance.client;

  var usersFuture = Rxn<Future<List<dynamic>>>();
  var searchQuery = ''.obs;
  var sortOrder = 'newest'.obs;
  var isAdmin = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
    isLoading.value = true;
    // Joriy foydalanuvchi ID sini Supabase Auth’dan olish
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('Foydalanuvchi tizimga kirmagan');
      Get.back();
      isLoading.value = false;
      return;
    }

    try {
      isAdmin.value = await apiService.isAdmin(userId);
      if (isAdmin.value) {
        _updateUsers();
      } else {
        print('Faqat adminlar bu sahifaga kirishi mumkin');
        Get.back();
      }
    } catch (e) {
      print('Adminligini tekshirishda xato: $e');
      Get.back();
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

  Future<void> addUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      await apiService.addUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      print('Foydalanuvchi muvaffaqiyatli qo‘shildi: $email');
      _updateUsers();
    } catch (e) {
      print('Foydalanuvchi qo‘shishda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserBlock(String? userId, bool isBlocked) async {
    if (userId == null) {
      print('Foydalanuvchi ID topilmadi');
      return;
    }
    try {
      isLoading.value = true;
      await apiService.toggleUserBlock(userId, isBlocked);
      print('Foydalanuvchi blok holati o‘zgartirildi: $userId, is_blocked: $isBlocked');
      _updateUsers();
    } catch (e) {
      print('Foydalanuvchi blok holatini o‘zgartirishda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }
}