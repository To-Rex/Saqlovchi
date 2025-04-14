import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:sklad/controllers/get_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../companents/custom_toast.dart';

class SalesScreenController extends GetxController {
  final ApiService apiService = ApiService();
  final GetController appController = Get.find<GetController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observables
  var selectedCategoryId = Rxn<String>();
  var selectedProductId = Rxn<String>();
  var selectedBatchId = Rxn<String>();
  var quantity = 0.0.obs;
  var unitPrice = 0.0.obs; // Ustama haq uchun
  var basePrice = 0.0.obs; // cost_price + selling_price
  var showCreditOptions = false.obs;
  var showDiscountOption = false.obs;
  var selectedCustomerId = Rxn<String>();
  var newCustomerName = ''.obs;
  var newCustomerPhone = ''.obs;
  var newCustomerAddress = ''.obs;
  var creditAmount = Rxn<double>();
  var creditDueDate = Rxn<DateTime>();
  var discount = 0.0.obs;
  var searchQuery = ''.obs;
  var isSelling = false.obs;
  var cachedStockQuantity = Rxn<double>();
  var isStockLoading = true.obs;
  var recentSalesFuture = Rxn<Future<List<dynamic>>>();

  // Kesh
  final Map<String, Map<String, dynamic>> batchCache = {};

