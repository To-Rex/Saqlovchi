import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/get_controller.dart';

import '../../function/dialog_function.dart';
import '../../resource/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GetController controller = Get.find<GetController>();
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image(image: const AssetImage('assets/images/logo.png'), height: 40),
                        const Text('Ombor Boshqaruvi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),)
                      ]
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => DialogFunction().showAddCategoryDialog(context, controller),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Yangi kategoriya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => DialogFunction().showAddProductDialog(context, controller),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Yangi mahsulot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Obx(
                      () => Row(
                    children: [
                      _buildStatCard(
                        title: 'Jami mahsulotlar',
                        value: controller.products.length.toString(),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.inventory,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        title: 'Kategoriyalar',
                        value: controller.categories.length.toString(),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.folder_open,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        title: 'Umumiy qiymat',
                        value:
                        '${controller.products.fold(0.0, (sum, p) => sum + (p['cost_price'] ?? 0.0)).toStringAsFixed(0)} UZS',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                      () => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategoriyalar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 16),
                        controller.categories.isEmpty
                            ? const Center(
                            child: Text('Kategoriyalar topilmadi', style: TextStyle(color: Colors.grey)))
                            : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: controller.categories.map((category) {
                            final creator = category['users'] ?? {};
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: isLargeScreen ? 260 : 200,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey.shade50],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            category['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.blue.withAlpha(20),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.edit, size: 18, color: Colors.blue[600]),
                                                onPressed: () => DialogFunction()
                                                    .showEditCategoryDialog(context, controller, category),
                                                padding: const EdgeInsets.all(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withAlpha(20),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.delete, size: 18, color: Colors.red[600]),
                                                onPressed: () => DialogFunction().showDeleteCategoryDialog(context, controller, category),
                                                padding: const EdgeInsets.all(4)
                                              )
                                            )
                                          ]
                                        )
                                      ]
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Qo‘shgan: ${creator['full_name'] ?? 'Noma\'lum'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                      () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mahsulotlar',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            SizedBox(
                              width: isLargeScreen ? 300 : 200,
                              child: TextField(
                                onChanged: (value) => controller.search.value = value,
                                decoration: InputDecoration(
                                  hintText: 'Mahsulotni qidirish...',
                                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProductsTable(context, controller, isLargeScreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required String title, required String value, required Gradient gradient, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            Icon(icon, size: 40, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, GetController controller, bool isLargeScreen) {
    final filteredProducts = controller.products
        .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(controller.search.value.toLowerCase()))
        .toList();

    return filteredProducts.isEmpty
        ? const Center(child: Text('Mahsulot topilmadi', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))))
        : SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Nomi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Kategoriya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Narxi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Sotish Narxi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Birligi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Partiya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Miqdor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
            DataColumn(label: Text('Amallar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center))
          ],
          rows: filteredProducts.map((product) {
            final category = controller.categories.firstWhere((c) => c['id'] == product['category_id'], orElse: () => {'name': 'Noma\'lum'});
            final unit = product['units'] != null ? product['units']['name'] : 'Noma\'lum';
            final batches = product['batches'] as List<dynamic>? ?? [];
            final batchNumber = batches.isNotEmpty ? batches[0]['batch_number'] : 'Yo‘q';

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    product['name'] ?? 'Noma\'lum',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    category['name'] ?? 'Noma\'lum',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    '${product['cost_price']?.toStringAsFixed(0) ?? 0} UZS',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    '${product['selling_price']?.toStringAsFixed(0) ?? 0} UZS',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    batchNumber,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Text(
                    product['quantity'].toStringAsFixed(0) ?? 'Noma\'lum',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                    textAlign: TextAlign.center
                  )
                ),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: AppColors.blue.withAlpha(20), shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(Icons.edit, size: 18, color: Colors.blue[600]),
                          onPressed: () => DialogFunction().showEditProductDialog(context, controller, product),
                          padding: const EdgeInsets.all(4)
                        )
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(color: AppColors.red.withAlpha(20), shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red[600]),
                          onPressed: () => DialogFunction().showDeleteProductDialog(context, controller, product),
                          padding: const EdgeInsets.all(4)
                        )
                      )
                    ]
                  )
                )
              ]
            );
          }).toList()
        )
      )
    );
  }
}