import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/companents/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'get_controller.dart';

class SalesScreenController extends GetxController {
  final ApiService apiService = ApiService();
  final GetController appController = Get.find<GetController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  var selectedCategoryId = Rxn<String>();
  var selectedProductId = Rxn<String>();
  var selectedBatchIds = <String>[].obs;
  var quantity = 0.0.obs;
  var unitPrice = 0.0.obs;
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

  final Map<String, Map<String, dynamic>> batchCache = {};

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
    recentSalesFuture.value = apiService.getRecentSales(limit: 2);
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

  // Jami narxni hisoblash (FIFO bo‘yicha)
  double getTotalPrice() {
    if (selectedProductId.value == null || quantity.value <= 0) return 0.0;

    final batches = batchCache.entries
        .where((entry) => entry.value['product_id'] == selectedProductId.value)
        .toList()
      ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

    double remainingQuantity = quantity.value;
    double totalPrice = 0.0;

    for (var batch in batches) {
      if (remainingQuantity <= 0) break;

      final batchQuantity = batch.value['quantity'] as double;
      final batchCostPrice = batch.value['cost_price'] as double;
      final batchSellingPrice = batch.value['selling_price'] as double;
      final pricePerUnit = batchCostPrice + batchSellingPrice;

      final quantityToUse = remainingQuantity > batchQuantity ? batchQuantity : remainingQuantity;
      totalPrice += quantityToUse * (pricePerUnit + unitPrice.value);
      remainingQuantity -= quantityToUse;
    }

    totalPrice -= discount.value;
    print('getTotalPrice: selectedBatchIds: $selectedBatchIds, quantity: $quantity, unitPrice: $unitPrice, discount: $discount, totalPrice: $totalPrice');
    return totalPrice;
  }

