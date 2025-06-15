import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/sales_screen_controller.dart';
import '../../companents/custom_toast.dart';
import '../../controllers/get_controller.dart';
import '../../responsive.dart';
import '../dashboard/components/header.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesScreenController());

    controller.preloadBatchData();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor,
              secondaryColor.withOpacity(0.9),
              secondaryColor.withOpacity(0.7),
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Responsive(
            mobile: _buildMobileLayout(context, controller),
            tablet: _buildTabletLayout(context, controller),
            desktop: _buildDesktopLayout(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SalesScreenController controller) {
    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context, controller),
        Expanded(
          child: Row(
            children: [
              _buildCategoryList(context, controller, width: 160),
              Expanded(child: _buildProductGrid(context, controller)),
              _buildSalePanel(context, controller, width: 320)
            ]
          )
        ),
        _buildRecentSales(context, controller)
      ]
    );
  }

  Widget _buildTabletLayout(BuildContext context, SalesScreenController controller) {
    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context, controller),
        Expanded(
          child: Row(
            children: [
              _buildCategoryList(context, controller, width: 130),
              Expanded(child: _buildProductGrid(context, controller)),
              _buildSalePanel(context, controller, width: 280),
            ],
          ),
        ),
        _buildRecentSales(context, controller),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SalesScreenController controller) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                _buildHeader(context),
                _buildSearchBar(context, controller, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))
              ]
            )
          ),
          expandedHeight: 140
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildCategoryList(context, controller, isHorizontal: true, height: 50),
              _buildProductGrid(context, controller, maxCrossAxisExtent: 140, childAspectRatio: 1.4, height: 360),
              _buildSalePanel(context, controller, width: double.infinity, padding: const EdgeInsets.all(12)),
              _buildRecentSales(context, controller)
            ]
          )
        )
      ]
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: Responsive.getPadding(context, basePadding: const EdgeInsets.all(12)),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Sotuv", style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 26), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
          ProfileCard(),
        ],
      ),
    );
  }


  Widget _buildSearchBar(BuildContext context, SalesScreenController controller, {EdgeInsets padding = const EdgeInsets.all(12)}) {
    return Padding(
      padding: Responsive.getPadding(context, basePadding: padding),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Nomi yoki kodi bo‘yicha qidirish', // Hint matni yaxshilandi
          hintStyle: TextStyle(color: Colors.white70, fontSize: Responsive.getFontSize(context, baseSize: 16)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 24),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)
        ),
        style: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 16)),
        onChanged: (value) {
          controller.searchQuery.value = value.trim().toLowerCase();
          print('SalesScreen SearchField: Yangi qidirish qiymati: ${controller.searchQuery.value}');
        },
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, SalesScreenController controller, {double width = 160, bool isHorizontal = false, double height = 400}) {
    return Container(
      width: isHorizontal ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Obx(() => isHorizontal
          ? SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryItem(context, controller, null, "Barchasi"),
            ...controller.appController.categories.map((category) => _buildCategoryItem(context, controller, category['id'].toString(), category['name'])
            )
          ]
        )
      ) : ListView.builder(
        scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
        itemCount: controller.appController.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryItem(
              context,
              controller,
              null,
              "Barchasi",
            );
          }
          final category = controller.appController.categories[index - 1];
          return _buildCategoryItem(
            context,
            controller,
            category['id'].toString(),
            category['name'],
          );
        },
      )),
    );
  }

  Widget _buildCategoryItem(BuildContext context, SalesScreenController controller, String? id, String name) {
    return GestureDetector(
      onTap: () => controller.selectCategory(id),
      child: Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: controller.selectedCategoryId.value == id ? primaryColor.withOpacity(0.9) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
            ]
          ),
          child: Text(
            name,
            style: TextStyle(
              color: controller.selectedCategoryId.value == id ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.getFontSize(context, baseSize: 15)
            )
          )
        )
      )
    );
  }

  Widget _buildProductGrid(BuildContext context, SalesScreenController controller, {double maxCrossAxisExtent = 180, double childAspectRatio = 1.5, double height = 400}) {
    return Obx(() {
      final filteredProducts = controller.selectedCategoryId.value == null
          ? controller.appController.products
          : controller.appController.products
          .where((p) => p['category_id'].toString() == controller.selectedCategoryId.value)
          .toList();

      final searchedProducts = filteredProducts.where((p) =>
      (p['name']?.toString().toLowerCase() ?? '').contains(controller.searchQuery.value) ||
          (p['code']?.toString().toLowerCase() ?? '').contains(controller.searchQuery.value)).toList();

      print('SalesScreen Qidirish natijalari: ${searchedProducts.length} ta mahsulot topildi (query: ${controller.searchQuery.value}), mahsulotlar: ${searchedProducts.map((p) => {'name': p['name'], 'code': p['code']}).toList()}');

      if (controller.isStockLoading.value) {
        return const Center(child: CircularProgressIndicator(color: primaryColor));
      }

      return searchedProducts.isEmpty
          ? Center(
        child: Text("Mahsulot topilmadi", style: TextStyle(color: Colors.white70, fontSize: Responsive.getFontSize(context, baseSize: 16))),
      )
          : SizedBox(
        height: height,
        child: GridView.builder(
          padding: Responsive.getPadding(
            context,
            basePadding: const EdgeInsets.all(12),
          ),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: searchedProducts.length,
          itemBuilder: (context, index) {
            final product = searchedProducts[index];
            return FutureBuilder<double>(
              future: controller.apiService.getStockQuantity(product['id'].toString()), // ApiService’dan qoldiq olish
              builder: (context, snapshot) {
                double stockQuantity = snapshot.data ?? 0.0;
                Color borderColor = Colors.transparent;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  print('Qoldiq olishda xato: ${snapshot.error}');
                  stockQuantity = 0.0;
                }

                if (stockQuantity == 0) {
                  borderColor = Colors.red;
                } else if (stockQuantity <= 10) {
                  borderColor = Colors.yellow;
                }

                // Partiyalar uchun tooltip
                final batches = controller.batchCache.entries
                    .where((entry) => entry.value['product_id'] == product['id'].toString())
                    .toList()
                  ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

                final firstBatchPrice = batches.isNotEmpty ? (batches.first.value['cost_price'] as double) + (batches.first.value['selling_price'] as double) : 0.0;

                final batchDetails = batches.isNotEmpty
                    ? batches.asMap().entries.map((entry) {
                  final batch = entry.value.value;
                  final batchNumber = batch['batch_number'] as String;
                  final quantity = batch['quantity'] as double;
                  final price = (batch['cost_price'] as double) + (batch['selling_price'] as double);
                  return 'Partiya ${entry.key + 1} ($batchNumber): $quantity kg, ${GetController().getMoneyFormat(price)} so‘m/kg';
                }).join('\n')
                    : 'Partiyalar mavjud emas';

                return GestureDetector(
                  onTap: () => controller.selectProduct(product['id'].toString(), 1.0),
                  child: Tooltip(
                    message: batchDetails,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                    textStyle: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 12)),
                    padding: const EdgeInsets.all(8),
                    preferBelow: true,
                    child: Obx(() => AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: controller.selectedProductId.value == product['id'].toString() ? 0.95 : 1.0,
                      child: Card(
                        elevation: 3,
                        color: controller.selectedProductId.value == product['id'].toString() ? primaryColor.withOpacity(0.9) : Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: borderColor, width: 2)),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  product['name'] ?? 'Noma’lum',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product['code'] != null && product['code'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Kod: ${product['code']}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Responsive.getFontSize(context, baseSize: 11),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                "Narx: ${GetController().getMoneyFormat(firstBatchPrice)} so‘m",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.getFontSize(context, baseSize: 11),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Qoldiq: ${stockQuantity.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: borderColor == Colors.transparent ? Colors.white70 : borderColor,
                                  fontSize: Responsive.getFontSize(context, baseSize: 11),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildSalePanel(
      BuildContext context, SalesScreenController controller,
      {double width = 320,
        EdgeInsets padding = const EdgeInsets.all(12),
        double? height}) {
    return Container(
      width: width,
      height: height,
      padding: Responsive.getPadding(context, basePadding: padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sotish",
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              if (controller.selectedProductId.value != null &&
                  controller.selectedBatchIds.isNotEmpty) ...[
                Text(
                  "Tanlangan: ${controller.appController.products.firstWhere((p) => p['id'].toString() == controller.selectedProductId.value, orElse: () => {'name': 'Noma’lum'},)['name']}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 15),
                  ),
                ),
                const SizedBox(height: 8),
                if (controller.cachedStockQuantity.value != null) ...[
                  Builder(
                    builder: (context) {
                      final stockQuantity =
                          controller.cachedStockQuantity.value ?? 0.0;
                      Color quantityColor = stockQuantity == 0
                          ? Colors.red
                          : stockQuantity <= 10
                          ? Colors.yellow
                          : Colors.white70;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Omborda qoldiq: ${stockQuantity.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: quantityColor,
                              fontSize:
                              Responsive.getFontSize(context, baseSize: 13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (stockQuantity == 0)
                            Text(
                              "Mahsulot omborda mavjud emas",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                Responsive.getFontSize(context, baseSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
              ],
              _buildQuantityInput(context, controller),
              const SizedBox(height: 12),
              _buildPriceInput(context, controller),
              const SizedBox(height: 12),
              _buildPriceSummary(context, controller),
              const SizedBox(height: 12),
              _buildAdvancedOptionsToggle(context, controller),
              if (controller.showCreditOptions.value ||
                  controller.showDiscountOption.value) ...[
                const SizedBox(height: 12),
                if (controller.showCreditOptions.value)
                  _buildCreditOptions(context, controller),
                if (controller.showDiscountOption.value)
                  _buildDiscountInput(context, controller),
              ],
              const SizedBox(height: 16),
              // “Tan narxiga sotish” tugmasi
              Obx(() => AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: controller.isSelling.value ? 0.95 : 1.0,
                  child: ElevatedButton(
                    onPressed: (controller.selectedProductId.value == null ||
                        controller.selectedBatchIds.isEmpty ||
                        controller.quantity.value <= 0 ||
                        controller.isSelling.value ||
                        controller.cachedStockQuantity.value == null ||
                        controller.cachedStockQuantity.value == 0)
                        ? null : () {
                      //controller.sellAtCostPrice(context)
                      //dialog ochiladi
                      showDialog(
                        context: context,
                        builder: (context) {
                          final selectedProduct = controller.appController.products.firstWhere(
                                (p) => p['id'].toString() == controller.selectedProductId.value,
                            orElse: () => null,
                          );

                          double costPrice = 0.0;
                          double quantity = controller.quantity.value;

                          final batches = controller.batchCache.entries
                              .where((entry) => entry.value['product_id'] == controller.selectedProductId.value)
                              .toList()
                            ..sort((a, b) => DateTime.parse(a.value['received_date']).compareTo(DateTime.parse(b.value['received_date'])));

                          if (batches.isNotEmpty) {
                            final batch = batches.first;
                            costPrice = (batch.value['cost_price'] as double?) ?? 0.0;
                          }

                          double totalCost = quantity * costPrice;

                          return AlertDialog(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text(
                              "Diqqat!",
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(context, baseSize: 18),
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tan narxiga sotishni tasdiqlaysizmi?",
                                  style: TextStyle(
                                    fontSize: Responsive.getFontSize(context, baseSize: 16),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (selectedProduct != null)
                                  Text(
                                    "🧾 Mahsulot: ${selectedProduct['name']}",
                                    style: TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                Text(
                                  "⚖️ Miqdor: ${quantity.toStringAsFixed(2)} kg",
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                Text(
                                  "💰 Tan narx: ${quantity.toStringAsFixed(2)} x ${GetController().getMoneyFormat(costPrice)} = ${GetController().getMoneyFormat(totalCost)} so‘m",
                                  style: TextStyle(fontSize: 14, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  "Tan narxiga sotish",
                                  style: TextStyle(
                                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () => controller.sellAtCostPrice(context),
                              ),
                            ],
                          );
                        },

                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: controller.isSelling.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ) : Text(
                      "Tan narxiga sotish",
                      style: TextStyle(
                        fontSize:
                        Responsive.getFontSize(context, baseSize: 16),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // “Sotish” tugmasi (umumiy narx uchun)
              Obx(() => AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: controller.isSelling.value ? 0.95 : 1.0,
                  child: ElevatedButton(
                    onPressed: (controller.selectedProductId.value == null ||
                        controller.selectedBatchIds.isEmpty ||
                        controller.quantity.value <= 0 ||
                        controller.isSelling.value ||
                        controller.cachedStockQuantity.value == null ||
                        controller.cachedStockQuantity.value == 0)
                        ? null
                        : () => controller.sellProduct(context), // Umumiy narxga sotish
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: controller.isSelling.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "Sotish",
                      style: TextStyle(
                        fontSize:
                        Responsive.getFontSize(context, baseSize: 16),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRecentSales(
      BuildContext context,
      SalesScreenController controller,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: Responsive.getPadding(
        context,
        basePadding: const EdgeInsets.all(10),
      ),
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Oxirgi sotuvlar",
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => FutureBuilder<List<dynamic>>(
            future: controller.recentSalesFuture.value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  "Xato: ${snapshot.error}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                  ),
                );
              }
              final recentSales = snapshot.data ?? [];
              return Column(
                children: [
                  ...recentSales.map((sale) {
                    bool hasMarkup = false;
                    bool hasDebt = ((sale['paid_amount'] as num?)?.toDouble() ?? 0.0) <
                        ((sale['total_amount'] as num?)?.toDouble() ?? 0.0);
                    bool hasDiscount = ((sale['discount_amount'] as num?)?.toDouble() ?? 0.0) > 0;

                    if (sale['sale_items'] != null && sale['sale_items'].isNotEmpty) {
                      for (var item in sale['sale_items']) {
                        final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                        final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
                        final totalPrice = (item['total_price'] as num?)?.toDouble() ?? 0.0;
                        if (totalPrice > unitPrice * quantity) {
                          hasMarkup = true;
                          break;
                        }
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sale['sale_items'] != null &&
                                            sale['sale_items'].isNotEmpty &&
                                            sale['sale_items'][0]['batches'] != null &&
                                            sale['sale_items'][0]['batches']['products'] != null
                                            ? sale['sale_items'][0]['batches']['products']['name'] ?? 'Noma’lum mahsulot'
                                            : 'Noma’lum mahsulot',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.getFontSize(context, baseSize: 13),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (sale['sale_type'] == 'returned')
                                        Text(
                                          "Qaytarildi",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: Responsive.getFontSize(context, baseSize: 11),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (hasMarkup)
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.yellow,
                                    size: 16,
                                  ),
                                const SizedBox(width: 6),
                                if (hasDebt)
                                  const Icon(
                                    Icons.credit_card,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                if (hasDiscount)
                                  const Icon(
                                    Icons.discount,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${GetController().getMoneyFormat(sale['total_amount'].toString())} so‘m',
                                style: TextStyle(color: Colors.white70, fontSize: Responsive.getFontSize(context, baseSize: 13))
                              ),
                              const SizedBox(width: 6),
                              if (sale['sale_type'] != 'returned')
                                IconButton(
                                  icon: const Icon(Icons.undo, color: Colors.orange, size: 16),
                                  tooltip: 'Qaytarish',
                                  onPressed: controller.isSelling.value ? null : () => controller.returnProduct(context, sale['id'])
                                )
                            ]
                          )
                        ]
                      )
                    );
                  }),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAllSalesDialog(context, controller),
                    child: Text(
                      "Barchasini ko‘rish",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          )),
        ],
      ),
    );
  }

  void _showAllSalesDialog(BuildContext context, SalesScreenController controller) {
    final TextEditingController searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
    final RxString selectedStatus = 'all'.obs;
    final RxString sortOrder = 'newest'.obs;
    final Rx<DateTime?> startDate = Rx<DateTime?>(null);
    final Rx<DateTime?> endDate = Rx<DateTime?>(null);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 16),
        child: Container(
          width: Responsive.isMobile(context)
              ? double.infinity
              : MediaQuery.of(context).size.width * 0.9,
          height: Responsive.isMobile(context)
              ? MediaQuery.of(context).size.height - 32
              : MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor,
                secondaryColor.withOpacity(0.9),
                secondaryColor.withOpacity(0.7),
                Colors.black.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Barcha sotuvlar",
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, baseSize: 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Mahsulot bo‘yicha qidirish',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: Responsive.getFontSize(context, baseSize: 14),
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                  ),
                  onChanged: (value) => searchQuery.value = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                            () => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          value: selectedStatus.value,
                          dropdownColor: Colors.black.withOpacity(0.9),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Barchasi')),
                            DropdownMenuItem(value: 'returned', child: Text('Qaytarilgan')),
                            DropdownMenuItem(value: 'debt', child: Text('Qarzga sotilgan')),
                            DropdownMenuItem(value: 'discount', child: Text('Chegirmali')),
                            DropdownMenuItem(value: 'cash', child: Text('Naqd')),
                          ],
                          onChanged: (value) {
                            if (value != null) selectedStatus.value = value;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                            () => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Saralash',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          value: sortOrder.value,
                          dropdownColor: Colors.black.withOpacity(0.9),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Eng yangi')),
                            DropdownMenuItem(value: 'oldest', child: Text('Eng eski')),
                          ],
                          onChanged: (value) {
                            if (value != null) sortOrder.value = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                            () => ElevatedButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: startDate.value ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                      surface: Colors.black,
                                      onSurface: Colors.white70,
                                    ),
                                    dialogBackgroundColor: Colors.black.withOpacity(0.9),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate != null) {
                              startDate.value = selectedDate;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            startDate.value == null
                                ? 'Boshlang‘ich sana'
                                : 'Boshlang‘ich: ${controller.apiService.formatDate(startDate.value!.toIso8601String())}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                            () => ElevatedButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate.value ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                      surface: Colors.black,
                                      onSurface: Colors.white70,
                                    ),
                                    dialogBackgroundColor: Colors.black.withOpacity(0.9),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate != null) {
                              endDate.value = selectedDate;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            endDate.value == null
                                ? 'Oxirgi sana'
                                : 'Oxirgi: ${controller.apiService.formatDate(endDate.value!.toIso8601String())}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() => FutureBuilder<List<dynamic>>(
                    future: controller.apiService.getAllSalesDetails(
                      searchQuery: searchQuery.value,
                      status: selectedStatus.value,
                      startDate: startDate.value,
                      endDate: endDate.value,
                      sortOrder: sortOrder.value,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Xato: ${snapshot.error}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                            ),
                          ),
                        );
                      }
                      final allSales = snapshot.data ?? [];
                      if (allSales.isEmpty) {
                        return Center(
                          child: Text(
                            "Sotuvlar mavjud emas",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        itemCount: allSales.length,
                        itemBuilder: (context, index) {
                          final sale = allSales[index];
                          bool hasMarkup = false;
                          bool hasDebt = ((sale['paid_amount'] as num?)?.toDouble() ?? 0.0) <
                              ((sale['total_amount'] as num?)?.toDouble() ?? 0.0);
                          bool hasDiscount = ((sale['discount_amount'] as num?)?.toDouble() ?? 0.0) > 0;
                          final items = sale['sale_items'] as List<dynamic>? ?? [];

                          for (var item in items) {
                            final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                            final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
                            final totalPrice = (item['total_price'] as num?)?.toDouble() ?? 0.0;
                            if (totalPrice > unitPrice * quantity) {
                              hasMarkup = true;
                              break;
                            }
                          }

                          return ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items.isNotEmpty
                                            ? items[0]['batches']['products']['name'] ?? 'Noma’lum mahsulot'
                                            : 'Noma’lum mahsulot',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.getFontSize(context, baseSize: 14),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        sale['sale_date'] != null
                                            ? controller.apiService.formatDate(sale['sale_date'])
                                            : 'Noma’lum vaqt',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        ),
                                      ),
                                      if (sale['sale_type'] == 'returned')
                                        Text(
                                          "Qaytarildi",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${GetController().getMoneyFormat(sale['total_amount'].toString())} so‘m',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (hasMarkup)
                                      const Icon(Icons.attach_money, color: Colors.yellow, size: 18),
                                    if (hasDebt)
                                      const Icon(Icons.credit_card, color: Colors.redAccent, size: 18),
                                    if (hasDiscount)
                                      const Icon(Icons.discount, color: Colors.greenAccent, size: 18),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mijoz: ${sale['customer_name'] ?? 'Noma’lum'}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Umumiy narx: ${GetController().getMoneyFormat(sale['total_amount'].toString())} so‘m',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    Text(
                                      'Chegirma: ${GetController().getMoneyFormat(sale['discount_amount'].toString())} so‘m',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    Text(
                                      'To‘langan: ${GetController().getMoneyFormat(sale['paid_amount'].toString())} so‘m',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    Text(
                                      'Qoldiq qarz: ${GetController().getMoneyFormat(((sale['total_amount'] as num?)?.toDouble() ?? 0.0) - ((sale['paid_amount'] as num?)?.toDouble() ?? 0.0))} so‘m',
                                      style: TextStyle(
                                        color: hasDebt ? Colors.redAccent : Colors.greenAccent,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Mahsulotlar:",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (items.isEmpty)
                                      Text(
                                        "Mahsulotlar haqida ma‘lumot yo‘q",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        ),
                                      ),
                                    ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                      child: Text(
                                        '${item['batches']['products']['name'] ?? 'Noma’lum'}: ${item['quantity'] ?? 0} x ${GetController().getMoneyFormat(item['unit_price'].toString())} = ${GetController().getMoneyFormat(item['total_price'].toString())}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        ),
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                    if (sale['comments'] != null && sale['comments'].isNotEmpty)
                                      Text(
                                        "Izoh: ${sale['comments']}",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (sale['sale_type'] == 'debt' || sale['sale_type'] == 'debt_with_discount')
                                          IconButton(
                                            icon: const Icon(Icons.payment, color: Colors.blueAccent, size: 18),
                                            tooltip: 'To‘lash',
                                            onPressed: controller.isSelling.value
                                                ? null
                                                : () => _showPaymentDialog(context, controller, sale),
                                          ),
                                        if (sale['sale_type'] != 'returned')
                                          IconButton(
                                            icon: const Icon(Icons.undo, color: Colors.orangeAccent, size: 18),
                                            tooltip: 'Qaytarish',
                                            onPressed: controller.isSelling.value
                                                ? null
                                                : () async {
                                              await controller.returnProduct(context, sale['id']);
                                              Navigator.pop(context);
                                              controller.recentSalesFuture.value =
                                                  controller.apiService.getRecentSales(limit: 2);
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(
      BuildContext context,
      SalesScreenController controller,
      Map<String, dynamic> sale,
      ) {
    final TextEditingController paymentController = TextEditingController();
    final remainingDebt =
        ((sale['total_amount'] as num?)?.toDouble() ?? 0.0) - ((sale['paid_amount'] as num?)?.toDouble() ?? 0.0);
    final items = sale['sale_items'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          'Qarzni to‘lash (Sotuv ID: ${sale['id']})',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mijoz: ${sale['customer_name'] ?? 'Noma’lum'}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jami qarz: ${GetController().getMoneyFormat(remainingDebt.toString())}',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mahsulotlar:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (items.isEmpty)
                Text(
                  'Mahsulotlar haqida ma‘lumot yo‘q',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                ),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Text(
                  '${item['batches']['products']['name'] ?? 'Noma’lum'}: ${item['quantity'] ?? 0} x ${GetController().getMoneyFormat(item['unit_price'].toString())} = ${GetController().getMoneyFormat(item['total_price'].toString())} so‘m',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              TextField(
                controller: paymentController,
                decoration: InputDecoration(
                  labelText: 'To‘lov miqdori (so‘m)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                onChanged: (value) {
                  final parsedValue = double.tryParse(value) ?? 0.0;
                  if (parsedValue > remainingDebt) {
                    paymentController.text = remainingDebt.toStringAsFixed(0);
                    paymentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: paymentController.text.length),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          Obx(
                () => ElevatedButton(
              onPressed: controller.isSelling.value
                  ? null
                  : () {
                final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
                if (paymentAmount <= 0 || paymentAmount > remainingDebt) {
                  CustomToast.show(
                    context: context,
                    title: 'Xatolik',
                    message: 'Noto‘g‘ri to‘lov miqdori',
                    type: CustomToast.error,
                  );
                  return;
                }
                controller
                    .payDebt(context, sale['id'], paymentAmount)
                    .then((_) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  controller.recentSalesFuture.value =
                      controller.apiService.getRecentSales(limit: 2);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isSelling.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'To‘lash',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput(BuildContext context, SalesScreenController controller) {
    return GetBuilder<SalesScreenController>(
      id: 'quantity',
      builder: (controller) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.quantityController,
                decoration: InputDecoration(
                  labelText: 'Miqdor',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 16),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                onChanged: controller.updateQuantity,
              ),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.remove,
              onPressed: controller.decrementQuantity,
            ),
            const SizedBox(width: 4),
            _buildIconButton(
              icon: Icons.add,
              onPressed: controller.incrementQuantity,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceInput(BuildContext context, SalesScreenController controller) {
    return TextField(
      controller: controller.priceController,
      decoration: InputDecoration(
        labelText: 'Ustama haq (so‘m)',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: Colors.white,
        fontSize: Responsive.getFontSize(context, baseSize: 16),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      onChanged: controller.updatePrice,
    );
  }

  Widget _buildPriceSummary(BuildContext context, SalesScreenController controller) {
    return GetBuilder<SalesScreenController>(
      id: 'totalPrice',
      builder: (controller) {
        final totalPrice = controller.getTotalPrice();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.selectedProductId.value != null) ...[
              Text(
                'Jami: ${GetController().getMoneyFormat(totalPrice.toString())} so‘m',
                style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 18), color: Colors.white, fontWeight: FontWeight.bold)
              ),
              if (controller.discount.value > 0)
                Text(
                  'Chegirma: ${GetController().getMoneyFormat(controller.discount.value.toString())} so‘m',
                  style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 13), color: Colors.white70)
                )
            ]
          ]
        );
      },
    );
  }

  Widget _buildAdvancedOptionsToggle(BuildContext context, SalesScreenController controller) {
    return Column(
      children: [
        _buildSwitchTile(
          context,
          title: "Qarzga sotish",
          value: controller.showCreditOptions,
          onChanged: controller.toggleCreditOptions,
        ),
        _buildSwitchTile(
          context,
          title: "Chegirma qo‘shish",
          value: controller.showDiscountOption,
          onChanged: controller.toggleDiscountOption,
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      BuildContext context, {
        required String title,
        required RxBool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Obx(
          () => Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 15),
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: value.value,
              onChanged: onChanged,
              activeColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditOptions(BuildContext context, SalesScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Qarzga sotish uchun",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Mavjud mijozni tanlang',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
            dropdownColor: secondaryColor.withOpacity(0.9),
            value: controller.selectedCustomerId.value,
            items: controller.appController.customers.map((customer) {
              return DropdownMenuItem<String>(
                value: customer['id'].toString(),
                child: Text(
                  customer['full_name'] ?? 'Noma’lum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.getFontSize(context, baseSize: 15),
                  ),
                ),
              );
            }).toList(),
            onChanged: controller.updateCustomerSelection,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Yoki yangi mijoz qo‘shing",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.newCustomerNameController,
          decoration: InputDecoration(
            labelText: 'Ism',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
          onChanged: controller.updateNewCustomerName,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.newCustomerPhoneController,
          decoration: InputDecoration(
            labelText: 'Telefon',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          keyboardType: TextInputType.phone,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
          onChanged: controller.updateNewCustomerPhone,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.newCustomerAddressController,
          decoration: InputDecoration(
            labelText: 'Manzil',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
          onChanged: controller.updateNewCustomerAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.creditAmountController,
          decoration: InputDecoration(
            labelText: 'Qarz summasi',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          onChanged: controller.updateCreditAmount,
        ),
        const SizedBox(height: 12),
        Obx(
              () => ElevatedButton(
            onPressed: () => controller.selectCreditDueDate(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              controller.creditDueDate.value == null
                  ? 'Muddat tanlang'
                  : 'Muddat: ${controller.apiService.formatDate(controller.creditDueDate.value!.toIso8601String())}',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountInput(BuildContext context, SalesScreenController controller) {
    return TextField(
      controller: controller.discountController,
      decoration: InputDecoration(
        labelText: 'Chegirma (so‘m)',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: Colors.white,
        fontSize: Responsive.getFontSize(context, baseSize: 16),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      onChanged: controller.updateDiscount,
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}