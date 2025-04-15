import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/sales_screen_controller.dart';
import '../../companents/custom_toast.dart';
import '../../responsive.dart';
import '../test_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesScreenController());

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

  Widget _buildDesktopLayout(
    BuildContext context,
    SalesScreenController controller,
  ) {
    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context, controller),
        Expanded(
          child: Row(
            children: [
              _buildCategoryList(context, controller, width: 160),
              Expanded(child: _buildProductGrid(context, controller)),
              _buildSalePanel(context, controller, width: 320),
            ],
          ),
        ),
        _buildRecentSales(context, controller),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    SalesScreenController controller,
  ) {
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

  Widget _buildMobileLayout(
    BuildContext context,
    SalesScreenController controller,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                _buildHeader(context),
                _buildSearchBar(
                  context,
                  controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ],
            ),
          ),
          expandedHeight: 140,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildCategoryList(
                context,
                controller,
                isHorizontal: true,
                height: 50,
              ),
              _buildProductGrid(
                context,
                controller,
                maxCrossAxisExtent: 140,
                childAspectRatio: 1.4,
                height: 360,
              ),
              _buildSalePanel(
                context,
                controller,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
              ),
              _buildRecentSales(context, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: Responsive.getPadding(
        context,
        basePadding: const EdgeInsets.all(12),
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sotuv",
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 26),
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 28),
              //TestScreen
            onPressed: () => GoRouter.of(context).go('/test'),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    SalesScreenController controller, {
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return Padding(
      padding: Responsive.getPadding(context, basePadding: padding),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Mahsulot qidirish',
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: Responsive.getFontSize(context, baseSize: 16),
          ),
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
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 24),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: Responsive.getFontSize(context, baseSize: 16),
        ),
        onChanged:
            (value) => controller.searchQuery.value = value.toLowerCase(),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    SalesScreenController controller, {
    double width = 160,
    bool isHorizontal = false,
    double height = 400,
  }) {
    return Container(
      width: isHorizontal ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () =>
            isHorizontal
                ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryItem(context, controller, null, "Barchasi"),
                      ...controller.appController.categories.map(
                        (category) => _buildCategoryItem(
                          context,
                          controller,
                          category['id'].toString(),
                          category['name'],
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  scrollDirection:
                      isHorizontal ? Axis.horizontal : Axis.vertical,
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
                    final category =
                        controller.appController.categories[index - 1];
                    return _buildCategoryItem(
                      context,
                      controller,
                      category['id'].toString(),
                      category['name'],
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    SalesScreenController controller,
    String? id,
    String name,
  ) {
    return GestureDetector(
      onTap: () => controller.selectCategory(id),
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                controller.selectedCategoryId.value == id
                    ? primaryColor.withOpacity(0.9)
                    : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            style: TextStyle(
              color:
                  controller.selectedCategoryId.value == id
                      ? Colors.white
                      : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.getFontSize(context, baseSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    SalesScreenController controller, {
    double maxCrossAxisExtent = 180,
    double childAspectRatio = 1.5,
    double height = 360,
  }) {
    return Obx(() {
      final filteredProducts =
          controller.selectedCategoryId.value == null
              ? controller.appController.products
              : controller.appController.products
                  .where(
                    (p) =>
                        p['category_id'].toString() ==
                        controller.selectedCategoryId.value,
                  )
                  .toList();

      final searchedProducts =
          filteredProducts
              .where(
                (p) => p['name'].toString().toLowerCase().contains(
                  controller.searchQuery.value,
                ),
              )
              .toList();

      if (controller.isStockLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }

      return searchedProducts.isEmpty
          ? Center(
            child: Text(
              "Mahsulot topilmadi",
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 16),
              ),
            ),
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
                String? batchId;
                double stockQuantity = 0.0;
                double sellingPrice = 0.0;
                double costPrice = 0.0;

                for (var entry in controller.batchCache.entries) {
                  if (entry.value['product_id'] == product['id'].toString()) {
                    batchId = entry.key;
                    stockQuantity = entry.value['quantity'];
                    sellingPrice = entry.value['selling_price'];
                    costPrice = entry.value['cost_price'];
                    break;
                  }
                }

                Color borderColor = Colors.transparent;
                if (stockQuantity == 0) {
                  borderColor = Colors.red;
                } else if (stockQuantity <= 10) {
                  borderColor = Colors.yellow;
                }

                return GestureDetector(
                  onTap:
                      () => controller.selectProduct(
                        product['id'].toString(),
                        batchId,
                        stockQuantity,
                        costPrice,
                        sellingPrice,
                      ),
                  child: Obx(
                    () => AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale:
                          controller.selectedProductId.value ==
                                  product['id'].toString()
                              ? 0.95
                              : 1.0,
                      child: Card(
                        elevation: 3,
                        color:
                            controller.selectedProductId.value ==
                                    product['id'].toString()
                                ? primaryColor.withOpacity(0.9)
                                : Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.getFontSize(
                                      context,
                                      baseSize: 14,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Narx: $costPrice + $sellingPrice = ${costPrice + sellingPrice}",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 11,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Qoldiq: ${stockQuantity.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color:
                                      borderColor == Colors.transparent
                                          ? Colors.white70
                                          : borderColor,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 11,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
    });
  }

  Widget _buildSalePanel(
    BuildContext context,
    SalesScreenController controller, {
    double width = 320,
    EdgeInsets padding = const EdgeInsets.all(12),
    double? height,
  }) {
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
        child: Obx(
          () => Column(
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
                  controller.selectedBatchId.value != null) ...[
                Text(
                  "Tanlangan: ${controller.appController.products.firstWhere((p) => p['id'].toString() == controller.selectedProductId.value)['name']}",
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
                      Color quantityColor =
                          stockQuantity == 0
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
                              fontSize: Responsive.getFontSize(
                                context,
                                baseSize: 13,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (stockQuantity == 0)
                            Text(
                              "Mahsulot omborda mavjud emas",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: Responsive.getFontSize(
                                  context,
                                  baseSize: 12,
                                ),
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
              Obx(
                () => AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: controller.isSelling.value ? 0.95 : 1.0,
                  child: ElevatedButton(
                    onPressed:
                        (controller.selectedProductId.value == null ||
                                controller.selectedBatchId.value == null ||
                                controller.quantity.value <= 0 ||
                                controller.isSelling.value ||
                                controller.cachedStockQuantity.value == null ||
                                controller.cachedStockQuantity.value == 0)
                            ? null
                            : () => controller.sellProduct(context),
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
                    child:
                        controller.isSelling.value
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
                                fontSize: Responsive.getFontSize(
                                  context,
                                  baseSize: 16,
                                ),
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
          FutureBuilder<List<dynamic>>(
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
                    if (sale['sale_items'] != null &&
                        sale['sale_items'].isNotEmpty &&
                        sale['sale_items'][0]['unit_price'] != null &&
                        sale['sale_items'][0]['batches'] != null) {
                      final unitPrice =
                          (sale['sale_items'][0]['unit_price'] as num?)
                              ?.toDouble() ??
                          0.0;
                      final costPrice =
                          (sale['sale_items'][0]['batches']['cost_price']
                                  as num?)
                              ?.toDouble() ??
                          0.0;
                      final sellingPrice =
                          (sale['sale_items'][0]['batches']['selling_price']
                                  as num?)
                              ?.toDouble() ??
                          0.0;
                      hasMarkup = unitPrice > (costPrice + sellingPrice);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sale['sale_items'] != null &&
                                                sale['sale_items'].isNotEmpty &&
                                                sale['sale_items'][0]['batches'] !=
                                                    null &&
                                                sale['sale_items'][0]['batches']['products'] !=
                                                    null
                                            ? sale['sale_items'][0]['batches']['products']['name'] ??
                                                'Noma’lum mahsulot'
                                            : 'Noma’lum mahsulot',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.getFontSize(
                                            context,
                                            baseSize: 13,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (sale['sale_type'] == 'returned')
                                        Text(
                                          "Qaytarildi",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: Responsive.getFontSize(
                                              context,
                                              baseSize: 11,
                                            ),
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
                                if ((sale['paid_amount'] as num) <
                                    (sale['total_amount'] as num))
                                  const Icon(
                                    Icons.credit_card,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                if ((sale['discount_amount'] as num) > 0)
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
                                "${(sale['total_amount'] as num).toStringAsFixed(0)} so‘m",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (sale['sale_type'] != 'returned')
                                IconButton(
                                  icon: const Icon(
                                    Icons.undo,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  tooltip: 'Qaytarish',
                                  onPressed:
                                      controller.isSelling.value
                                          ? null
                                          : () => controller.returnProduct(
                                            context,
                                            sale['id'],
                                          ),
                                ),
                            ],
                          ),
                        ],
                      ),
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
          ),
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
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 16),
            child: Container(
              width:
                  Responsive.isMobile(context)
                      ? double.infinity
                      : MediaQuery.of(context).size.width * 0.9,
              height:
                  Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.height - 32
                      : MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Sarlavha va yopish tugmasi
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Barcha sotuvlar",
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              baseSize: 18,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Qidiruv maydoni
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Mahsulot bo‘yicha qidirish',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: Responsive.getFontSize(
                            context,
                            baseSize: 14,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                      ),
                      onChanged:
                          (value) => searchQuery.value = value.toLowerCase(),
                    ),
                  ),
                  // Status va vaqt saralash
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Status',
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 12,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              value: selectedStatus.value,
                              items: [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text(
                                    'Barchasi',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'returned',
                                  child: Text(
                                    'Qaytarilgan',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'debt',
                                  child: Text(
                                    'Qarzga sotilgan',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'discount',
                                  child: Text(
                                    'Chegirmali',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'cash',
                                  child: Text(
                                    'Naqd',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
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
                                  color: Colors.black54,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 12,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              value: sortOrder.value,
                              items: [
                                DropdownMenuItem(
                                  value: 'newest',
                                  child: Text(
                                    'Eng yangi',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'oldest',
                                  child: Text(
                                    'Eng eski',
                                    style: TextStyle(
                                      fontSize: Responsive.getFontSize(
                                        context,
                                        baseSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
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
                  // Sana tanlash
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      startDate.value ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  startDate.value = selectedDate;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                startDate.value == null
                                    ? 'Boshlang‘ich sana'
                                    : 'Boshlang‘ich: ${startDate.value!.toString().substring(0, 10)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 12,
                                  ),
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
                                );
                                if (selectedDate != null) {
                                  endDate.value = selectedDate;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                endDate.value == null
                                    ? 'Oxirgi sana'
                                    : 'Oxirgi: ${endDate.value!.toString().substring(0, 10)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.getFontSize(
                                    context,
                                    baseSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sotuvlar ro‘yxati
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: controller.apiService.getSales(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Xato: ${snapshot.error}",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: Responsive.getFontSize(
                                  context,
                                  baseSize: 14,
                                ),
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
                                color: Colors.black54,
                                fontSize: Responsive.getFontSize(
                                  context,
                                  baseSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return Obx(() {
                          // Qidiruv, status va sana bo‘yicha filtr
                          List<dynamic> filteredSales =
                              allSales.where((sale) {
                                final productName =
                                    sale['sale_items'] != null &&
                                            sale['sale_items'].isNotEmpty &&
                                            sale['sale_items'][0]['batches'] !=
                                                null &&
                                            sale['sale_items'][0]['batches']['products'] !=
                                                null
                                        ? sale['sale_items'][0]['batches']['products']['name']
                                                ?.toString()
                                                .toLowerCase() ??
                                            ''
                                        : '';
                                final matchesSearch =
                                    searchQuery.value.isEmpty ||
                                    productName.contains(searchQuery.value);
                                final matchesStatus =
                                    selectedStatus.value == 'all' ||
                                    (selectedStatus.value == 'returned' &&
                                        sale['sale_type'] == 'returned') ||
                                    (selectedStatus.value == 'debt' &&
                                        (sale['sale_type'] == 'debt' ||
                                            sale['sale_type'] ==
                                                'debt_with_discount')) ||
                                    (selectedStatus.value == 'discount' &&
                                        (sale['sale_type'] == 'discount' ||
                                            sale['sale_type'] ==
                                                'debt_with_discount')) ||
                                    (selectedStatus.value == 'cash' &&
                                        sale['sale_type'] == 'cash');
                                final saleDate = DateTime.parse(
                                  sale['sale_date'],
                                );
                                final matchesDate =
                                    (startDate.value == null ||
                                        saleDate.isAfter(startDate.value!)) &&
                                    (endDate.value == null ||
                                        saleDate.isBefore(
                                          endDate.value!.add(
                                            const Duration(days: 1),
                                          ),
                                        ));
                                return matchesSearch &&
                                    matchesStatus &&
                                    matchesDate;
                              }).toList();

                          // Vaqt bo‘yicha saralash
                          filteredSales.sort((a, b) {
                            final dateA = DateTime.parse(a['sale_date']);
                            final dateB = DateTime.parse(b['sale_date']);
                            return sortOrder.value == 'newest'
                                ? dateB.compareTo(dateA)
                                : dateA.compareTo(dateB);
                          });

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            itemCount: filteredSales.length,
                            itemBuilder: (context, index) {
                              final sale = filteredSales[index];
                              bool hasMarkup = false;
                              if (sale['sale_items'] != null &&
                                  sale['sale_items'].isNotEmpty &&
                                  sale['sale_items'][0]['unit_price'] != null &&
                                  sale['sale_items'][0]['batches'] != null) {
                                final unitPrice =
                                    (sale['sale_items'][0]['unit_price']
                                            as num?)
                                        ?.toDouble() ??
                                    0.0;
                                final costPrice =
                                    (sale['sale_items'][0]['batches']['cost_price']
                                            as num?)
                                        ?.toDouble() ??
                                    0.0;
                                final sellingPrice =
                                    (sale['sale_items'][0]['batches']['selling_price']
                                            as num?)
                                        ?.toDouble() ??
                                    0.0;
                                hasMarkup =
                                    unitPrice > (costPrice + sellingPrice);
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sale['sale_items'] != null &&
                                                          sale['sale_items']
                                                              .isNotEmpty &&
                                                          sale['sale_items'][0]['batches'] !=
                                                              null &&
                                                          sale['sale_items'][0]['batches']['products'] !=
                                                              null
                                                      ? sale['sale_items'][0]['batches']['products']['name'] ??
                                                          'Noma’lum mahsulot'
                                                      : 'Noma’lum mahsulot',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                          context,
                                                          baseSize: 14,
                                                        ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  sale['sale_date'] != null
                                                      ? sale['sale_date']
                                                          .substring(
                                                            0,
                                                            16,
                                                          ) // YYYY-MM-DD HH:MM
                                                      : 'Noma’lum vaqt',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                          context,
                                                          baseSize: 12,
                                                        ),
                                                  ),
                                                ),
                                                if (sale['sale_type'] ==
                                                    'returned')
                                                  Text(
                                                    "Qaytarildi",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          Responsive.getFontSize(
                                                            context,
                                                            baseSize: 12,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (hasMarkup)
                                            const Icon(
                                              Icons.attach_money,
                                              color: Colors.yellow,
                                              size: 18,
                                            ),
                                          const SizedBox(width: 8),
                                          if ((sale['paid_amount'] as num) <
                                              (sale['total_amount'] as num))
                                            const Icon(
                                              Icons.credit_card,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          if ((sale['discount_amount'] as num) >
                                              0)
                                            const Icon(
                                              Icons.discount,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${(sale['total_amount'] as num).toStringAsFixed(0)} so‘m",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: Responsive.getFontSize(
                                              context,
                                              baseSize: 14,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (sale['sale_type'] == 'debt' ||
                                            sale['sale_type'] ==
                                                'debt_with_discount')
                                          IconButton(
                                            icon: const Icon(
                                              Icons.payment,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                            tooltip: 'To‘lash',
                                            onPressed:
                                                controller.isSelling.value
                                                    ? null
                                                    : () => _showPaymentDialog(
                                                      context,
                                                      controller,
                                                      sale,
                                                    ),
                                          ),
                                        if (sale['sale_type'] != 'returned')
                                          IconButton(
                                            icon: const Icon(
                                              Icons.undo,
                                              color: Colors.orange,
                                              size: 18,
                                            ),
                                            tooltip: 'Qaytarish',
                                            onPressed:
                                                controller.isSelling.value
                                                    ? null
                                                    : () async {
                                                      await controller
                                                          .returnProduct(
                                                            context,
                                                            sale['id'],
                                                          );
                                                      Navigator.pop(
                                                        context,
                                                      ); // Dialogni yopish
                                                      controller
                                                          .recentSalesFuture
                                                          .value = controller
                                                          .apiService
                                                          .getRecentSales(
                                                            limit: 2,
                                                          ); // Ro‘yxatni yangilash
                                                    },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
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
    final remainingDebt = ((sale['total_amount'] as num?)?.toDouble() ?? 0.0) - ((sale['paid_amount'] as num?)?.toDouble() ?? 0.0);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Qarzni to‘lash'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jami qarz: ${remainingDebt.toStringAsFixed(0)} so‘m'),
                const SizedBox(height: 16),
                TextField(
                  controller: paymentController,
                  decoration: InputDecoration(
                    labelText: 'To‘lov miqdori (so‘m)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bekor qilish', style: TextStyle(color: Colors.red))
              ),
              Obx(() => ElevatedButton(onPressed: controller.isSelling.value ? null : () {
                final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
                if (paymentAmount <= 0 || paymentAmount > remainingDebt) {
                  //paymentController maximal miqdori
                  paymentController.text = remainingDebt.toStringAsFixed(0);
                  CustomToast.show(context: context, title: 'Xatolik', message: 'Noto‘g‘ri to‘lov miqdori', type: CustomToast.error);
                  return;
                }
                controller.payDebt(context, sale['id'], paymentAmount).then((_) {Navigator.pop(context,);Navigator.pop(context,);});
                },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: controller.isSelling.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('To‘lash', style: TextStyle(color: Colors.white)))
              )
            ]
          )
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

  Widget _buildPriceInput(
    BuildContext context,
    SalesScreenController controller,
  ) {
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
      onChanged: controller.updatePrice,
    );
  }

  Widget _buildPriceSummary(
    BuildContext context,
    SalesScreenController controller,
  ) {
    return GetBuilder<SalesScreenController>(
      id: 'totalPrice',
      builder: (controller) {
        final totalPrice = controller.getTotalPrice();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.selectedProductId.value != null) ...[
              Text(
                "Jami: $totalPrice so‘m",
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 18),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (controller.discount.value > 0)
                Text(
                  "Chegirma: ${controller.discount.value} so‘m",
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 13),
                    color: Colors.white70,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAdvancedOptionsToggle(
    BuildContext context,
    SalesScreenController controller,
  ) {
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

  Widget _buildCreditOptions(
    BuildContext context,
    SalesScreenController controller,
  ) {
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
            items:
                controller.appController.customers.map((customer) {
                  return DropdownMenuItem<String>(
                    value: customer['id'].toString(),
                    child: Text(
                      customer['full_name'],
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
          onChanged: controller.updateCreditAmount,
        ),
        const SizedBox(height: 12),
        Obx(
          () => ElevatedButton(
            onPressed: () => controller.selectCreditDueDate(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              controller.creditDueDate.value == null
                  ? 'Muddat tanlang'
                  : 'Muddat: ${controller.creditDueDate.value!.toString().substring(0, 10)}',
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

  Widget _buildDiscountInput(
    BuildContext context,
    SalesScreenController controller,
  ) {
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
      onChanged: controller.updateDiscount,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
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
