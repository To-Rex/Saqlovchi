class ProductDisplayData {
  final String name;
  final String categoryName;
  final String costPrice;
  final String sellingPrice;
  final String unit;
  final String batchNumber;
  final String quantity;
  final String saleStatus;
  final String createdAt;
  final bool isLowStock;

  ProductDisplayData({
    required this.name,
    required this.categoryName,
    required this.costPrice,
    required this.sellingPrice,
    required this.unit,
    required this.batchNumber,
    required this.quantity,
    required this.saleStatus,
    required this.createdAt,
    required this.isLowStock,
  });

  factory ProductDisplayData.fromProduct(Map<String, dynamic> product, List<dynamic> categories) {
    final batches = product['batches'] as List<dynamic>?;
    final latestBatch = batches != null && batches.isNotEmpty ? batches[0] : {};

    final quantity = latestBatch['quantity']?.toString() ?? '0';
    final costPrice = latestBatch['cost_price']?.toString() ?? '0';
    final sellingPrice = latestBatch['selling_price']?.toString() ?? '0';
    final batchNumber = latestBatch['batch_number']?.toString() ?? 'Noma’lum';
    final isLowStock = double.tryParse(quantity) != null && double.parse(quantity) <= 10.0 && double.parse(quantity) > 0;

    print('Mahsulot ma’lumatlari: name=${product['name']}, '
        'quantity=$quantity, costPrice=$costPrice, sellingPrice=$sellingPrice');

    return ProductDisplayData(
      name: product['name']?.toString() ?? 'Noma’lum',
      categoryName: product['categories']?['name']?.toString() ?? 'Noma’lum',
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      unit: product['units']?['name']?.toString() ?? 'Noma’lum',
      batchNumber: batchNumber,
      quantity: quantity,
      saleStatus: product['sales'] != null && (product['sales'] as List).isNotEmpty
          ? product['sales'][0]['sale_type']?.toString() ?? 'Noma’lum'
          : 'Sotilmagan',
      createdAt: product['created_at'] != null
          ? DateTime.parse(product['created_at']).toLocal().toString().substring(0, 16)
          : 'Noma’lum',
      isLowStock: isLowStock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category_name': categoryName,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'unit': unit,
      'batch_number': batchNumber,
      'quantity': quantity,
      'sale_status': saleStatus,
      'created_at': createdAt,
    };
  }
}