  // Partiya ma'lumotlarini oldindan yuklash
  Future<void> preloadBatchData() async {
    isStockLoading.value = true;
    try {
      final batches = await apiService.getBatches();
      batchCache.clear();
      for (var batch in batches) {
        final batchId = batch['id'].toString();
        batchCache[batchId] = {
          'product_id': batch['product_id'].toString(),
          'quantity': (batch['quantity'] as num?)?.toDouble() ?? 0.0,
          'cost_price': (batch['cost_price'] as num?)?.toDouble() ?? 0.0,
          'selling_price': (batch['selling_price'] as num?)?.toDouble() ?? 0.0,
          'received_date': batch['received_date'] ?? DateTime.now().toIso8601String(),
          'batch_number': batch['batch_number'] ?? 'Noma’lum',
        };
      }
      print('batchCache to‘ldirildi: ${batchCache.length} ta partiya');
    } catch (e) {
      print('preloadBatchData xatosi: $e');
      CustomToast.show(
        context: Get.context!,
        title: 'Xatolik',
        message: 'Partiyalarni yuklashda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isStockLoading.value = false;
    }
  }

  // Kategoriya tanlash
  void selectCategory(String? id) {
    selectedCategoryId.value = id;
    selectedProductId.value = null;
    selectedBatchIds.clear();
    cachedStockQuantity.value = null;
    resetSalePanel();
  }

  // Mahsulot tanlash (FIFO bilan)
  void selectProduct(String productId, double requestedQuantity) {
    selectedProductId.value = productId;
    selectedBatchIds.clear();
    cachedStockQuantity.value = 0.0;
    unitPrice.value = 0.0;

    // FIFO bo‘yicha partiyalarni tanlash
    final batches = batchCache.entries
        .where((entry) => entry.value['product_id'] == productId)
        .toList()
      ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

    double totalStockQuantity = 0.0; // Umumiy qoldiq
    double remainingQuantity = requestedQuantity;

    for (var batch in batches) {
      final batchId = batch.key;
      final batchQuantity = batch.value['quantity'] as double;
      totalStockQuantity += batchQuantity;

      if (remainingQuantity <= 0) continue;

      final quantityToUse = remainingQuantity > batchQuantity ? batchQuantity : remainingQuantity;
      selectedBatchIds.add(batchId);
      remainingQuantity -= quantityToUse;
    }

    if (totalStockQuantity > 0) {
      quantity.value = requestedQuantity; // Avtomatik 1.0
      cachedStockQuantity.value = totalStockQuantity; // Umumiy qoldiq
      quantityController.text = quantity.value.toString();
      priceController.text = unitPrice.value.toString();
    } else {
      selectedProductId.value = null;
      selectedBatchIds.clear();
      cachedStockQuantity.value = null;
      resetSalePanel();
      CustomToast.show(
        context: Get.context!,
        title: 'Xatolik',
        message: 'Omborda yetarli mahsulot yo‘q',
        type: CustomToast.error,
      );
      return;
    }

    print('selectProduct: productId: $productId, batchIds: $selectedBatchIds, stockQuantity: $cachedStockQuantity, unitPrice: $unitPrice, quantity: $quantity');
    update(['quantity', 'totalPrice']);
  }

  // Miqdorni yangilash
  void updateQuantity(String value) {
    print('updateQuantity: input value: $value');
    if (value.isEmpty) {
      quantity.value = 0.0;
      update(['totalPrice']);
      return;
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue == null || parsedValue < 0) {
      quantity.value = 0.0;
      quantityController.text = '';
      update(['totalPrice']);
      return;
    }

    if (cachedStockQuantity.value != null && parsedValue > cachedStockQuantity.value!) {
      quantity.value = cachedStockQuantity.value!;
      quantityController.text = cachedStockQuantity.value!.toString();
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
    update(['quantity', 'totalPrice']);
  }

  // Miqdorni oshirish
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

  // Miqdorni kamaytirish
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

  // Narxni yangilash
  void updatePrice(String value) {
    unitPrice.value = double.tryParse(value) ?? 0.0;
    print('updatePrice: unitPrice set to: ${unitPrice.value}');
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  // Qarz opsiyasini yoqish/o‘chirish
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

  // Chegirma opsiyasini yoqish/o‘chirish
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

  // Mijoz tanlash
  void updateCustomerSelection(String? value) {
    selectedCustomerId.value = value;
    newCustomerName.value = '';
    newCustomerPhone.value = '';
    newCustomerAddress.value = '';
    newCustomerNameController.clear();
    newCustomerPhoneController.clear();
    newCustomerAddressController.clear();
  }

  // Yangi mijoz nomini yangilash
  void updateNewCustomerName(String value) {
    newCustomerName.value = value;
    selectedCustomerId.value = null;
  }

  // Yangi mijoz telefonini yangilash
  void updateNewCustomerPhone(String value) {
    newCustomerPhone.value = value;
  }

  // Yangi mijoz manzilini yangilash
  void updateNewCustomerAddress(String value) {
    newCustomerAddress.value = value;
  }

  // Qarz summasini yangilash
  void updateCreditAmount(String value) {
    creditAmount.value = double.tryParse(value) ?? getTotalPrice();
  }

  // Chegirmani yangilash
  void updateDiscount(String value) {
    discount.value = double.tryParse(value) ?? 0.0;
    if (showCreditOptions.value) {
      creditAmount.value = getTotalPrice();
      creditAmountController.text = creditAmount.value?.toString() ?? '';
    }
    update(['totalPrice']);
  }

  // Qarz muddatini tanlash
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

  Future<void> sellAtCostPrice(BuildContext context) async {
    final parsedQuantity = double.tryParse(quantityController.text) ?? quantity.value;
    if (cachedStockQuantity.value != null && parsedQuantity > cachedStockQuantity.value!) {
      quantity.value = cachedStockQuantity.value!;
      quantityController.text = quantity.value.toString();
      update(['quantity', 'totalPrice']);
    } else {
      quantity.value = parsedQuantity;
    }

    if (selectedProductId.value == null || quantity.value <= 0) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Mahsulot tanlang va miqdor 0 dan katta bo‘lsin',
        type: CustomToast.error,
      );
      return;
    }
    if (cachedStockQuantity.value != null && quantity.value > cachedStockQuantity.value!) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Omborda yetarli mahsulot yo‘q',
        type: CustomToast.error,
      );
      return;
    }
    if (showCreditOptions.value && (creditAmount.value == null || creditDueDate.value == null)) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Qarz uchun summa va muddatni kiriting',
        type: CustomToast.error,
      );
      return;
    }
    if (showCreditOptions.value && selectedCustomerId.value == null && newCustomerName.value.isEmpty) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Mijozni tanlang yoki yangi mijoz ismini kiriting',
        type: CustomToast.error,
      );
      return;
    }
    if (discount.value > getTotalPrice()) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Chegirma jami summadan katta bo‘lmasligi kerak',
        type: CustomToast.error,
      );
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
        if (customerResponse.isEmpty) {
          throw Exception('Mijoz qo‘shishda xato yuz berdi');
        }
        customerId = customerResponse['id'].toString();
        appController.customers.add(customerResponse);
      }

      String saleType;
      if (showCreditOptions.value && showDiscountOption.value) {
        saleType = 'debt_with_discount';
      } else if (showCreditOptions.value) {
        saleType = 'debt';
      } else {
        saleType = 'discount'; // Chegirmali sotish bilan bir xil
      }

      // FIFO bo‘yicha partiyalarni tanlash
      final items = await _prepareCostPriceSaleItems(selectedProductId.value!, quantity.value);
      double totalPrice = 0.0;
      double totalDiscount = 0.0;
      for (var item in items) {
        totalPrice += item['total_price'] as double;
        totalDiscount += item['discount_amount'] as double;
      }

      final saleResponse = await apiService.addSale(
        saleType: saleType,
        customerId: customerId != null ? int.parse(customerId) : null,
        totalAmount: totalPrice,
        discountAmount: totalDiscount + discount.value,
        paidAmount: saleType == 'discount' ? totalPrice : 0.0,
        comments: saleType == 'debt_with_discount'
            ? 'Qarzga va chegirma bilan sotuv'
            : saleType == 'debt'
            ? 'Qarzga sotuv'
            : 'Tan narxiga chegirma bilan sotuv',
        createdBy: _supabase.auth.currentUser!.id,
        items: items,
      );

      if (saleResponse.isEmpty) {
        throw Exception('Sotuv qo‘shishda xato yuz berdi');
      }

      // Qoldiqni yangilash
      cachedStockQuantity.value = (cachedStockQuantity.value ?? 0.0) - quantity.value;
      for (var item in items) {
        final batchId = item['batch_id'].toString();
        final itemQuantity = item['quantity'] as double;
        if (batchCache.containsKey(batchId)) {
          batchCache[batchId]!['quantity'] = (batchCache[batchId]!['quantity'] ?? 0.0) - itemQuantity;
        }
      }

      // Sotuv panelini tozalash
      selectedProductId.value = null;
      selectedBatchIds.clear();
      cachedStockQuantity.value = null;
      resetSalePanel();

      // Oxirgi sotuvlarni yangilash
      recentSalesFuture.value = apiService.getRecentSales(limit: 2);
      update();

      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'Mahsulot tan narxiga sotildi',
        type: CustomToast.success,
      );
    } catch (e) {
      String errorMessage = 'Sotuv amalga oshirishda xato yuz berdi';
      if (e.toString().contains('sale_type')) {
        errorMessage = 'Ma\'lumotlar bazasida sotuv turi bilan bog‘liq muammo bor';
      }
      print('Xatolik: $e');
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: errorMessage,
        type: CustomToast.error,
      );
    } finally {
      isSelling.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _prepareCostPriceSaleItems(String productId, double requestedQuantity) async {
    final batches = batchCache.entries
        .where((entry) => entry.value['product_id'] == productId)
        .toList()
      ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

    double remainingQuantity = requestedQuantity;
    List<Map<String, dynamic>> items = [];

    for (var batch in batches) {
      if (remainingQuantity <= 0) break;

      final batchId = batch.key;
      final batchQuantity = batch.value['quantity'] as double;
      final batchCostPrice = batch.value['cost_price'] as double;
      final batchSellingPrice = batch.value['selling_price'] as double;

      final quantityToUse = remainingQuantity > batchQuantity ? batchQuantity : remainingQuantity;
      final discountAmount = batchSellingPrice * quantityToUse; // Sotish narxi chegirma sifatida

      items.add({
        'product_id': int.parse(productId),
        'batch_id': int.parse(batchId),
        'quantity': quantityToUse,
        'unit_price': batchCostPrice, // Faqat tan narxi
        'total_price': quantityToUse * batchCostPrice,
        'discount_amount': discountAmount,
      });

      remainingQuantity -= quantityToUse;
    }

    if (remainingQuantity > 0) {
      throw Exception('Omborda yetarli mahsulot yo‘q: product_id=$productId');
    }

    return items;
  }

  // Sotuv panelini tozalash
  void resetSalePanel() {
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
    update(['totalPrice']);
  }

  Future<void> sellProduct(BuildContext context) async {
    final parsedQuantity = double.tryParse(quantityController.text) ?? quantity.value;
    if (cachedStockQuantity.value != null && parsedQuantity > cachedStockQuantity.value!) {
      quantity.value = cachedStockQuantity.value!;
      quantityController.text = quantity.value.toString();
      update(['quantity', 'totalPrice']);
    } else {
      quantity.value = parsedQuantity;
    }

    if (selectedProductId.value == null || quantity.value <= 0) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Mahsulot tanlang va miqdor 0 dan katta bo‘lsin',
        type: CustomToast.error,
      );
      return;
    }
    if (cachedStockQuantity.value != null && quantity.value > cachedStockQuantity.value!) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Omborda yetarli mahsulot yo‘q',
        type: CustomToast.error,
      );
      return;
    }
    if (showCreditOptions.value && (creditAmount.value == null || creditDueDate.value == null)) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Qarz uchun summa va muddatni kiriting',
        type: CustomToast.error,
      );
      return;
    }
    if (showCreditOptions.value && selectedCustomerId.value == null && newCustomerName.value.isEmpty) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Mijozni tanlang yoki yangi mijoz ismini kiriting',
        type: CustomToast.error,
      );
      return;
    }
    if (discount.value > getTotalPrice()) {
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Chegirma jami summadan katta bo‘lmasligi kerak',
        type: CustomToast.error,
      );
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
        if (customerResponse.isEmpty) {
          throw Exception('Mijoz qo‘shishda xato yuz berdi');
        }
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

      final totalPrice = getTotalPrice();
      final items = await _prepareSaleItems(selectedProductId.value!, quantity.value);
      final saleResponse = await apiService.addSale(
        saleType: saleType,
        customerId: customerId != null ? int.parse(customerId) : null,
        totalAmount: totalPrice,
        discountAmount: discount.value,
        paidAmount: saleType == 'cash' || saleType == 'discount' ? totalPrice : 0.0,
        comments: saleType == 'debt_with_discount'
            ? 'Qarzga va chegirma bilan sotuv'
            : saleType == 'debt'
            ? 'Qarzga sotuv'
            : saleType == 'discount'
            ? 'Chegirma bilan sotuv'
            : 'Naqd sotuv',
        createdBy: _supabase.auth.currentUser!.id,
        items: items,
      );

      if (saleResponse.isEmpty) {
        throw Exception('Sotuv qo‘shishda xato yuz berdi');
      }

      // Qoldiqni yangilash
      cachedStockQuantity.value = (cachedStockQuantity.value ?? 0.0) - quantity.value;
      for (var item in items) {
        final batchId = item['batch_id'].toString();
        final itemQuantity = item['quantity'] as double;
        if (batchCache.containsKey(batchId)) {
          batchCache[batchId]!['quantity'] = (batchCache[batchId]!['quantity'] ?? 0.0) - itemQuantity;
        }
      }

      // Sotuv panelini tozalash
      selectedProductId.value = null;
      selectedBatchIds.clear();
      cachedStockQuantity.value = null;
      resetSalePanel();

      // Oxirgi sotuvlarni yangilash
      recentSalesFuture.value = apiService.getRecentSales(limit: 2);
      print('recentSalesFuture yangilandi: saleId=${saleResponse['id']}, saleType=$saleType');
      update(); // UI ni qayta chizish uchun

      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'Mahsulot sotildi',
        type: CustomToast.success,
      );
    } catch (e) {
      String errorMessage = 'Sotuv amalga oshirishda xato yuz berdi';
      if (e.toString().contains('sale_type')) {
        errorMessage = 'Ma\'lumotlar bazasida sotuv turi bilan bog‘liq muammo bor';
      }
      print('Xatolik: $e');
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: errorMessage,
        type: CustomToast.error,
      );
    } finally {
      isSelling.value = false;
    }
  }

  // FIFO bo‘yicha sotuv elementlarini tayyorlash
  Future<List<Map<String, dynamic>>> _prepareSaleItems(String productId, double requestedQuantity) async {
    final batches = batchCache.entries
        .where((entry) => entry.value['product_id'] == productId)
        .toList()
      ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

    double remainingQuantity = requestedQuantity;
    List<Map<String, dynamic>> items = [];

    for (var batch in batches) {
      if (remainingQuantity <= 0) break;

      final batchId = batch.key;
      final batchQuantity = batch.value['quantity'] as double;
      final batchCostPrice = batch.value['cost_price'] as double;
      final batchSellingPrice = batch.value['selling_price'] as double;
      final pricePerUnit = batchCostPrice + batchSellingPrice;

      final quantityToUse = remainingQuantity > batchQuantity ? batchQuantity : remainingQuantity;
      items.add({
        'product_id': int.parse(productId),
        'batch_id': int.parse(batchId),
        'quantity': quantityToUse,
        'unit_price': pricePerUnit + unitPrice.value,
        'total_price': quantityToUse * (pricePerUnit + unitPrice.value),
      });

      remainingQuantity -= quantityToUse;
    }

    if (remainingQuantity > 0) {
      throw Exception('Omborda yetarli mahsulot yo‘q: product_id=$productId');
    }

    return items;
  }

  // Mahsulotni qaytarish
  Future<void> returnProduct(BuildContext context, int saleId) async {
    isSelling.value = true;

    try {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tovar qaytarish'),
          content: const Text('Ushbu sotuvni qaytarishni tasdiqlaysizmi? Mahsulot omborga qaytariladi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tasdiqlash'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        isSelling.value = false;
        return;
      }

      print('return_sale chaqirilmoqda: saleId=$saleId');
      await _supabase.rpc('return_sale', params: {'p_sale_id': saleId});
      print('Sotuv qaytarildi: saleId=$saleId');

      final saleItems = await apiService.getSaleItems(saleId: saleId);
      print('Sale items for saleId=$saleId: $saleItems');
      for (var item in saleItems) {
        final itemBatchId = item['batch_id']?.toString();
        final itemQuantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
        if (itemBatchId != null && batchCache.containsKey(itemBatchId)) {
          batchCache[itemBatchId]!['quantity'] =
              (batchCache[itemBatchId]!['quantity'] ?? 0.0) + itemQuantity;
          print('batchCache updated: $itemBatchId, new quantity=${batchCache[itemBatchId]!['quantity']}');
        }
      }

      recentSalesFuture.value = apiService.getRecentSales(limit: 2);

      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'Tovar omborga qaytarildi va sotuv qaytarilgan deb belgilandi',
        type: CustomToast.success,
      );
    } catch (e) {
      print('Tovar qaytarishda xato: $e');
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'Tovar qaytarishda xato yuz berdi: $e',
        type: CustomToast.error,
      );
    } finally {
      isSelling.value = false;
    }
  }

  // Qarz to‘lash
  Future<void> payDebt(BuildContext context, int saleId, double paymentAmount) async {
    isSelling.value = true;
    try {
      final sale = await _supabase
          .from('sales')
          .select('customer_id, total_amount, paid_amount')
          .eq('id', saleId)
          .single();

      final customerId = sale['customer_id'] as int?;
      final totalAmount = (sale['total_amount'] as num?)?.toDouble() ?? 0.0;
      final currentPaidAmount = (sale['paid_amount'] as num?)?.toDouble() ?? 0.0;

      if (customerId == null) {
        CustomToast.show(
          context: context,
          title: 'Xatolik',
          message: 'Mijoz ID topilmadi',
          type: CustomToast.error,
        );
        return;
      }

      if (paymentAmount <= 0) {
        CustomToast.show(
          context: context,
          title: 'Xatolik',
          message: 'To‘lov miqdori musbat bo‘lishi kerak',
          type: CustomToast.error,
        );
        return;
      }

      if (paymentAmount > (totalAmount - currentPaidAmount)) {
        CustomToast.show(
          context: context,
          title: 'Xatolik',
          message: 'To‘lov miqdori qoldiq qarzdan ($totalAmount - $currentPaidAmount) ko‘p bo‘lmasligi kerak',
          type: CustomToast.error,
        );
        return;
      }

      print('debt_payment qo‘shilmoqda: Sale ID: $saleId, Miqdor: $paymentAmount, Mijoz ID: $customerId');
      await apiService.addTransaction(
        transactionType: 'debt_payment',
        amount: paymentAmount,
        customerId: customerId,
        saleId: saleId,
        comments: 'Qarz to‘lovi (Sale ID: $saleId)',
        createdBy: _supabase.auth.currentUser!.id,
      );

      await apiService.updateSalePaidAmount(saleId, paymentAmount);

      recentSalesFuture.value = apiService.getRecentSales(limit: 2);

      CustomToast.show(
        context: context,
        title: 'Muvaffaqiyat',
        message: 'To‘lov qabul qilindi',
        type: CustomToast.success,
      );
    } catch (e) {
      print('To‘lov xatosi: $e');
      CustomToast.show(
        context: context,
        title: 'Xatolik',
        message: 'To‘lovni amalga oshirishda xato: $e',
        type: CustomToast.error,
      );
    } finally {
      isSelling.value = false;
    }
  }
}