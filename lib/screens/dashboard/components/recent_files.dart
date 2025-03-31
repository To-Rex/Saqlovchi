import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../libs/function/dialog_function.dart';
import '../../../libs/resource/colors.dart';
import '../../../models/recent_file.dart';

class RecentFiles extends StatelessWidget {
  final GetController controller;
  const RecentFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    final filteredProducts = controller.products
        .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(controller.search.value.toLowerCase()))
        .toList();

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(color: secondaryColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Obx(() => controller.products.isEmpty ? const Center(child: Text('Mahsulot topilmadi', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)))) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_buildProductsTable(context, controller, false),
          Text(
            "Barcha mahsulotlar",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: const [
                DataColumn(label: Text('Nomi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Kategoriya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Narxi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Sotish Narxi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Birligi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Partiya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Miqdor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center)),
                DataColumn(label: Text('Amallar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.center))
              ], rows: filteredProducts.map((product) {
              final category = controller.categories.firstWhere((c) => c['id'] == product['category_id'], orElse: () => {'name': 'Noma\'lum'});
              final unit = product['units'] != null ? product['units']['name'] : 'Noma\'lum';
              final batches = product['batches'] as List<dynamic>? ?? [];
              final batchNumber = batches.isNotEmpty ? batches[0]['batch_number'] : 'Yo‘q';

              return DataRow(cells: [
                DataCell(Text(product['name'] ?? '')),
                DataCell(Text(category['name'] ?? '')),
                DataCell(Text(product['cost_price'] != null ? product['cost_price'].toString() : '0.0')),
                DataCell(Text(product['selling_price'] != null ? product['selling_price'].toString() : '0.0')),
                DataCell(Text(unit)),
                DataCell(Text(batchNumber)),
                DataCell(Text(product['quantity'] != null ? product['quantity'].toString() : '0.0')),
                DataCell(Row(
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
                  ],
                ))
              ]);
            }).toList()

            ),
          ),
        ],
      ))
    );
  }
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

DataRow recentFileDataRow(RecentFile fileInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgPicture.asset(
              fileInfo.icon!,
              height: 30,
              width: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(fileInfo.title!),
            ),
          ],
        ),
      ),
      DataCell(Text(fileInfo.date!)),
      DataCell(Text(fileInfo.size!)),
    ],
  );
}
