import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../companents/custom_toast.dart';
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

//-----------------------------------------------------------------------------
  List<ProductDisplayData> _filterProducts(
      List<dynamic> products, String searchQuery, String filterUnit, String filterCategory) {
    final trimmedQuery = searchQuery.trim().toLowerCase();
    var filtered = products
        .where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final code = (p['code'] ?? '').toString().toLowerCase();
      final matchesName = name.contains(trimmedQuery);
      final matchesCode = code.contains(trimmedQuery);
      print('Mahsulot: ${p['name']}, code: ${p['code']}, matchesName: $matchesName, matchesCode: $matchesCode, query: $trimmedQuery');
      return matchesName || matchesCode;
    })
        .map((p) => ProductDisplayData.fromProduct(p, controller.categories))
        .toList();

    if (filterUnit.isNotEmpty && controller.units.any((u) => u['name'] == filterUnit)) {
      filtered = filtered.where((p) => p.unit == filterUnit).toList();
    }
    if (filterCategory.isNotEmpty &&
        controller.categories.any((c) => c['name'] == filterCategory)) {
      filtered = filtered.where((p) => p.categoryName == filterCategory).toList();
    }

    print('Qidirish natijalari: ${filtered.length} ta mahsulot topildi (query: $trimmedQuery), mahsulotlar: ${filtered.map((p) => {'name': p.name, 'code': p.code}).toList()}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.getPadding(context, basePadding: const EdgeInsets.all(defaultPadding / 2)),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Obx(() {
        final filteredProducts = _filterProducts(
          controller.products,
          controller.search.value,
          controller.filterUnit.value,
          controller.filterCategory.value,
        );
        return filteredProducts.isEmpty
            ? Center(
          child: Text(
            'Mahsulot topilmadi',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 14),
              color: Colors.white70,
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Barcha mahsulotlar",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: Responsive.getFontSize(context, baseSize: 18),
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined, color: Colors.white, size: 16),
                  onPressed: () => DialogFunction().showFilterDialog(context),
                ),
              ],
            ),
            SizedBox(height: defaultPadding / 2),
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
                columns: _buildTableColumns(context),
                rows: filteredProducts.map((product) => _buildTableRow(context, product)).toList(),
                dataRowHeight: 40,
                headingRowHeight: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataColumn> _buildTableColumns(BuildContext context) {
    final columnStyle = TextStyle(
      fontSize: Responsive.getFontSize(context, baseSize: 12),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return [
      DataColumn(label: Text('Nomi', style: columnStyle)),
      DataColumn(label: Text('Kategoriya', style: columnStyle)),
      DataColumn(label: Text('Narxi', style: columnStyle)),
      DataColumn(label: Text('Sotish Narxi', style: columnStyle)),
      DataColumn(label: Text('Miqdor', style: columnStyle)),
      DataColumn(label: Text('Birligi', style: columnStyle)),
      DataColumn(label: Text('Partiya', style: columnStyle)),
      DataColumn(label: Text('Sotuv Holati', style: columnStyle)),
      DataColumn(label: Text('Yaratilgan', style: columnStyle)),
      DataColumn(label: Text('Kod', style: columnStyle)),
      DataColumn(label: Text('Amallar', style: columnStyle)),
    ];
  }

  DataRow _buildTableRow(BuildContext context, ProductDisplayData product) {
    final isOutOfStock = product.quantity == '0';
    final textStyle = TextStyle(
      fontSize: Responsive.getFontSize(context, baseSize: 11),
      color: isOutOfStock
          ? outOfStockColor
          : product.isLowStock
          ? lowStockColor
          : Colors.white,
    );
    final batchDetails = product.batches.isNotEmpty
        ? product.batches.asMap().entries.map((entry) {
      final batch = entry.value;
      final quantity = (batch['quantity'] as num?)?.toDouble() ?? 0.0;
      final costPrice = (batch['cost_price'] as num?)?.toDouble() ?? 0.0;
      final sellingPrice = (batch['selling_price'] as num?)?.toDouble() ?? 0.0;
      final receivedDate = batch['received_date']?.toString().split('T').first ?? 'Noma’lum';
      return 'Partiya ${entry.key + 1}: Miqdor: $quantity kg, Xarid narxi: $costPrice so‘m, Sotish narxi: $sellingPrice so‘m, Yaratilgan: $receivedDate';
    }).join('\n')
        : 'Partiyalar mavjud emas';
    print('Tooltip ma‘lumotlari: product=${product.name}, batchDetails=$batchDetails');

    return DataRow(
      color: isOutOfStock
          ? WidgetStateProperty.all(outOfStockColor.withOpacity(0.2))
          : product.isLowStock
          ? WidgetStateProperty.all(lowStockColor.withOpacity(0.1))
          : null,
      cells: [
        DataCell(Text(product.name, style: textStyle)),
        DataCell(Text(product.categoryName, style: textStyle)),
        DataCell(Text('${product.costPrice} UZS', style: textStyle)),
        DataCell(Text('${product.sellingPrice} UZS', style: textStyle)),
        DataCell(
          Tooltip(
            message: batchDetails,
            child: Text(product.quantity, style: textStyle),
          ),
        ),
        DataCell(Text(product.unit, style: textStyle)),
        DataCell(Text(product.batchNumber, style: textStyle)),
        DataCell(Text(product.saleStatus, style: textStyle)),
        DataCell(Text(product.createdAt, style: textStyle)),
        DataCell(Text(product.code != '' ? product.code : 'Yo‘q', style: textStyle)),
        DataCell(_buildActionButtons(context, product)),
      ],
    );
  }

  Widget _buildCardView(BuildContext context, List<ProductDisplayData> filteredProducts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final isOutOfStock = product.quantity == '0';
        final batchDetails = product.batches.isNotEmpty
            ? product.batches.asMap().entries.map((entry) {
          final batch = entry.value;
          final quantity = (batch['quantity'] as num?)?.toDouble() ?? 0.0;
          final costPrice = (batch['cost_price'] as num?)?.toDouble() ?? 0.0;
          final sellingPrice = (batch['selling_price'] as num?)?.toDouble() ?? 0.0;
          final receivedDate = batch['received_date']?.toString().split('T').first ?? 'Noma’lum';
          return 'Partiya ${entry.key + 1}: Miqdor: $quantity kg, Xarid narxi: $costPrice so‘m, Sotish narxi: $sellingPrice so‘m, Yaratilgan: $receivedDate';
        }).join('\n')
            : 'Partiyalar mavjud emas';
        print('Tooltip ma‘lumotlari: product=${product.name}, batchDetails=$batchDetails');

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(vertical: defaultPadding / 2),
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isOutOfStock
                    ? outOfStockColor.withOpacity(0.3)
                    : product.isLowStock
                    ? lowStockColor.withOpacity(0.3)
                    : secondaryColor.withOpacity(0.8),
                secondaryColor.withOpacity(0.9),
              ],
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
          child: SingleChildScrollView(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 14),
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? outOfStockColor
                              : product.isLowStock
                              ? lowStockColor
                              : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kategoriya: ${product.categoryName}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Narxi: ${product.costPrice} UZS',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Sotish Narxi: ${product.sellingPrice} UZS',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Tooltip(
                        message: batchDetails,
                        child: Text(
                          'Miqdor: ${product.quantity} kg',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                            color: isOutOfStock
                                ? outOfStockColor
                                : product.isLowStock
                                ? lowStockColor
                                : Colors.white70,
                          ),
                        ),
                      ),
                      Text(
                        'Birligi: ${product.unit}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Partiya: ${product.batchNumber}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Sotuv Holati: ${product.saleStatus}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Yaratilgan: ${product.createdAt}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Kod: ${product.code != '' ? product.code : 'Yo‘q'}',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context, product),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildActionButtons(BuildContext context, ProductDisplayData product) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 14, color: Colors.white),
      onSelected: (value) {
        final productMap = product.toMap();
        if (value == 'edit') {
          DialogFunction().showEditProductDialog(context, controller, productMap);
        } else if (value == 'delete') {
          DialogFunction().showDeleteProductDialog(context, controller, productMap);
        } else if (value == 'add_batch') {
          if (product.productId == null) {
            print('Xato: productId null, product=${product.name}');
            CustomToast.show(
              context: context,
              title: 'Xatolik',
              message: 'Mahsulot ID topilmadi',
              type: CustomToast.error,
            );
            return;
          }
          print('Mahsulot qo‘shish tanlandi: productId=${product.productId}, name=${product.name}');
          DialogFunction().showAddProductDialog(context, controller, existingProductId: product.productId);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'add_batch',
          child: Row(
            children: [
              Icon(Icons.add_circle, size: 12, color: Colors.green),
              SizedBox(width: 6),
              Text('Mahsulot qo‘shish', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 12, color: Colors.blue),
              SizedBox(width: 6),
              Text('Tahrirlash', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 12, color: Colors.red),
              SizedBox(width: 6),
              Text('O‘chirish', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
            ],
          ),
        )
      ],
      color: secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }


}