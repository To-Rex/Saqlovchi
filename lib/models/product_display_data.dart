class ProductDisplayData {
  final int? productId; // int? sifatida o‘zgartirildi
  final String name;
  final String categoryName;
  final String quantity;
  final double costPrice;
  final double sellingPrice;
  final String unit;
  final String batchNumber;
  final String saleStatus;
  final String createdAt;
  final bool isLowStock;
  final String code;
  final double initialQuantity;
  final List<Map<String, dynamic>> batches;

  ProductDisplayData({
    required this.productId,
    required this.name,
    required this.categoryName,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.unit,
    required this.batchNumber,
    required this.saleStatus,
    required this.createdAt,
    required this.isLowStock,
    required this.code,
    required this.initialQuantity,
    required this.batches,
  });

  factory ProductDisplayData.fromProduct(dynamic product, List<dynamic> categories) {
    final batch = product['batches']?.isNotEmpty == true ? product['batches'][0] : null;
    final category = categories.firstWhere(
          (c) => c['id'] == product['category_id'],
      orElse: () => null,
    );
    final stockQuantity = product['stock_quantity']?.toDouble() ?? 0.0;
    final batchList = product['batches'] != null
        ? List<Map<String, dynamic>>.from(product['batches'])
        : <Map<String, dynamic>>[];

    return ProductDisplayData(
      productId: product['id'] != null ? int.tryParse(product['id'].toString()) : null, // Xavfsiz konvertatsiya
      name: product['name']?.toString() ?? 'Noma’lum',
      categoryName: category != null ? category['name']?.toString() ?? 'Noma’lum' : 'Noma’lum',
      quantity: stockQuantity.toStringAsFixed(2),
      costPrice: batch != null ? (batch['cost_price']?.toDouble() ?? 0.0) : 0.0,
      sellingPrice: batch != null ? (batch['selling_price']?.toDouble() ?? 0.0) : 0.0,
      unit: product['units']?['name']?.toString() ?? 'Noma’lum',
      batchNumber: batch != null ? (batch['batch_number']?.toString() ?? 'Noma’lum') : 'Noma’lum',
      saleStatus: stockQuantity == 0 ? 'Tugagan' : stockQuantity <= 10 ? 'Kam qoldi' : 'Yetarli',
      createdAt: product['created_at']?.toString().split('T').first ?? 'Noma’lum',
      isLowStock: stockQuantity > 0 && stockQuantity <= 10,
      code: product['code']?.toString() ?? '',
      initialQuantity: product['initial_quantity']?.toDouble() ?? 0.0,
      batches: batchList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': productId,
      'name': name,
      'category_name': categoryName,
      'quantity': quantity,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'unit': unit,
      'batch_number': batchNumber,
      'sale_status': saleStatus,
      'created_at': createdAt,
      'code': code,
      'initial_quantity': initialQuantity,
      'batches': batches,
    };
  }
}