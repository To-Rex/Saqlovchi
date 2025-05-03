import 'package:get/get.dart';

class ProductDisplayData {
  final String id;
  final String name;
  final String categoryName;
  final String unit;
  final String costPrice;
  final String sellingPrice;
  final String batchNumber;
  final String quantity;
  final String saleStatus;
  final String createdAt;
  final bool isLowStock;

  ProductDisplayData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.batchNumber,
    required this.quantity,
    required this.saleStatus,
    required this.createdAt,
    required this.isLowStock,
  });

  factory ProductDisplayData.fromProduct(Map<String, dynamic> product, List<dynamic> categories) {
    final batches = product['batches'] as List<dynamic>? ?? [];
    final firstBatch = batches.isNotEmpty ? batches[0] : {};
    final quantity = batches.fold<double>(
      0.0,
          (sum, batch) => sum + ((batch['quantity'] as num?)?.toDouble() ?? 0.0),
    );
    final categoryId = product['category_id']?.toString() ?? '';
    final category = categories.firstWhereOrNull((c) => c['id'].toString() == categoryId) ?? {'name': 'Noma’lum'};

    return ProductDisplayData(
      id: product['id'].toString(),
      name: product['name']?.toString() ?? 'Noma’lum',
      categoryName: category['name']?.toString() ?? 'Noma’lum',
      unit: product['units']?['name']?.toString() ?? 'Noma’lum',
      costPrice: firstBatch['cost_price']?.toString() ?? '0',
      sellingPrice: firstBatch['selling_price']?.toString() ?? '0',
      batchNumber: firstBatch['batch_number']?.toString() ?? 'Noma’lum',
      quantity: quantity.toStringAsFixed(2),
      saleStatus: product['sales']?['sale_type']?.toString() ?? 'Noma’lum',
      createdAt: product['created_at']?.toString() ?? 'Noma’lum',
      isLowStock: quantity > 0 && quantity < 10.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_name': categoryName,
      'unit': unit,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'batch_number': batchNumber,
      'quantity': quantity,
      'sale_status': saleStatus,
      'created_at': createdAt,
    };
  }
}