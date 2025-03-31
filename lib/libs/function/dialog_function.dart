import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import '../../controllers/get_controller.dart';

class DialogFunction {
  // Umumiy tema uchun yordamchi metod
  Widget _applyDarkTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor, // Dialog fon rangi
        primaryColor: secondaryColor,
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF3B82F6), // Tugmalar uchun asosiy rang
          textTheme: ButtonTextTheme.normal
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
          fillColor: bgColor, // TextField fon rangi dialog bilan bir xil
          filled: true,
          labelStyle: const TextStyle(color: Colors.white70),
        ), dialogTheme: DialogThemeData(backgroundColor: bgColor),
      ),
      child: child,
    );
  }

  void showAddProductDialog(BuildContext context, GetController controller) {
    TextEditingController nameController = TextEditingController();
    String? categoryId;
    TextEditingController costPriceController = TextEditingController();
    TextEditingController sellingPriceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    String? unitId;

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
                      'Yangi Mahsulot Qo‘shish',
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
                Obx(
                      () => DropdownButtonFormField<String>(
                    value: categoryId != null && controller.categories.any((cat) => cat['id'] == categoryId)
                        ? categoryId
                        : controller.categories.isNotEmpty
                        ? controller.categories.first['id'] as String
                        : null,
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'] as String,
                        child: Text(cat['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => categoryId = value,
                    decoration: const InputDecoration(labelText: 'Kategoriya'),
                    dropdownColor: bgColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(labelText: 'Narxi'),
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
                const SizedBox(height: 16),
                Obx(
                      () => DropdownButtonFormField<String>(
                    value: unitId != null && controller.units.any((unit) => unit['id'] == unitId)
                        ? unitId
                        : controller.units.isNotEmpty
                        ? controller.units.first['id'] as String
                        : null,
                    items: controller.units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit['id'] as String,
                        child: Text(unit['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => unitId = value,
                    decoration: const InputDecoration(labelText: 'Birlik'),
                    dropdownColor: bgColor,
                  ),
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
                        controller.newProductName.value = nameController.text;
                        controller.newProductCategoryId.value = categoryId ?? controller.categories.first['id'] as String;
                        controller.newProductCostPrice.value = double.tryParse(costPriceController.text) ?? 0.0;
                        controller.newProductSellingPrice.value = double.tryParse(sellingPriceController.text) ?? 0.0;
                        controller.newProductQuantity.value = double.tryParse(quantityController.text) ?? 0.0;
                        controller.newProductUnitId.value = unitId ?? controller.units.first['id'] as String;
                        await controller.addProduct();
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    TextEditingController nameController = TextEditingController(text: product['name']?.toString() ?? '');
    String? categoryId = product['category_id']?.toString();
    TextEditingController costPriceController = TextEditingController(text: product['cost_price']?.toString() ?? '0.0');
    TextEditingController sellingPriceController = TextEditingController(text: product['selling_price']?.toString() ?? '0.0');
    TextEditingController quantityController = TextEditingController(text: product['quantity']?.toString() ?? '0.0');
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
                Obx(
                      () => DropdownButtonFormField<String>(
                    value: categoryId != null && controller.categories.any((cat) => cat['id'] == categoryId)
                        ? categoryId
                        : controller.categories.isNotEmpty
                        ? controller.categories.first['id'] as String
                        : null,
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'] as String,
                        child: Text(cat['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => categoryId = value,
                    decoration: const InputDecoration(labelText: 'Kategoriya'),
                    dropdownColor: bgColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(labelText: 'Narxi'),
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
                const SizedBox(height: 16),
                Obx(
                      () => DropdownButtonFormField<String>(
                    value: unitId != null && controller.units.any((unit) => unit['id'] == unitId)
                        ? unitId
                        : controller.units.isNotEmpty
                        ? controller.units.first['id'] as String
                        : null,
                    items: controller.units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit['id'] as String,
                        child: Text(unit['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) => unitId = value,
                    decoration: const InputDecoration(labelText: 'Birlik'),
                    dropdownColor: bgColor,
                  ),
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
                          product['id'] as String,
                          nameController.text,
                          categoryId ?? controller.categories.first['id'] as String,
                          double.tryParse(costPriceController.text) ?? 0.0,
                          unitId ?? controller.units.first['id'] as String,
                          sellingPrice: double.tryParse(sellingPriceController.text),
                          quantity: double.tryParse(quantityController.text) ?? 0.0,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
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
      builder: (context) => _applyDarkTheme(
        context,
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Mahsulotni o‘chirish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text('“${product['name']}” ni o‘chirishni xohlaysizmi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.deleteProduct(product['id']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              child: const Text('O‘chirish', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showEditCategoryDialog(BuildContext context, GetController controller, Map<String, dynamic> category) {
    TextEditingController nameController = TextEditingController(text: category['name']);
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
                    const Text('Kategoriyani tahrirlash',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor qilish', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.editCategory(category['id'], nameController.text);
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
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
          title: const Text('Kategoriyani o‘chirish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text('“${category['name']}” kategoriyasini o‘chirishni xohlaysizmi? Bu amal qaytarilmaydi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.deleteCategory(category['id']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              child: const Text('O‘chirish', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showAddCategoryDialog(BuildContext context, GetController controller) {
    TextEditingController nameController = TextEditingController();
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
                    const Text('Yangi kategoriya',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor qilish', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        controller.newCategoryName.value = nameController.text;
                        await controller.addCategory();
                        Navigator.pop(context);
                      },
                      child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
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
}