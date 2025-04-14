import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';
import '../../../models/product_display_data.dart';
import '../../../responsive.dart';

class RecentFiles extends StatelessWidget {
  RecentFiles({super.key});

  final GetController controller = Get.find<GetController>();
  static const Color lowStockColor = Colors.redAccent;
  static const Color outOfStockColor = Colors.red;
  static const double lowStockThreshold = 10.0;

  List<ProductDisplayData> _filterProducts(
      List<dynamic> products, String searchQuery, String filterUnit, String filterCategory) {
    var filtered = products.where((p) => (p['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase())).map((p) => ProductDisplayData.fromProduct(p, controller.categories));

    if (filterUnit.isNotEmpty && controller.units.any((u) => u['name'] == filterUnit)) {
      filtered = filtered.where((p) => p.unit == filterUnit);
    }
    if (filterCategory.isNotEmpty &&
        controller.categories.any((c) => c['name'] == filterCategory)) {
      filtered = filtered.where((p) => p.categoryName == filterCategory);
    }

    return filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Obx(() {
        final filteredProducts = _filterProducts(
          controller.products,
          controller.search.value,
          controller.filterUnit.value,
          controller.filterCategory.value,
        );
        return filteredProducts.isEmpty
            ? const Center(
            child: Text('Mahsulot topilmadi',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Barcha mahsulotlar",
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                  onPressed: () => DialogFunction().showFilterDialog(context),
                  //onPressed: (){},
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Responsive(
              mobile: _buildCardView(context, filteredProducts),
              tablet: _buildTableView(context, filteredProducts),
              desktop: _buildTableView(context, filteredProducts),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableView(BuildContext context, List<ProductDisplayData> filteredProducts) {
    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: defaultPadding / 2,
                columns: _buildTableColumns(),
                rows: filteredProducts.map((product) => _buildTableRow(context, product)).toList(),
                dataRowHeight: 50,
                headingRowHeight: 56,
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    const columnStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreyColor);
    return const [
      DataColumn(label: Text('Nomi', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Kategoriya', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Narxi', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Sotish Narxi', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Birligi', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Partiya', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Miqdor', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Sotuv Holati', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Yaratilgan', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Amallar', style: columnStyle, textAlign: TextAlign.center)),
    ];
  }

  DataRow _buildTableRow(BuildContext context, ProductDisplayData product) {
    final isOutOfStock = product.quantity == '0';
    final textStyle = TextStyle(
      fontSize: 14,
      color: isOutOfStock
          ? outOfStockColor
          : product.isLowStock
          ? lowStockColor
          : whiteColor,
    );
    return DataRow(
      color: isOutOfStock
          ? WidgetStateProperty.all(outOfStockColor.withOpacity(0.2))
          : product.isLowStock
          ? WidgetStateProperty.all(lowStockColor.withOpacity(0.1))
          : null,
      cells: [
        DataCell(Text(product.name, style: textStyle)),
        DataCell(Text(product.categoryName, style: textStyle)),
        DataCell(Text(product.costPrice, style: textStyle)),
        DataCell(Text(product.sellingPrice, style: textStyle)),
        DataCell(Text(product.unit, style: textStyle)),
        DataCell(Text(product.batchNumber, style: textStyle)),
        DataCell(Text(product.quantity, style: textStyle)),
        DataCell(Text(product.saleStatus, style: textStyle)),
        DataCell(Text(product.createdAt, style: textStyle)),
        DataCell(_buildActionButtons(context, product)),
      ],
    );
  }

  Widget _buildCardView(BuildContext context, List<ProductDisplayData> filteredProducts) =>
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final isOutOfStock = product.quantity == '0';
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? outOfStockColor.withOpacity(0.2)
                      : product.isLowStock
                      ? lowStockColor.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? outOfStockColor
                                : product.isLowStock
                                ? lowStockColor
                                : whiteColor,
                          ),
                        ),
                        _buildActionButtons(context, product),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Kategoriya', product.categoryName, isOutOfStock, product.isLowStock),
                    _buildInfoRow('Narxi', '${product.costPrice} UZS', isOutOfStock, product.isLowStock),
                    _buildInfoRow('Sotish Narxi', '${product.sellingPrice} UZS', isOutOfStock, product.isLowStock),
                    _buildInfoRow('Birligi', product.unit, isOutOfStock, product.isLowStock),
                    _buildInfoRow('Partiya', product.batchNumber, isOutOfStock, product.isLowStock),
                    _buildInfoRow('Miqdor', product.quantity, isOutOfStock, product.isLowStock),
                    _buildInfoRow('Sotuv Holati', product.saleStatus, isOutOfStock, product.isLowStock),
                    _buildInfoRow('Yaratilgan Sana', product.createdAt, isOutOfStock, product.isLowStock),
                  ],
                ),
              ),
              if (index != filteredProducts.length - 1) Divider(color: greyColor, thickness: 1),
            ],
          );
        },
      );

  Widget _buildActionButtons(BuildContext context, ProductDisplayData product) => Row(
    children: [
      Container(
        decoration: BoxDecoration(color: Colors.blue.withAlpha(20), shape: BoxShape.circle),
        child: IconButton(
          icon: Icon(Icons.edit, size: 18, color: Colors.blue[600]),
          onPressed: () {
            final productMap = product.toMap();
            DialogFunction().showEditProductDialog(context, controller, productMap);
          },
          padding: const EdgeInsets.all(4),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(color: Colors.red.withAlpha(20), shape: BoxShape.circle),
        child: IconButton(
          icon: Icon(Icons.delete, size: 18, color: Colors.red[600]),
          onPressed: () {
            final productMap = product.toMap();
            DialogFunction().showDeleteProductDialog(context, controller, productMap);
          },
          padding: const EdgeInsets.all(4),
        ),
      ),
    ],
  );

  Widget _buildInfoRow(String label, String value, bool isOutOfStock, bool isLowStock) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isOutOfStock
                ? outOfStockColor
                : isLowStock
                ? lowStockColor
                : whiteColor,
          ),
        ),
      ],
    ),
  );
}