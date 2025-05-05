import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../companents/custom_toast.dart';
import '../screens/main/main_screen.dart';
import 'api_service.dart';

class GetController extends GetxController {
  final ApiService _apiService = ApiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Foydalanuvchi ma'lumotlari
  var fullName = 'User'.obs;
  var role = 'seller'.obs;
  Locale get language => Locale(GetStorage().read('language') ?? 'uz_UZ');

  // TextField kontrollerlari
  final TextEditingController customerController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Ma'lumotlar ro‘yxatlari
  RxList<dynamic> categories = <dynamic>[].obs;
  RxList<dynamic> soldItems = <dynamic>[].obs;
  RxList<dynamic> products = <dynamic>[].obs;
  RxList<dynamic> units = <dynamic>[].obs;
  RxList<dynamic> customers = <dynamic>[].obs;
  RxList<dynamic> stats = <dynamic>[].obs;

  // Yuklanish va xato holatlari
  RxBool isLoading = true.obs;
  RxString error = ''.obs;
  RxBool isProcessing = false.obs;

  // Yangi mahsulot/partiya uchun o‘zgaruvchilar
  final newCategoryName = ''.obs;
  final newProductName = ''.obs;
  final newProductCategoryId = Rxn<int>();
  final newProductUnitId = Rxn<int>();
  final newProductDescription = ''.obs;
  final newProductQuantity = 0.0.obs;
  final newProductCostPrice = 0.0.obs;
  final newProductSellingPrice = 0.0.obs;
  final newProductBatchNumber = ''.obs;
  final newProductSupplier = ''.obs;

  // Kirish uchun o‘zgaruvchilar
  final email = ''.obs;
  final password = ''.obs;
  final showPassword = false.obs;
  final search = ''.obs;

  // Filtr va tartiblash uchun o‘zgaruvchilar
  RxString filterUnit = ''.obs;
  RxString filterCategory = ''.obs;
  RxString filterSaleStatus = ''.obs;
  RxBool filterOutOfStock = false.obs;
  Rx<double?> filterMinQuantity = Rx<double?>(null);
  Rx<double?> filterMaxQuantity = Rx<double?>(null);
  Rx<DateTime?> filterStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> filterEndDate = Rx<DateTime?>(null);
  Rx<double?> filterMinCostPrice = Rx<double?>(null);
  Rx<double?> filterMaxCostPrice = Rx<double?>(null);
  Rx<double?> filterMinSellingPrice = Rx<double?>(null);
  Rx<double?> filterMaxSellingPrice = Rx<double?>(null);
  RxString sortColumn = 'created_at'.obs;
  RxBool sortAscending = false.obs;

  @override
  void onInit() {
    fetchInitialData();
    super.onInit();
  }

