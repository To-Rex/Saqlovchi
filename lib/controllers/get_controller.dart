import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/main/main_screen.dart';
import 'api_service.dart';

class GetController extends GetxController {
  final ApiService _apiService = ApiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Foydalanuvchi ma'lumotlari
  var fullName = 'Dilshodjon Haydarov'.obs;
  var role = 'seller'.obs;
  Locale get language => Locale(GetStorage().read('language') ?? 'uz_UZ');

  // TextField kontrollerlari
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
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
      products.value = await _apiService.getProducts();
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
      error.value = 'Ma’lumotlarni olishda xato: $e';
    } finally {
      isLoading.value = false;
    }
  }
  // Filtrlash va tartiblash bilan ma’lumotlarni yuklash
  Future<void> fetchFilteredAndSortedData() async {
    isLoading.value = true;
    try {
      var query = _supabase.from('products').select('''
      *,
      categories(name),
      units(name),
      batches(id, quantity, batch_number, cost_price, selling_price),
      sales(id, sale_type, discount_amount, paid_amount)
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

      // Sotuv holati filtri
      if (filterSaleStatus.value.isNotEmpty) {
        query = query.eq('sales.sale_type', filterSaleStatus.value);
      }

      // Tugagan mahsulotlar filtri
      if (filterOutOfStock.value) {
        query = query.eq('batches.quantity', 0);
      }

      // Miqdor filtri
      if (filterMinQuantity.value != null) {
        query = query.gte('batches.quantity', filterMinQuantity.value!);
      }
      if (filterMaxQuantity.value != null) {
        query = query.lte('batches.quantity', filterMaxQuantity.value!);
      }

      // Tannarx filtri
      if (filterMinCostPrice.value != null) {
        query = query.gte('batches.cost_price', filterMinCostPrice.value!);
      }
      if (filterMaxCostPrice.value != null) {
        query = query.lte('batches.cost_price', filterMaxCostPrice.value!);
      }

      // Sotish narxi filtri
      if (filterMinSellingPrice.value != null) {
        query = query.gte('batches.selling_price', filterMinSellingPrice.value!);
      }
      if (filterMaxSellingPrice.value != null) {
        query = query.lte('batches.selling_price', filterMaxSellingPrice.value!);
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

      products.value = response;
      error.value = '';
    } catch (e) {
      error.value = 'Ma’lumotlarni olishda xato: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Yangi kategoriya qo‘shish
  Future<void> addCategory() async {
    isLoading.value = true;
    try {
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
    } finally {
      isLoading.value = false;
    }
  }

  // Kategoriyani tahrirlash
  Future<void> editCategory(String id, String name) async {
    isLoading.value = true;
    try {
      await _apiService.updateCategory(
        id: int.parse(id),
        name: name,
        description: null,
      );
      await fetchInitialData();
    } catch (e) {
      error.value = 'Kategoriya tahrirlashda xato: $e';
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
    } catch (e) {
      error.value = 'Kategoriya o‘chirishda xato: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Yangi mahsulot qo‘shish
  Future<void> addProduct() async {
    isLoading.value = true;
    try {
      if (newProductName.value.isEmpty) {
        print('Xato: Mahsulot nomi kiritilmadi');
        return;
      }
      if (newProductCategoryId.value == null) {
        print('Xato: Kategoriya tanlanmadi');
        return;
      }
      if (newProductUnitId.value == null) {
        print('Xato: Birlik tanlanmadi');
        return;
      }
      if (newProductQuantity.value <= 0) {
        print('Xato: Miqdor ijobiy bo‘lishi kerak');
        return;
      }
      if (newProductCostPrice.value <= 0) {
        print('Xato: Tannarx ijobiy bo‘lishi kerak');
        return;
      }
      if (newProductSellingPrice.value <= 0) {
        print('Xato: Sotish narxi ijobiy bo‘lishi kerak');
        return;
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Xato: Foydalanuvchi autentifikatsiya qilinmagan');
        return;
      }

      final productResponse = await _apiService.addProduct(
        name: newProductName.value,
        categoryId: newProductCategoryId.value!,
        unitId: newProductUnitId.value!,
        description: newProductDescription.value.isEmpty ? null : newProductDescription.value,
        createdBy: userId,
      );

      if (productResponse.isNotEmpty) {
        // Partiya qo‘shish
        await _apiService.addBatch(
          productId: productResponse['id'],
          batchNumber: newProductBatchNumber.value.isEmpty
              ? 'B${DateTime.now().millisecondsSinceEpoch}'
              : newProductBatchNumber.value,
          quantity: newProductQuantity.value.toInt(),
          costPrice: newProductCostPrice.value,
          sellingPrice: newProductSellingPrice.value,
          createdBy: userId,
        );

        await fetchInitialData();
        print('Mahsulot va partiya muvaffaqiyatli qo‘shildi: ${productResponse['name']}');
      } else {
        print('Xato: Mahsulot qo‘shilmadi, javob bo‘sh');
      }
    } catch (e) {
      print('addProduct xatosi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mahsulotni tahrirlash
  Future<void> editProduct(String id, String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    isLoading.value = true;
    try {
      if (name.isEmpty) {
        throw Exception('Mahsulot nomi kiritilishi shart');
      }
      if (costPrice <= 0 || (sellingPrice != null && sellingPrice <= 0) || (quantity != null && quantity <= 0)) {
        throw Exception('Miqdor va narxlar ijobiy bo‘lishi kerak');
      }

      await _apiService.updateProduct(
        id: int.parse(id),
        name: name,
        categoryId: int.parse(categoryId),
        unitId: int.parse(unitId),
        description: null,
      );

      // Partiyani yangilash
      if (quantity != null || sellingPrice != null || costPrice != 0) {
        final product = products.firstWhere((p) => p['id'].toString() == id);
        final batch = product['batches']?.isNotEmpty == true ? product['batches'][0] : null;
        if (batch != null) {
          await _apiService.updateBatch(
            id: batch['id'],
            quantity: quantity?.toInt() ?? batch['quantity'],
            costPrice: costPrice,
            sellingPrice: sellingPrice ?? batch['selling_price'],
            comments: 'Tahrirlangan',
          );
        }
      }

      await fetchInitialData();
      Get.snackbar('Muvaffaqiyat', 'Mahsulot tahrirlandi',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Mahsulot tahrirlashda xato: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Mahsulotni o‘chirish
  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    try {
      await _apiService.deleteProduct(int.parse(id));
      await fetchInitialData();
    } catch (e) {
      error.value = 'Mahsulot o‘chirishda xato: $e';
    } finally {
      isLoading.value = false;
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
      Get.snackbar('Muvaffaqiyat', 'Mijoz qo‘shildi', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      error.value = 'Mijoz qo‘shishda xato: $e';

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


  Future<void> handleSubmit(BuildContext context) async {
    error.value = '';
    isLoading.value = true;
    try {
      await _apiService.signIn(context, email.value, password.value);
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Role ni checkUserRole orqali olish
        final userRole = await _apiService.checkUserRole(userId);
        role.value = userRole;
        fullName.value = _supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'Noma’lum';
        print('Foydalanuvchi ma’lumatlari yuklandi: full_name=${fullName.value}, role=$userRole');
      } else {
        print('Foydalanuvchi ID topilmadi');
      }
    } catch (e) {
      error.value = 'Kirishda xato: $e';
      print('Kirish xatosi: $e');
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

    } finally {
      isLoading.value = false;
    }
  }

  // Parolni ko‘rsatish/yashirish
  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }
}