  // TextEditingController’lar
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController newCustomerNameController = TextEditingController();
  final TextEditingController newCustomerPhoneController = TextEditingController();
  final TextEditingController newCustomerAddressController = TextEditingController();
  final TextEditingController creditAmountController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    recentSalesFuture.value = apiService.getRecentSales(limit: 3);
    preloadBatchData();
  }

  @override
  void onClose() {
    quantityController.dispose();
    priceController.dispose();
    newCustomerNameController.dispose();
    newCustomerPhoneController.dispose();
    newCustomerAddressController.dispose();
    creditAmountController.dispose();
    discountController.dispose();
    super.onClose();
  }

  double getTotalPrice() {
    print(
        'getTotalPrice: selectedBatchId: $selectedBatchId, quantity: $quantity, basePrice: $basePrice, unitPrice: $unitPrice, discount: $discount');
    final totalWithoutDiscount = quantity.value * (basePrice.value + unitPrice.value);
    return totalWithoutDiscount - discount.value;
  }

  // Partiyalar ma'lumotlarini oldindan yuklash
  Future<void> preloadBatchData() async {
    isStockLoading.value = true;
    final batches = await apiService.getBatches();
    for (var batch in batches) {
      final batchId = batch['id'].toString();
      if (!batchCache.containsKey(batchId)) {
        batchCache[batchId] = {
          'product_id': batch['product_id'].toString(),
          'quantity': (batch['quantity'] as num).toDouble(),
          'cost_price': (batch['cost_price'] as num).toDouble(),
          'selling_price': (batch['selling_price'] as num).toDouble(),
        };
      }
    }
    isStockLoading.value = false;
  }

  void selectCategory(String? id) {
    selectedCategoryId.value = id;
    selectedProductId.value = null;
    selectedBatchId.value = null;
    cachedStockQuantity.value = null;
    resetSalePanel();
  }

  void selectProduct(String productId, String? batchId, double stockQuantity, double costPrice, double sellingPrice) {
    selectedProductId.value = productId;
    selectedBatchId.value = batchId;
    cachedStockQuantity.value = stockQuantity;
    basePrice.value = costPrice + sellingPrice; // Asosiy narx
    unitPrice.value = 0.0; // Ustama haq 0 dan boshlanadi
    priceController.text = '0';
    print(
        'selectProduct: productId: $productId, batchId: $batchId, stockQuantity: $stockQuantity, basePrice: $basePrice, unitPrice: $unitPrice');
    // Faqat kerakli holatlarni reset qilamiz, basePrice saqlanadi
    showCreditOptions.value = false;
    showDiscountOption.value = false;
    selectedCustomerId.value = null;
    newCustomerName.value = '';
    newCustomerPhone.value = '';
    newCustomerAddress.value = '';
    creditAmount.value = null;
    creditDueDate.value = null;
    discount.value = 0.0;
    newCustomerNameController.clear();
    newCustomerPhoneController.clear();
    newCustomerAddressController.clear();
    creditAmountController.clear();
    discountController.clear();
    quantity.value = 1.0; // Miqdor avtomatik 1
    quantityController.text = '1';
    update(['quantity', 'totalPrice']); // UI yangilanishi uchun
  }

  void updateQuantity(String value) {
    print('updateQuantity: input value: $value');
    // Bo‘sh kiritish
    if (value.isEmpty) {
      quantity.value = 0.0;
      update(['totalPrice']);
      return;
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue == null || parsedValue < 0) {
      // Noto‘g‘ri kiritish, quantity o‘zgarmaydi
      quantity.value = 0.0;
      quantityController.text = '';
      update(['totalPrice']);
      return;
    }

    // Qoldiq chegarasini tekshiramiz
    if (cachedStockQuantity.value != null && parsedValue > cachedStockQuantity.value!) {
      quantity.value = cachedStockQuantity.value!;
      quantityController.text = cachedStockQuantity.value!.toString();
      // Kursor oxirida qolishi uchun
      quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: quantityController.text.length),
      );
    } else {
      quantity.value = parsedValue;
    }

    print('updateQuantity: quantity set to: ${quantity.value}');
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  void incrementQuantity() {
    if (cachedStockQuantity.value != null && quantity.value < cachedStockQuantity.value!) {
      quantity.value += 1.0;
      quantityController.text = quantity.value.toString();
      print('incrementQuantity: quantity set to: ${quantity.value}');
      if (showCreditOptions.value) {
        creditAmount.value = getTotalPrice();
        creditAmountController.text = creditAmount.value?.toString() ?? '';
      }
      update(['quantity', 'totalPrice']);
    }
  }

  void decrementQuantity() {
    if (quantity.value > 0) {
      quantity.value -= 1.0;
      quantityController.text = quantity.value.toString();
      print('decrementQuantity: quantity set to: ${quantity.value}');
      if (showCreditOptions.value) {
        creditAmount.value = getTotalPrice();
        creditAmountController.text = creditAmount.value?.toString() ?? '';
      }
      update(['quantity', 'totalPrice']);
    }
  }

  void updatePrice(String value) {
    unitPrice.value = double.tryParse(value) ?? 0.0;
    print('updatePrice: unitPrice set to: ${unitPrice.value}');
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  void toggleCreditOptions(bool value) {
    showCreditOptions.value = value;
    if (value && selectedProductId.value != null && quantity.value > 0) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    } else {
      creditAmount.value = null;
      selectedCustomerId.value = null;
      newCustomerName.value = '';
      newCustomerPhone.value = '';
      newCustomerAddress.value = '';
      creditDueDate.value = null;
      newCustomerNameController.clear();
      newCustomerPhoneController.clear();
      newCustomerAddressController.clear();
      creditAmountController.clear();
    }
    update(['totalPrice']);
  }

  void toggleDiscountOption(bool value) {
    showDiscountOption.value = value;
    if (!value) {
      discount.value = 0.0;
      discountController.clear();
    }
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  void updateCustomerSelection(String? value) {
    selectedCustomerId.value = value;
    newCustomerName.value = '';
    newCustomerPhone.value = '';
    newCustomerAddress.value = '';
    newCustomerNameController.clear();
    newCustomerPhoneController.clear();
    newCustomerAddressController.clear();
  }

  void updateNewCustomerName(String value) {
    newCustomerName.value = value;
    selectedCustomerId.value = null;
  }

  void updateNewCustomerPhone(String value) {
    newCustomerPhone.value = value;
  }

  void updateNewCustomerAddress(String value) {
    newCustomerAddress.value = value;
  }

  void updateCreditAmount(String value) {
    creditAmount.value = double.tryParse(value) ?? getTotalPrice();
  }

  void updateDiscount(String value) {
    discount.value = double.tryParse(value) ?? 0.0;
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  Future<void> selectCreditDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      creditDueDate.value = pickedDate;
    }
  }

  void resetSalePanel() {
    quantity.value = 0.0;
    unitPrice.value = 0.0;
    showCreditOptions.value = false;
    showDiscountOption.value = false;
    selectedCustomerId.value = null;
    newCustomerName.value = '';
    newCustomerPhone.value = '';
    newCustomerAddress.value = '';
    creditAmount.value = null;
    creditDueDate.value = null;
    discount.value = 0.0;
    quantityController.clear();
    priceController.clear();
    newCustomerNameController.clear();
    newCustomerPhoneController.clear();
    newCustomerAddressController.clear();
    creditAmountController.clear();
    discountController.clear();
    update(['totalPrice']);
  }

  Future<void> sellProduct(BuildContext context) async {
    // Kiritilgan miqdorni qoldiq bilan tekshirish
    final parsedQuantity = double.tryParse(quantityController.text) ?? quantity.value;
    if (cachedStockQuantity.value != null && parsedQuantity > cachedStockQuantity.value!) {
      quantity.value = cachedStockQuantity.value!;
      quantityController.text = quantity.value.toString();
      update(['quantity', 'totalPrice']);
    } else {
      quantity.value = parsedQuantity;
    }

    if (selectedProductId.value == null || selectedBatchId.value == null || quantity.value <= 0) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Mahsulot tanlang va miqdor 0 dan katta bo‘lsin', type: CustomToast.error,);
      return;
    }
    if (cachedStockQuantity.value != null && quantity.value > cachedStockQuantity.value!) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Omborda yetarli mahsulot yo‘q', type: CustomToast.error);
      return;
    }
    if (showCreditOptions.value && (creditAmount.value == null || creditDueDate.value == null)) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Qarz uchun summa va muddatni kiriting', type: CustomToast.error);
      return;
    }
    if (showCreditOptions.value && selectedCustomerId.value == null && (newCustomerName.value.isEmpty)) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Mijozni tanlang yoki yangi mijoz ismini kiriting', type: CustomToast.error);
      return;
    }
    if (discount.value > getTotalPrice()) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Chegirma jami summadan katta bo‘lmasligi kerak', type: CustomToast.error);
      return;
    }

    isSelling.value = true;

    try {
      String? customerId = selectedCustomerId.value;
      if (customerId == null && newCustomerName.value.isNotEmpty) {
        final customerResponse = await apiService.addCustomer(
          fullName: newCustomerName.value,
          phoneNumber: newCustomerPhone.value.isNotEmpty ? newCustomerPhone.value : null,
          address: newCustomerAddress.value.isNotEmpty ? newCustomerAddress.value : null,
          createdBy: _supabase.auth.currentUser!.id,
        );
        customerId = customerResponse['id'].toString();
        appController.customers.add(customerResponse);
      }

      String saleType;
      if (showCreditOptions.value && showDiscountOption.value) {
        saleType = 'debt_with_discount';
      } else if (showCreditOptions.value) {
        saleType = 'debt';
      } else if (showDiscountOption.value) {
        saleType = 'discount';
      } else {
        saleType = 'cash';
      }

      final saleResponse = await apiService.addSale(
        saleType: saleType,
        customerId: customerId != null ? int.parse(customerId) : null,
        totalAmount: getTotalPrice(),
        discountAmount: discount.value,
        paidAmount: saleType == 'cash' || saleType == 'discount' ? getTotalPrice() : 0.0,
        createdBy: _supabase.auth.currentUser!.id,
        comments: saleType == 'debt_with_discount' ? 'Qarzga va chegirma bilan sotuv' : saleType == 'debt' ? 'Qarzga sotuv' : saleType == 'discount' ? 'Chegirma bilan sotuv' : 'Naqd sotuv'
      );

      await apiService.addSaleItem(
        saleId: saleResponse['id'],
        batchId: int.parse(selectedBatchId.value!),
        quantity: quantity.value.toInt(),
        unitPrice: basePrice.value + unitPrice.value, // Asosiy narx + ustama haq
      );

      batchCache[selectedBatchId.value!]!['quantity'] = (batchCache[selectedBatchId.value!]!['quantity'] ?? 0.0) - quantity.value;
      selectedProductId.value = null;
      selectedBatchId.value = null;
      cachedStockQuantity.value = null;
      resetSalePanel();
      recentSalesFuture.value = apiService.getRecentSales(limit: 3);
      CustomToast.show(context: context, title: 'Muvaffaqiyat', message: 'Mahsulot sotildi', type: CustomToast.success);
    } catch (e) {
      print('Xatolik: $e');
      CustomToast.show(context: context, title: 'Xatolik', message: e.toString(), type: CustomToast.error);
    } finally {
      isSelling.value = false;
    }
  }
}