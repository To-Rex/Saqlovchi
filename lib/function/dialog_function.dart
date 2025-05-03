import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../controllers/get_controller.dart';
import '../companents/custom_toast.dart';
import '../controllers/api_service.dart';
import '../responsive.dart';

class DialogFunction {
  final GetController controller = Get.find<GetController>();

  // Umumiy tema uchun yordamchi metod
  Widget _applyDarkTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
        primaryColor: secondaryColor,
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF3B82F6),
          textTheme: ButtonTextTheme.normal,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          fillColor: bgColor,
          filled: true,
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        dialogTheme: DialogTheme(backgroundColor: bgColor),
      ),
      child: child,
    );
  }

  void showAddProductDialog(BuildContext context, GetController controller) {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController costPriceController = TextEditingController();
    final TextEditingController sellingPriceController = TextEditingController();
    int? selectedProductId;

    // Mahsulot ID’larini log qilish
    print('Mavjud mahsulotlar: ${controller.products.map((p) => {'id': p['id'], 'name': p['name'], 'code': p['code']}).toList()}');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor,
                secondaryColor.withOpacity(0.9),
                secondaryColor.withOpacity(0.7),
                Colors.black.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yangi mahsulot yoki partiya qo‘shish",
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Mavjud mahsulot (ixtiyoriy)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  dropdownColor: secondaryColor.withOpacity(0.9),
                  style: const TextStyle(color: Colors.white),
                  items: controller.products.map((product) {
                    return DropdownMenuItem<int>(
                      value: int.parse(product['id'].toString()),
                      child: Text(product['name']),
                    );
                  }).toList(),
                  value: selectedProductId,
                  onChanged: (value) {
                    selectedProductId = value;
                    if (value != null) {
                      final product = controller.products.firstWhere((p) => p['id'] == value);
                      productNameController.text = product['name'];
                      codeController.text = product['code']?.toString() ?? '';
                      controller.newProductName.value = product['name'];
                    } else {
                      productNameController.clear();
                      codeController.clear();
                      controller.newProductName.value = '';
                    }
                  },
                )),
                const SizedBox(height: 16),
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    labelText: 'Mahsulot nomi',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => controller.newProductName.value = value,
                  enabled: selectedProductId == null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Kod (shtrix-kod yoki ID, ixtiyoriy)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  enabled: selectedProductId == null,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Kategoriya',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  dropdownColor: secondaryColor.withOpacity(0.9),
                  style: const TextStyle(color: Colors.white),
                  items: controller.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: int.parse(category['id'].toString()),
                      child: Text(category['name']),
                    );
                  }).toList(),
                  value: controller.newProductCategoryId.value,
                  onChanged: selectedProductId == null
                      ? (value) => controller.newProductCategoryId.value = value
                      : null,
                )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Birlik',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  dropdownColor: secondaryColor.withOpacity(0.9),
                  style: const TextStyle(color: Colors.white),
                  items: controller.units.map((unit) {
                    return DropdownMenuItem<int>(
                      value: int.parse(unit['id'].toString()),
                      child: Text(unit['name']),
                    );
                  }).toList(),
                  value: controller.newProductUnitId.value,
                  onChanged: selectedProductId == null
                      ? (value) => controller.newProductUnitId.value = value
                      : null,
                )),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Miqdor (kg)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => controller.newProductQuantity.value = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: costPriceController,
                  decoration: InputDecoration(
                    labelText: 'Xarid narxi (so‘m)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => controller.newProductCostPrice.value = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sellingPriceController,
                  decoration: InputDecoration(
                    labelText: 'Sotuv narxi (so‘m)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => controller.newProductSellingPrice.value = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: 1.0,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Bekor qilish",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Responsive.getFontSize(context, baseSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: 1.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (productNameController.text.isEmpty && selectedProductId == null) {
                            CustomToast.show(
                              context: context,
                              title: 'Xatolik',
                              message: 'Mahsulot nomini kiriting yoki mavjud mahsulotni tanlang',
                              type: CustomToast.error,
                            );
                            return;
                          }
                          if (controller.newProductCategoryId.value == null) {
                            CustomToast.show(
                              context: context,
                              title: 'Xatolik',
                              message: 'Kategoriyani tanlang',
                              type: CustomToast.error,
                            );
                            return;
                          }
                          if (controller.newProductUnitId.value == null) {
                            CustomToast.show(
                              context: context,
                              title: 'Xatolik',
                              message: 'Birlikni tanlang',
                              type: CustomToast.error,
                            );
                            return;
                          }
                          if (controller.newProductQuantity.value <= 0) {
                            CustomToast.show(
                              context: context,
                              title: 'Xatolik',
                              message: 'Miqdor 0 dan katta bo‘lishi kerak',
                              type: CustomToast.error,
                            );
                            return;
                          }

                          try {
                            await controller.addProduct(
                              existingProductId: selectedProductId,
                              code: codeController.text.isEmpty ? null : codeController.text, // code parametri
                            );
                            Navigator.pop(context);
                            CustomToast.show(
                              context: context,
                              title: 'Muvaffaqiyat',
                              message: 'Mahsulot yoki partiya qo‘shildi',
                              type: CustomToast.success,
                            );
                          } catch (e) {
                            CustomToast.show(
                              context: context,
                              title: 'Xatolik',
                              message: 'Mahsulot/partiya qo‘shishda xato: $e',
                              type: CustomToast.error,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: Text(
                          "Qo‘shish",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showEditProductDialog(BuildContext context, GetController controller, Map<String, dynamic> product) {
    final batch = product['batches']?.isNotEmpty == true ? product['batches'][0] : {};
    TextEditingController nameController = TextEditingController(text: product['name']?.toString() ?? '');
    TextEditingController descriptionController =
    TextEditingController(text: product['description']?.toString() ?? '');
    TextEditingController costPriceController =
    TextEditingController(text: batch['cost_price']?.toString() ?? '0.0');
    TextEditingController sellingPriceController =
    TextEditingController(text: batch['selling_price']?.toString() ?? '0.0');
    TextEditingController quantityController =
    TextEditingController(text: batch['quantity']?.toString() ?? '0.0');
    TextEditingController batchNumberController =
    TextEditingController(text: batch['batch_number']?.toString() ?? '');
    String? categoryId = product['category_id']?.toString();
    String? unitId = product['unit_id']?.toString();

    showDialog(
      context: context,
      builder: (context) => _applyDarkTheme(
        context,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mahsulotni Tahrirlash',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nomi'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Tavsif (ixtiyoriy)'),
                ),
                const SizedBox(height: 16),
                Obx(
                      () => DropdownButtonFormField<int>(
                    value: categoryId != null &&
                        controller.categories.any((cat) => cat['id'].toString() == categoryId)
                        ? int.parse(categoryId!)
                        : controller.categories.isNotEmpty
                        ? controller.categories.first['id']
                        : null,
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'],
                        child: Text(cat['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => categoryId = value?.toString(),
                    decoration: const InputDecoration(labelText: 'Kategoriya'),
                    dropdownColor: bgColor,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                      () => DropdownButtonFormField<int>(
                    value: unitId != null &&
                        controller.units.any((unit) => unit['id'].toString() == unitId)
                        ? int.parse(unitId!)
                        : controller.units.isNotEmpty
                        ? controller.units.first['id']
                        : null,
                    items: controller.units.map((unit) {
                      return DropdownMenuItem<int>(
                        value: unit['id'],
                        child: Text(unit['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => unitId = value?.toString(),
                    decoration: const InputDecoration(labelText: 'Birlik'),
                    dropdownColor: bgColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: batchNumberController,
                  decoration: const InputDecoration(labelText: 'Partiya Raqami'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(labelText: 'Tannarx'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: sellingPriceController,
                        decoration: const InputDecoration(labelText: 'Sotish Narxi'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Miqdor'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor Qilish', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.editProduct(
                          product['id'].toString(),
                          nameController.text,
                          categoryId ?? controller.categories.first['id'].toString(),
                          double.tryParse(costPriceController.text) ?? 0.0,
                          unitId ?? controller.units.first['id'].toString(),
                          sellingPrice: double.tryParse(sellingPriceController.text),
                          quantity: double.tryParse(quantityController.text),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteProductDialog(BuildContext context, GetController controller, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: secondaryColor,
        title: Text(
          'Mahsulotni o‘chirish',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, baseSize: 18),
            color: Colors.white,
          ),
        ),
        content: Text(
          'Haqiqatan ham "${product['name']}" mahsulotini o‘chirmoqchimisiz?',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, baseSize: 16),
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 14),
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService().deleteProduct(product['id']);
                await controller.fetchInitialData();
                Navigator.pop(context);
                Get.snackbar(
                  'Muvaffaqiyat',
                  'Mahsulot o‘chirildi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Xatolik',
                  'Mahsulotni o‘chirishda xato: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'O‘chirish',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 14),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddCategoryDialog(BuildContext context, GetController controller) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _applyDarkTheme(
        context,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Yangi Kategoriya',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nomi'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Tavsif (ixtiyoriy)'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor Qilish', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        controller.newCategoryName.value = nameController.text;
                        await controller.addCategory();
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showEditCategoryDialog(BuildContext context, GetController controller, Map<String, dynamic> category) {
    TextEditingController nameController = TextEditingController(text: category['name']);
    TextEditingController descriptionController =
    TextEditingController(text: category['description']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => _applyDarkTheme(
        context,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kategoriyani Tahrirlash',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nomi'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Tavsif (ixtiyoriy)'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor Qilish', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.editCategory(category['id'].toString(), nameController.text);
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteCategoryDialog(BuildContext context, GetController controller, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => _applyDarkTheme(
        context,
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Kategoriyani O‘chirish',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text('“${category['name']}” kategoriyasini o‘chirishni xohlaysizmi? Bu amal qaytarilmaydi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor Qilish', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.deleteCategory(category['id'].toString());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              child: const Text('O‘chirish',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showCategoryDetailsDialog(BuildContext context, GetController controller, int categoryId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: secondaryColor,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.isMobile(context) ? double.infinity : 700,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: Responsive.getPadding(context, basePadding: const EdgeInsets.all(defaultPadding)),
          child: FutureBuilder<Map<String, dynamic>>(
            future: ApiService().getCategoryDetails(categoryId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('Snapshot xatosi: ${snapshot.error}');
                return Center(
                  child: Text(
                    'Ma\'lumotlarni yuklashda xato',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, baseSize: 16),
                      color: Colors.white70,
                    ),
                  ),
                );
              }
              final data = snapshot.data ?? {'category': null, 'products': []};
              final category = data['category'] ?? {
                'name': 'Noma’lum',
                'created_by': 'Noma’lum',
                'created_at': 'Noma’lum',
                'product_count': 0,
                'total_quantity': 0.0,
              };
              final products = data['products'] ?? [];

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategoriya ma'lumotlari
                    Container(
                      padding: EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, baseSize: 20),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: defaultPadding / 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildInfoRow(context, 'Yaratuvchi', category['created_by'])),
                              Expanded(child: _buildInfoRow(context, 'Yaratilgan', category['created_at'])),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildInfoRow(context, 'Mahsulotlar soni', category['product_count'].toString())),
                              Expanded(child: _buildInfoRow(context, 'Umumiy miqdor', '${category['total_quantity'].toStringAsFixed(2)} kg')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: defaultPadding),
                    // Mahsulotlar ro‘yxati
                    Text(
                      'Mahsulotlar',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, baseSize: 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: defaultPadding / 2),
                    products.isEmpty
                        ? Center(
                      child: Text(
                        'Bu kategoriyada mahsulotlar yo‘q',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 16),
                          color: Colors.white70,
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(vertical: defaultPadding / 2),
                          padding: EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [secondaryColor.withOpacity(0.9), secondaryColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, baseSize: 16),
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: defaultPadding / 4),
                                    Text(
                                      'Miqdor: ${product['quantity'].toStringAsFixed(2)} kg',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Narxi: ${product['cost_price'].toStringAsFixed(2)} UZS',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Sotish narxi: ${product['selling_price'].toStringAsFixed(2)} UZS',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Yaratilgan: ${product['created_at']}',
                                      style: TextStyle(
                                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 16, color: Colors.white),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    showAddProductDialog(context, controller);
                                  } else if (value == 'delete') {
                                    showDeleteProductDialog(context, controller, product);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 12, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Tahrirlash', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 12, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('O‘chirish', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
                                      ],
                                    ),
                                  ),
                                ],
                                color: secondaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Yopish',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: defaultPadding / 2),
                        ElevatedButton(
                          onPressed: () {
                            showAddProductDialog(context, controller);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                          ),
                          child: Text(
                            'Yangi mahsulot',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: defaultPadding / 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 14),
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 14),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    final unitController = TextEditingController(text: controller.filterUnit.value);
    final categoryController = TextEditingController(text: controller.filterCategory.value);
    final saleStatusController = TextEditingController(text: controller.filterSaleStatus.value);
    final minQuantityController =
    TextEditingController(text: controller.filterMinQuantity.value?.toString() ?? '');
    final maxQuantityController =
    TextEditingController(text: controller.filterMaxQuantity.value?.toString() ?? '');
    final minCostPriceController =
    TextEditingController(text: controller.filterMinCostPrice.value?.toString() ?? '');
    final maxCostPriceController =
    TextEditingController(text: controller.filterMaxCostPrice.value?.toString() ?? '');
    final minSellingPriceController =
    TextEditingController(text: controller.filterMinSellingPrice.value?.toString() ?? '');
    final maxSellingPriceController =
    TextEditingController(text: controller.filterMaxSellingPrice.value?.toString() ?? '');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Filtr va Tartiblash',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: whiteColor),
        ),
        content: Obx(() => SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategoriya Dropdown
                DropdownButtonFormField<String>(
                  value: controller.filterCategory.value.isEmpty
                      ? null
                      : controller.filterCategory.value,
                  decoration: InputDecoration(
                    labelText: 'Kategoriya',
                    labelStyle: TextStyle(color: whiteColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintStyle: TextStyle(color: whiteColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.category, color: primaryColor),
                  ),
                  dropdownColor: secondaryColor,
                  items: controller.categories
                      .map((category) => DropdownMenuItem<String>(
                    value: category['name'] as String,
                    child: Text(category['name'] as String,
                        style: TextStyle(color: whiteColor)),
                  ))
                      .toList(),
                  onChanged: (value) => controller.filterCategory.value = value ?? '',
                ),
                const SizedBox(height: defaultPadding),

                // Birlik Dropdown
                DropdownButtonFormField<String>(
                  value: controller.filterUnit.value.isEmpty ? null : controller.filterUnit.value,
                  decoration: InputDecoration(
                    labelText: 'Birlik',
                    labelStyle: TextStyle(color: whiteColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.category, color: primaryColor),
                  ),
                  dropdownColor: secondaryColor,
                  items: controller.units
                      .map((unit) => DropdownMenuItem<String>(
                    value: unit['name'] as String,
                    child:
                    Text(unit['name'] as String, style: TextStyle(color: whiteColor)),
                  ))
                      .toList(),
                  onChanged: (value) => controller.filterUnit.value = value ?? '',
                ),
                const SizedBox(height: defaultPadding),

                // Sotuv Holati Dropdown
                DropdownButtonFormField<String>(
                  value: controller.filterSaleStatus.value.isEmpty
                      ? null
                      : controller.filterSaleStatus.value,
                  decoration: InputDecoration(
                    labelText: 'Sotuv Holati',
                    labelStyle: TextStyle(color: whiteColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                  ),
                  dropdownColor: secondaryColor,
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text('Naqd', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(value: 'debt', child: Text('Qarzga', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'discount', child: Text('Chegirmali', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'debt_with_discount',
                        child: Text('Qarz va Chegirma', style: TextStyle(color: whiteColor))),
                  ],
                  onChanged: (value) => controller.filterSaleStatus.value = value ?? '',
                ),
                const SizedBox(height: defaultPadding),

                // Tugagan Mahsulotlar Checkbox
                CheckboxListTile(
                  title: Text('Faqat Tugagan Mahsulotlar', style: TextStyle(color: whiteColor)),
                  value: controller.filterOutOfStock.value,
                  onChanged: (value) => controller.filterOutOfStock.value = value ?? false,
                  activeColor: primaryColor,
                ),

                _buildSectionTitle('Miqdor'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.arrow_upward, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: TextField(
                        controller: maxQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Max',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.arrow_downward, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),

                _buildSectionTitle('Yaratilgan Sana'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    controller.filterStartDate.value != null
                        ? DateFormat('yyyy-MM-dd').format(controller.filterStartDate.value!)
                        : 'Sana (dan)',
                    style: TextStyle(color: whiteColor),
                  ),
                  trailing: Icon(Icons.calendar_today, color: primaryColor),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: primaryColor,
                            onPrimary: whiteColor,
                            surface: secondaryColor,
                            onSurface: whiteColor,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) controller.filterStartDate.value = picked;
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    controller.filterEndDate.value != null
                        ? DateFormat('yyyy-MM-dd').format(controller.filterEndDate.value!)
                        : 'Sana (gacha)',
                    style: TextStyle(color: whiteColor),
                  ),
                  trailing: Icon(Icons.calendar_today, color: primaryColor),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: primaryColor,
                            onPrimary: whiteColor,
                            surface: secondaryColor,
                            onSurface: whiteColor,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) controller.filterEndDate.value = picked;
                  },
                ),
                const SizedBox(height: defaultPadding),

                _buildSectionTitle('Tannarx'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCostPriceController,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: TextField(
                        controller: maxCostPriceController,
                        decoration: InputDecoration(
                          labelText: 'Max',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),

                _buildSectionTitle('Sotish Narxi'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minSellingPriceController,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.sell, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: TextField(
                        controller: maxSellingPriceController,
                        decoration: InputDecoration(
                          labelText: 'Max',
                          labelStyle: TextStyle(color: whiteColor),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: Icon(Icons.sell, color: primaryColor),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),

                _buildSectionTitle('Tartiblash'),
                DropdownButtonFormField<String>(
                  value: controller.sortColumn.value,
                  decoration: InputDecoration(
                    labelText: 'Ustun',
                    labelStyle: TextStyle(color: whiteColor),
                    filled: true,
                    fillColor: Colors.white.withAlpha(30),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.sort, color: primaryColor),
                  ),
                  dropdownColor: secondaryColor,
                  items: [
                    DropdownMenuItem(
                        value: 'name', child: Text('Nomi', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'quantity',
                        child: Text('Miqdor', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'cost_price',
                        child: Text('Tannarx', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'selling_price',
                        child: Text('Sotish Narxi', style: TextStyle(color: whiteColor))),
                    DropdownMenuItem(
                        value: 'created_at',
                        child: Text('Yaratilgan Sana', style: TextStyle(color: whiteColor))),
                  ],
                  onChanged: (value) => controller.sortColumn.value = value ?? 'created_at',
                ),
                SwitchListTile(
                  title: Text('O‘sish Tartibida', style: TextStyle(color: whiteColor)),
                  value: controller.sortAscending.value,
                  onChanged: (value) => controller.sortAscending.value = value,
                  activeColor: primaryColor,
                  inactiveThumbColor: darkGreyColor,
                ),
              ],
            ),
          ),
        )),
        actions: [
          ElevatedButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tozalash', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.filterMinQuantity.value = double.tryParse(minQuantityController.text);
              controller.filterMaxQuantity.value = double.tryParse(maxQuantityController.text);
              controller.filterMinCostPrice.value = double.tryParse(minCostPriceController.text);
              controller.filterMaxCostPrice.value = double.tryParse(maxCostPriceController.text);
              controller.filterMinSellingPrice.value =
                  double.tryParse(minSellingPriceController.text);
              controller.filterMaxSellingPrice.value =
                  double.tryParse(maxSellingPriceController.text);
              controller.fetchFilteredAndSortedData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Qo‘llash', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeIn),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        color: whiteColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

}