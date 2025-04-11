import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../screens/main/main_screen.dart';
import 'api_service.dart';

class GetController extends GetxController {
  var fullName = 'Dilshodjon Haydarov'.obs;
  Locale get language => Locale(GetStorage().read('language') ?? 'uz_UZ');

  final ApiService _apiService = ApiService();

  RxList<dynamic> categories = <dynamic>[].obs;
  RxList<dynamic> soldItems = <dynamic>[].obs;
  RxList<dynamic> products = <dynamic>[].obs;
  RxList<dynamic> units = <dynamic>[].obs;
  RxList<dynamic> customers = <dynamic>[].obs;
  RxBool isLoading = true.obs;
  RxString error = ''.obs;

  // Yangi mahsulot qo‘shish uchun o‘zgaruvchilar
  final newCategoryName = ''.obs;
  final newProductName = ''.obs;
  final newProductCategoryId = ''.obs;
  final newProductCostPrice = 0.0.obs;
  final newProductSellingPrice = 0.0.obs;
  final newProductQuantity = 0.0.obs;
  final newProductUnitId = ''.obs;

  // Kirish uchun o‘zgaruvchilar
  final email = ''.obs;
  final password = ''.obs;
  final showPassword = false.obs;
  final search = ''.obs;

  // Filtr va tartiblash uchun o‘zgaruvchilar (Rx<double?> ishlatiladi)
  RxString filterUnit = ''.obs;
  RxString filterCategory = ''.obs;
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
    fetchData();
    super.onInit();
  }

  // Ma’lumotlarni yuklash (filtrlar va tartiblashsiz)
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await _apiService.getCategories();
      final fetchedSoldItems = await _apiService.getSoldItems();
      final fetchedProducts = await _apiService.getProducts();
      final fetchedUnits = await _apiService.getUnits();
      customers.value = await _apiService.getCustomers();
      categories.assignAll(fetchedCategories);
      soldItems.assignAll(fetchedSoldItems);
      products.assignAll(fetchedProducts);
      units.assignAll(fetchedUnits);
      print('Mahsulotlar: $fetchedProducts');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrlash va tartiblash bilan ma’lumotlarni yuklash
  Future<void> fetchFilteredAndSortedData() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getFilteredAndSortedProducts(
        unit: filterUnit.value.isNotEmpty ? filterUnit.value : null,
        minQuantity: filterMinQuantity.value,
        maxQuantity: filterMaxQuantity.value,
        startDate: filterStartDate.value,
        endDate: filterEndDate.value,
        minCostPrice: filterMinCostPrice.value,
        maxCostPrice: filterMaxCostPrice.value,
        minSellingPrice: filterMinSellingPrice.value,
        maxSellingPrice: filterMaxSellingPrice.value,
        sortColumn: sortColumn.value,
        ascending: sortAscending.value,
      );
      products.assignAll(response);
      print('Filtlangan va tartiblangan mahsulotlar: $response');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrlarni tozalash
  void clearFilters() {
    filterUnit.value = '';
    filterCategory.value = '';
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
    fetchData(); // Asl ma’lumotlarni qaytarish
  }

  // Yangi kategoriya qo‘shish
  Future<void> addCategory() async {
    if (newCategoryName.value.isEmpty) {
      Get.snackbar('Xato', 'Kategoriya nomini kiriting');
      return;
    }
    try {
      isLoading.value = true;
      await _apiService.addCategory(newCategoryName.value);
      newCategoryName.value = '';
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Yangi mahsulot qo‘shish
  Future<void> addProduct() async {
    if (newProductName.value.isEmpty ||
        newProductCategoryId.value.isEmpty ||
        newProductUnitId.value.isEmpty ||
        newProductQuantity.value < 0) {
      Get.snackbar('Xato', 'Barcha maydonlarni to‘g‘ri to‘ldiring (miqdor salbiy bo‘lmasligi kerak)');
      return;
    }
    try {
      isLoading.value = true;
      await _apiService.addProduct(
        newProductName.value,
        newProductCategoryId.value,
        newProductCostPrice.value,
        newProductUnitId.value,
        sellingPrice: newProductSellingPrice.value,
        quantity: newProductQuantity.value,
      );
      newProductName.value = '';
      newProductCategoryId.value = '';
      newProductCostPrice.value = 0.0;
      newProductSellingPrice.value = 0.0;
      newProductQuantity.value = 0.0;
      newProductUnitId.value = '';
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Kategoriyani tahrirlash
  Future<void> editCategory(String id, String newName) async {
    if (newName.isEmpty) {
      Get.snackbar('Xato', 'Yangi nomni kiriting');
      return;
    }
    try {
      isLoading.value = true;
      await _apiService.editCategory(id, newName);
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Kategoriyani o‘chirish
  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteCategory(id);
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Mahsulotni tahrirlash
  Future<void> editProduct(String id, String name, String categoryId, double costPrice, String unitId, {double? sellingPrice, double? quantity}) async {
    if (name.isEmpty || categoryId.isEmpty || unitId.isEmpty || (quantity != null && quantity < 0)) {
      Get.snackbar('Xato', 'Barcha maydonlarni to‘g‘ri to‘ldiring (miqdor salbiy bo‘lmasligi kerak)');
      return;
    }
    try {
      isLoading.value = true;
      await _apiService.editProduct(id, name, categoryId, costPrice, unitId, sellingPrice: sellingPrice, quantity: quantity);
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Mahsulotni o‘chirish
  Future<void> deleteProduct(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteProduct(id);
      await fetchData();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Xato', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Chiqish
  Future<void> signOut() async {
    try {
      await _apiService.signOut();
      Get.offAllNamed('/signup');
    } catch (e) {
      Get.snackbar('Xato', e.toString());
    }
  }

  // Kirish
  Future<void> handleSubmit(context) async {
    error.value = '';
    isLoading.value = true;
    try {
      await _apiService.signIn(context, 'torex.amaki@gmail.com', 'QAZZAQs!2');
    } catch (e) {
      error.value = 'Kirishda xato: $e';
      Get.snackbar('Xato', 'Kirishda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Parolni ko‘rsatish/yashirish
  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  // Ro‘yxatdan o‘tish sahifasiga o‘tish
  void goToSignUp() {
    Get.offAllNamed('/signup');
  }
}