import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_service.dart'; // API chaqiruv joyi, sizga mos ravishda sozlang

class ExpensesController extends GetxController {
  final expenseNameController = TextEditingController();
  final amountController = TextEditingController();

  final isSubmitting = false.obs;
  final buttonScale = 1.0.obs;

  final expenseList = <ExpenseItem>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }
  Future<void> fetchExpenses() async {
    try {
      await ApiService().fetchExpenses();
      await ApiService().fetchExpensesWithUserStats();
    } catch (e) {
      print("Xarajatlarni olishda xatolik: $e");
      Get.snackbar(
        'Xatolik',
        'Xarajatlar ro‘yxatini olishda muammo yuz berdi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  void setButtonScale(double scale) {
    buttonScale.value = scale;
  }
  void changeExpenseList(List<dynamic> response) {
    expenseList.value = response.map((e) => ExpenseItem(
      id: e['id'],
      title: e['title'] ?? '',
      amount: (e['amount'] is int) ? (e['amount'] as int).toDouble() : e['amount'],
      createdBy: e['created_by'] ?? '',
      createdAt: e['created_at'] ?? '',
    )).toList();

    print("✅ expenseList length: ${expenseList.length}");
  }


  /// Xarajatni yuborish funksiyasi
  Future<void> submitExpense() async {
    final name = expenseNameController.text.trim();
    final amountText = amountController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, xarajat nomi va summasini kiriting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Xatolik',
        'Miqdor noto‘g‘ri formatda yoki 0 dan kichik.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isSubmitting.value = true;

      // API chaqiruv
      await ApiService().submitExpense(name, amountText);

      // Maydonlarni tozalash
      expenseNameController.clear();
      amountController.clear();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotni yuborishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    expenseNameController.dispose();
    amountController.dispose();
    super.onClose();
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String createdBy;
  final String createdAt;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdBy,
    required this.createdAt,
  });

  List toMap() {
    return [id, title, amount, createdBy, createdAt];
  }

  factory ExpenseItem.fromMap(List map) {
    return ExpenseItem(
      id: map[0],
      title: map[1],
      amount: map[2],
      createdBy: map[3],
      createdAt: map[4],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}

