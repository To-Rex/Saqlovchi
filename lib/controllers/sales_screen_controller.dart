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
  var selectedBatchId = Rxn<String>();
  var quantity = 0.0.obs;
  var unitPrice = 0.0.obs;
  var basePrice = 0.0.obs;
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

  // Jami narxni hisoblash
  double getTotalPrice() {
    print('getTotalPrice: selectedBatchId: $selectedBatchId, quantity: $quantity, basePrice: $basePrice, unitPrice: $unitPrice, discount: $discount');
    final totalWithoutDiscount = quantity.value * (basePrice.value + unitPrice.value);
    return totalWithoutDiscount - discount.value;
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
          'received_date': batch['received_date'],
        };
      }
    } catch (e) {
      print('preloadBatchData xatosi: $e');
    } finally {
      isStockLoading.value = false;
    }
  }

  // Kategoriya tanlash
  void selectCategory(String? id) {
    selectedCategoryId.value = id;
    selectedProductId.value = null;
    selectedBatchId.value = null;
    cachedStockQuantity.value = null;
    resetSalePanel();
  }

  // Mahsulot tanlash
  void selectProduct(String productId, String? batchId, double stockQuantity, double costPrice, double sellingPrice) {
    selectedProductId.value = productId;
    selectedBatchId.value = batchId;
    cachedStockQuantity.value = stockQuantity;
    basePrice.value = costPrice;
    unitPrice.value = sellingPrice - costPrice; // Qo‘shimcha narx
    quantity.value = 1.0;
    quantityController.text = '1';
    priceController.text = unitPrice.value.toString();
    print('selectProduct: productId: $productId, batchId: $batchId, stockQuantity: $stockQuantity, basePrice: $basePrice, unitPrice: $unitPrice');
    resetSalePanel();
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
    update(['totalPrice']);
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

  // Sotuv panelini tozalash
  void resetSalePanel() {
    quantity.value = 0.0;
    unitPrice.value = 0.0;
    basePrice.value = 0.0;
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

  // Mahsulot sotish
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
        items: [
          {
            'product_id': int.parse(selectedProductId.value!),
            'quantity': quantity.value,
            'unit_price': basePrice.value + unitPrice.value,
          }
        ],
      );

      if (saleResponse.isEmpty) {
        throw Exception('Sotuv qo‘shishda xato yuz berdi');
      }

      // Qoldiqni yangilash
      cachedStockQuantity.value = (cachedStockQuantity.value ?? 0.0) - quantity.value;
      if (selectedBatchId.value != null && batchCache.containsKey(selectedBatchId.value!)) {
        batchCache[selectedBatchId.value!]!['quantity'] =
            (batchCache[selectedBatchId.value!]!['quantity'] ?? 0.0) - quantity.value;
      }

      // Sotuv panelini tozalash
      selectedProductId.value = null;
      selectedBatchId.value = null;
      cachedStockQuantity.value = null;
      resetSalePanel();
      recentSalesFuture.value = apiService.getRecentSales(limit: 2);

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