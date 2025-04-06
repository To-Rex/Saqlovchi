import 'package:intl/intl.dart';

class ProductDisplayData {
  final String id;
  final String name;
  final String categoryName;
  final String costPrice;
  final String sellingPrice;
  final String unit;
  final String batchNumber;
  final String quantity;
  final double quantityValue;
  final bool isLowStock;
  final dynamic categoryId;
  final dynamic unitId;
  final String createdAt;
  final String createdBy;

  ProductDisplayData.fromProduct(Map<String, dynamic> product, List<dynamic> categories)
      : id = product['id']?.toString() ?? '',
        name = product['name'] ?? '',
        categoryName = categories.firstWhere((c) => c['id'] == product['category_id'], orElse: () => {'name': ''})['name'] ?? '',
        costPrice = product['cost_price']?.toString() ?? '0.0',
        sellingPrice = product['selling_price']?.toString() ?? '0.0',
        unit = product['units'] != null ? product['units']['name'] : '',
        batchNumber = (product['batches'] as List<dynamic>? ?? []).isNotEmpty ? product['batches'][0]['batch_number'] : 'Yo‘q',
        quantity = product['quantity']?.toString() ?? '0.0',
        quantityValue = (product['quantity'] as num?)?.toDouble() ?? 0.0,
        isLowStock = ((product['quantity'] as num?)?.toDouble() ?? 0.0) < 10,
        categoryId = product['category_id'],
        unitId = product['unit_id'] ?? (product['units'] != null ? product['units']['id'] : null),
        createdAt = product['created_at'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(product['created_at']).toLocal()) : 'Noma’lum',
        createdBy = product['created_by']?.toString() ?? 'Noma’lum';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId ?? '',
      'cost_price': double.tryParse(costPrice) ?? 0.0,
      'selling_price': double.tryParse(sellingPrice) ?? 0.0,
      'unit_id': unitId ?? '',
      'units': {'name': unit},
      'batches': batchNumber == 'Yo‘q' ? [] : [{'batch_number': batchNumber}],
      'quantity': double.tryParse(quantity) ?? 0.0,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}