  // Boshlang‘ich ma'lumotlarni yuklash
  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      await _apiService.checkUserRole(_supabase.auth.currentUser!.id);
      categories.value = await _apiService.getCategories();
      products.value = await _apiService.getProductsWithStock(); // Qoldiqlarni olish
      units.value = await _apiService.getUnits();
      customers.value = await _apiService.getCustomers();
      soldItems.value = await _apiService.getSaleItems();
      stats.value = await _apiService.getSaleItems();
      if (units.isEmpty) {
        print('Warning: No units fetched');
      } else {
        print('Units loaded: ${units.length}');
      }
      error.value = '';
    } catch (e) {
      //error.value = 'Ma’lumotlarni olishda xato: $e';
      print('fetchInitialData xatosi: $e');
      Get.snackbar('Xatolik', 'Ma’lumotlarni olishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrlash va tartiblash bilan ma’lumotlarni yuklash
  Future<void> fetchFilteredAndSortedData() async {
    isLoading.value = true;
    try {
      var query = _supabase.from('products').select('''
        id, name, category_id, unit_id, description, created_by, created_at,
        categories!inner(name),
        units!inner(name),
        batches(id, quantity, batch_number, cost_price, selling_price, received_date)
      ''');

      // Kategoriya filtri
      if (filterCategory.value.isNotEmpty) {
        final categoryId = categories.firstWhereOrNull((c) => c['name'] == filterCategory.value)?['id'];
        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }
      }

      // Birlik filtri
      if (filterUnit.value.isNotEmpty) {
        final unitId = units.firstWhereOrNull((u) => u['name'] == filterUnit.value)?['id'];
        if (unitId != null) {
          query = query.eq('unit_id', unitId);
        }
      }

      // Sotuv holati filtri (sales jadvalidan)
      if (filterSaleStatus.value.isNotEmpty) {
        query = query.filter('sales.sale_type', 'eq', filterSaleStatus.value);
      }

      // Tugagan mahsulotlar filtri
      if (filterOutOfStock.value) {
        query = query.filter('batches.quantity', 'eq', 0);
      }

      // Miqdor filtri
      if (filterMinQuantity.value != null) {
        query = query.filter('batches.quantity', 'gte', filterMinQuantity.value!);
      }
      if (filterMaxQuantity.value != null) {
        query = query.filter('batches.quantity', 'lte', filterMaxQuantity.value!);
      }

      // Tannarx filtri
      if (filterMinCostPrice.value != null) {
        query = query.filter('batches.cost_price', 'gte', filterMinCostPrice.value!);
      }
      if (filterMaxCostPrice.value != null) {
        query = query.filter('batches.cost_price', 'lte', filterMaxCostPrice.value!);
      }

      // Sotish narxi filtri
      if (filterMinSellingPrice.value != null) {
        query = query.filter('batches.selling_price', 'gte', filterMinSellingPrice.value!);
      }
      if (filterMaxSellingPrice.value != null) {
        query = query.filter('batches.selling_price', 'lte', filterMaxSellingPrice.value!);
      }

      // Sana filtri
      if (filterStartDate.value != null) {
        query = query.gte('created_at', filterStartDate.value!.toIso8601String());
      }
      if (filterEndDate.value != null) {
        query = query.lte('created_at', filterEndDate.value!.toIso8601String());
      }

      // Tartiblash va so‘rovni bajarish
      final response = await query.order(sortColumn.value, ascending: sortAscending.value);

      products.value = response.map((product) {
        final stockQuantity = _calculateStockQuantity(product['batches']);
        return {
          ...product,
          'stock_quantity': stockQuantity,
        };
      }).toList();
      error.value = '';
    } catch (e) {
      error.value = 'Ma’lumotlarni olishda xato: $e';
      print('fetchFilteredAndSortedData xatosi: $e');
      Get.snackbar('Xatolik', 'Ma’lumotlarni olishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Qoldiqni hisoblash
  double _calculateStockQuantity(List<dynamic>? batches) {
    if (batches == null || batches.isEmpty) return 0.0;
    return batches.fold<double>(
      0.0,
          (sum, batch) => sum + ((batch['quantity'] as num?)?.toDouble() ?? 0.0),
    );
  }

  // Yangi kategoriya qo‘shish
  Future<void> addCategory() async {
    isLoading.value = true;
    try {
      if (newCategoryName.value.isEmpty) {
        throw Exception('Kategoriya nomi kiritilishi shart');
      }
      await _apiService.addCategory(
        name: newCategoryName.value,
        description: null,
        createdBy: _supabase.auth.currentUser?.id ?? '',
      );
      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Kategoriya qo‘shildi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Kategoriya qo‘shishda xato: $e';
      print('addCategory xatosi: $e');
      Get.snackbar('Xatolik', 'Kategoriya qo‘shishda xato: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Kategoriyani tahrirlash
  Future<void> editCategory(String id, String name) async {
    isLoading.value = true;
    try {
      if (name.isEmpty) {
        throw Exception('Kategoriya nomi kiritilishi shart');
      }
      await _apiService.updateCategory(
        id: int.parse(id),
        name: name,
        description: null,
      );
      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Kategoriya tahrirlandi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Kategoriya tahrirlashda xato: $e';
      print('editCategory xatosi: $e');
      Get.snackbar('Xatolik', 'Kategoriya tahrirlashda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Kategoriyani o‘chirish
  Future<void> deleteCategory(String id) async {
    isLoading.value = true;
    try {
      await _apiService.deleteCategory(int.parse(id));
      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Kategoriya o‘chirildi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Kategoriya o‘chirishda xato: $e';
      print('deleteCategory xatosi: $e');
      Get.snackbar('Xatolik', 'Kategoriya o‘chirishda xato: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> addProduct({int? existingProductId, String? code}) async {
    isLoading.value = true;
    try {
      // Foydalanuvchi ID sini olish
      final userId = _supabase.auth.currentUser?.id;
      print('Foydalanuvchi ID: $userId'); // Log qilish uchun
      if (userId == null) {
        throw Exception('Foydalanuvchi autentifikatsiya qilinmagan');
      }

      // UUID formatini tekshirish
      if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(userId)) {
        throw Exception('Noto‘g‘ri foydalanuvchi ID formati: $userId');
      }

      // Validatsiya
      if (newProductName.value.isEmpty && existingProductId == null) {
        throw Exception('Mahsulot nomi kiritilishi shart');
      }
      if (newProductCategoryId.value == null) {
        throw Exception('Kategoriya tanlanishi shart');
      }
      if (newProductUnitId.value == null) {
        throw Exception('Birlik tanlanishi shart');
      }
      if (newProductQuantity.value <= 0) {
        throw Exception('Miqdor ijobiy bo‘lishi kerak');
      }
      if (newProductCostPrice.value <= 0) {
        throw Exception('Tannarx ijobiy bo‘lishi kerak');
      }
      if (newProductSellingPrice.value <= 0) {
        throw Exception('Sotish narxi ijobiy bo‘lishi kerak');
      }

      Map<String, dynamic> response;

      if (existingProductId != null) {
        // Mavjud mahsulotga partiya qo‘shish
        response = await _apiService.addBatchToExistingProduct(
          productId: existingProductId,
          batchQuantity: newProductQuantity.value,
          batchCostPrice: newProductCostPrice.value,
          batchSellingPrice: newProductSellingPrice.value,
          createdBy: userId,
        );
      } else {
        // Yangi mahsulot va partiya qo‘shish
        response = await _apiService.addProductAndBatch(
          name: newProductName.value,
          categoryId: newProductCategoryId.value!,
          unitId: newProductUnitId.value!,
          batchQuantity: newProductQuantity.value,
          batchCostPrice: newProductCostPrice.value,
          batchSellingPrice: newProductSellingPrice.value,
          createdBy: userId,
          code: code,
        );
      }

      // Javobni tekshirish
      if (response.isEmpty || response['batch_id'] == null) {
        throw Exception('Mahsulot yoki partiya qo‘shishda xato: Javob bo‘sh yoki noto‘g‘ri');
      }

      // Ma'lumotlarni qayta yuklash
      await fetchInitialData();

      // CustomToast bilan xabar ko‘rsatish
      CustomToast.show(
        context: Get.context!,
        title: 'Muvaffaqiyat',
        message: existingProductId != null ? 'Partiya qo‘shildi' : 'Mahsulot va partiya qo‘shildi',
        type: CustomToast.success,
      );
    } catch (e) {
      final errorMessage = e.toString().isEmpty ? 'Noma’lum xato yuz berdi' : e.toString();
      error.value = 'Mahsulot qo‘shishda xato: $errorMessage';
      print('addProduct xatosi: $errorMessage');
      print('Xato yuz berdi: $e, toString: ${e.toString()}');
      // CustomToast bilan xato xabarini ko‘rsatish
      if (Get.context != null) {
        CustomToast.show(
          context: Get.context!,
          title: 'Xatolik',
          message: errorMessage,
          type: CustomToast.error,
        );
      } else {
        print('Kontekst mavjud emas, xato xabari ko‘rsatilmadi');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Mahsulotni tahrirlash


  // Mahsulotni yangilash
  Future<void> updateProduct({
    required String id,
    required String name,
    String? code,
    required int categoryId,
    required int unitId,
    String? description,
  }) async {
    isProcessing.value = true;
    print('Mahsulot yangilash boshlandi: productId=$id, name=$name');
    try {
      await _apiService.updateProduct(
        productId: int.parse(id),
        name: name,
        code: code,
        categoryId: categoryId,
        unitId: unitId,
        description: description,
      );
      await fetchInitialData();
    } catch (e) {
      error.value = 'Mahsulot yangilashda xato: $e';
      print('updateProduct xatosi: $e');
    } finally {
      isProcessing.value = false;
      print('Yangilash tugadi: isProcessing=false');
    }
  }

  // Mahsulotni o‘chirish
  Future<void> deleteProduct(String id) async {
    isProcessing.value = true;
    print('O‘chirish boshlandi: productId=$id');
    try {
      await _apiService.deleteProduct(int.parse(id));
      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Mahsulot o‘chirildi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Mahsulot o‘chirishda xato: $e';
      print('deleteProduct xatosi: $e');
      Get.snackbar('Xatolik', 'Mahsulot o‘chirishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
      print('O‘chirish tugadi: isProcessing=false');
    }
  }

  // Yangi mijoz qo‘shish
  Future<void> addCustomer() async {
    isLoading.value = true;
    try {
      if (customerController.text.isEmpty) {
        throw Exception('Mijoz ismi kiritilishi shart');
      }
      await _apiService.addCustomer(
        fullName: customerController.text,
        phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
        address: addressController.text.isEmpty ? null : addressController.text,
        createdBy: _supabase.auth.currentUser?.id ?? '',
      );
      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Mijoz qo‘shildi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Mijoz qo‘shishda xato: $e';
      print('addCustomer xatosi: $e');
      Get.snackbar('Xatolik', 'Mijoz qo‘shishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrlarni tozalash
  void clearFilters() {
    filterUnit.value = '';
    filterCategory.value = '';
    filterSaleStatus.value = '';
    filterOutOfStock.value = false;
    filterMinQuantity.value = null;
    filterMaxQuantity.value = null;
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterMinCostPrice.value = null;
    filterMaxCostPrice.value = null;
    filterMinSellingPrice.value = null;
    filterMaxSellingPrice.value = null;
    sortColumn.value = 'created_at';
    sortAscending.value = false;
    fetchInitialData();
  }

  // Kirish
  Future<void> handleSubmit(BuildContext context) async {
    error.value = '';
    isLoading.value = true;
    try {
      await _apiService.signIn(context, email.value, password.value);
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final userRole = await _apiService.checkUserRole(userId);
        role.value = userRole;
        fullName.value = _supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'Noma’lum';
        print('Foydalanuvchi ma’lumatlari yuklandi: full_name=${fullName.value}, role=$userRole');
      } else {
        throw Exception('Foydalanuvchi ID topilmadi');
      }
      Get.snackbar('Muvaffaqiyat', 'Tizimga kirdingiz',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Kirishda xato: $e';
      print('Kirish xatosi: $e');
      Get.snackbar('Xatolik', 'Kirishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Chiqish
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _supabase.auth.signOut();
      Get.offAllNamed('/signup');
      fullName.value = 'Foydalanuvchi';
      role.value = 'seller';
      email.value = '';
      password.value = '';
      Get.snackbar('Muvaffaqiyat', 'Tizimdan chiqildi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Chiqishda xato: $e';
      print('signOut xatosi: $e');
      Get.snackbar('Xatolik', 'Chiqishda xato: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Parolni ko‘rsatish/yashirish
  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  // Qoldiqlarni yangilash
  void updateStockQuantities(List<dynamic> newProducts) {
    products.value = newProducts;
  }
}