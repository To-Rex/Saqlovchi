import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/companents/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class CustomersScreenController extends GetxController {
  final ApiService apiService = ApiService();
  final SupabaseClient supabase = Supabase.instance.client;

  var customersFuture = Rxn<Future<List<dynamic>>>();
  var searchQuery = ''.obs;
  var sortOrder = 'newest'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    updateCustomers();
  }

  void updateCustomers() {
    customersFuture.value = apiService.getAllCustomers(
      searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      sortOrder: sortOrder.value,
    );
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    updateCustomers();
  }

  void setSortOrder(String? order) {
    if (order != null && ['newest', 'oldest'].contains(order)) {
      sortOrder.value = order;
      updateCustomers();
    }
  }

  Future<void> addCustomer({
    required String fullName,
    String? phoneNumber,
    String? address,
    required String createdBy,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      await apiService.addCustomer(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        createdBy: createdBy,
      );

      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Mijoz muvaffaqiyatli qo‘shildi',
        type: CustomToast.success,
      );
      updateCustomers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Mijoz qo‘shishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer({
    required int customerId,
    required String fullName,
    String? phoneNumber,
    String? address,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      await apiService.updateCustomer(
        id: customerId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
      );

      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Mijoz ma‘lumotlari muvaffaqiyatli yangilandi',
        type: CustomToast.success,
      );
      updateCustomers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Mijoz ma‘lumotlarini yangilashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(int? customerId, BuildContext context) async {
    if (customerId == null) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Mijoz ID topilmadi',
        type: CustomToast.error,
      );
      return;
    }
    try {
      isLoading.value = true;
      await apiService.deleteCustomer(customerId);

      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Mijoz muvaffaqiyatli o‘chirildi',
        type: CustomToast.success,
      );
      updateCustomers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Mijoz o‘chirishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> getDebtSales(int customerId) async {
    try {
      final debtSales = await apiService.getCustomerDebtSales(customerId);
      print('Olingan tranzaksiyalar (Mijoz ID: $customerId): ${debtSales.length} ta');
      return debtSales;
    } catch (e) {
      print('Qarzga sotilgan mahsulotlarni olishda xato: $e');
      return [];
    }
  }

  Future<void> payDebt({
    required int customerId,
    required double paymentAmount,
    required List<int> selectedTransactionIds,
    required String createdBy,
    required BuildContext context,
  }) async {
    if (paymentAmount <= 0) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'To‘lov miqdori musbat bo‘lishi kerak',
        type: CustomToast.error,
      );
      return;
    }
    if (selectedTransactionIds.isEmpty) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Kamida bitta tranzaksiya tanlang',
        type: CustomToast.error,
      );
      return;
    }
    isLoading.value = true;
    try {
      double remainingPayment = paymentAmount;
      for (var transactionId in selectedTransactionIds) {
        if (remainingPayment <= 0) break;

        final transaction = await supabase
            .from('transactions')
            .select('amount, sale_id')
            .eq('id', transactionId)
            .eq('transaction_type', 'debt_sale')
            .single();

        final debtAmount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
        final saleId = transaction['sale_id'] as int?;
        final paymentForTransaction = remainingPayment >= debtAmount ? debtAmount : remainingPayment;

        print('To‘lov qo‘shilmoqda: Tranzaksiya ID: $transactionId, Sale ID: $saleId, Miqdor: $paymentForTransaction');

        await apiService.addTransaction(
          transactionType: 'debt_payment',
          amount: paymentForTransaction,
          customerId: customerId,
          saleId: saleId,
          comments: 'Qarz to‘lovi (Tranzaksiya ID: $transactionId)',
          createdBy: createdBy,
        );

        if (saleId != null) {
          await apiService.updateSalePaidAmount(saleId, paymentForTransaction);
        }

        remainingPayment -= paymentForTransaction;
      }

      CustomToast.show(
        title: 'Muvaffaqiyat',
        context: context,
        message: 'Qarz to‘lovi muvaffaqiyatli amalga oshirildi',
        type: CustomToast.success,
      );
      updateCustomers();
    } catch (e) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Qarz to‘lashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}