import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import '../companents/custom_toast.dart';

class TestScreenController extends GetxController {
  ApiService apiService = ApiService();
  var isLoading = false.obs;

  Future<void> clearAllData(BuildContext context) async {
    isLoading.value = true;
    try {
      await apiService.clearAllDataExceptUsersAndUnits();
      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'Ma\'lumotlar (users va units’dan tashqari) tozalandi',
        type: CustomToast.success,
      );
    } catch (e) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Ma\'lumotlarni tozalashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}