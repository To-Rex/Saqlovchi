import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../libs/function/dialog_function.dart';
import '../../../libs/resource/colors.dart';
import '../../../models/product_display_data.dart';
import '../../../responsive.dart';


class RecentFiles extends StatelessWidget {
  RecentFiles({super.key});

  final GetController controller = Get.find<GetController>();
  static const Color lowStockColor = Colors.redAccent;
  static const double lowStockThreshold = 10.0;

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
            ? const Center(child: Text('Mahsulot topilmadi', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Barcha mahsulotlar", style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                  onPressed: () => DialogFunction().showFilterDialog(context),
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

  List<ProductDisplayData> _filterProducts(List<dynamic> products, String searchQuery, String filterUnit, String filterCategory) {
    var filtered = products
        .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .map((p) => ProductDisplayData.fromProduct(p, controller.categories));

    // Birlik bo‘yicha filtr
    if (filterUnit.isNotEmpty) {
      filtered = filtered.where((p) => p.unit == filterUnit);
    }

    // Kategoriya bo‘yicha filtr
    if (filterCategory.isNotEmpty) {
      filtered = filtered.where((p) => p.categoryName == filterCategory);
    }

    return filtered.toList();
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
      DataColumn(label: Text('Yaratilgan', style: columnStyle, textAlign: TextAlign.center)),
      DataColumn(label: Text('Amallar', style: columnStyle, textAlign: TextAlign.center)),
    ];
  }

  DataRow _buildTableRow(BuildContext context, ProductDisplayData product) {
    final textStyle = TextStyle(fontSize: 14, color: product.isLowStock ? lowStockColor : whiteColor);
    return DataRow(
      color: product.isLowStock ? WidgetStateProperty.all(lowStockColor.withOpacity(0.1)) : null,
      cells: [
        DataCell(Text(product.name, style: textStyle)),
        DataCell(Text(product.categoryName, style: textStyle)),
        DataCell(Text(product.costPrice, style: textStyle)),
        DataCell(Text(product.sellingPrice, style: textStyle)),
        DataCell(Text(product.unit, style: textStyle)),
        DataCell(Text(product.batchNumber, style: textStyle)),
        DataCell(Text(product.quantity, style: textStyle)),
        DataCell(Text(product.createdAt, style: textStyle)),
        DataCell(_buildActionButtons(context, product)),
      ],
    );
  }

  Widget _buildCardView(BuildContext context, List<ProductDisplayData> filteredProducts) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filteredProducts.length,
    itemBuilder: (context, index) {
      final product = filteredProducts[index];
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: product.isLowStock ? lowStockColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: product.isLowStock ? lowStockColor : whiteColor)),
                      _buildActionButtons(context, product)
                    ]),
                const SizedBox(height: 8),
                _buildInfoRow('Kategoriya', product.categoryName, product.isLowStock),
                _buildInfoRow('Narxi', '${product.costPrice} UZS', product.isLowStock),
                _buildInfoRow('Sotish Narxi', '${product.sellingPrice} UZS', product.isLowStock),
                _buildInfoRow('Birligi', product.unit, product.isLowStock),
                _buildInfoRow('Partiya', product.batchNumber, product.isLowStock),
                _buildInfoRow('Miqdor', product.quantity, product.isLowStock),
                _buildInfoRow('Yaratilgan Sana', product.createdAt, product.isLowStock),
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
        decoration: BoxDecoration(color: AppColors.blue.withAlpha(20), shape: BoxShape.circle),
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
        decoration: BoxDecoration(color: AppColors.red.withAlpha(20), shape: BoxShape.circle),
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

  Widget _buildInfoRow(String label, String value, bool isLowStock) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(value, style: TextStyle(fontSize: 14, color: isLowStock ? lowStockColor : whiteColor))
        ]),
  );
}