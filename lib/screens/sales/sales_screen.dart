import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:sklad/controllers/get_controller.dart';
import 'package:sklad/constants.dart';
import '../../companents/custom_toast.dart';
import '../../responsive.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ApiService apiService = ApiService();
  final GetController controller = Get.find<GetController>();
  String? selectedCategoryId;
  String? selectedProductId;
  double quantity = 0.0;
  bool showCreditOptions = false;
  bool showDiscountOption = false;
  String? selectedCustomerId;
  String? newCustomerName;
  String? newCustomerPhone;
  String? newCustomerAddress;
  double? creditAmount;
  DateTime? creditDueDate;
  double discount = 0.0;
  final RxString searchQuery = ''.obs;
  bool _isSelling = false;
  late Future<List<dynamic>> _recentSalesFuture;
  double? _cachedStockQuantity; // Tanlangan mahsulotning qoldigi
  final Map<String, double> _stockCache = {}; // Barcha mahsulotlarning qoldiqlari
  bool _isStockLoading = true; // Qoldiqlar yuklanayotgan holat

  @override
  void initState() {
    super.initState();
    _recentSalesFuture = apiService.getRecentSoldItems(limit: 3);
    _preloadStockQuantities();
  }

  double getTotalPrice() {
    if (selectedProductId == null || quantity <= 0) return 0.0;
    final product = controller.products.firstWhere((p) => p['id'] == selectedProductId);
    final sellingPrice = (product['selling_price'] as num).toDouble();
    final totalWithoutDiscount = sellingPrice * quantity;
    return totalWithoutDiscount - discount;
  }

  // Barcha mahsulotlar uchun qoldiqlarni oldindan yuklash
  Future<void> _preloadStockQuantities() async {
    setState(() {
      _isStockLoading = true;
    });
    for (var product in controller.products) {
      final productId = product['id'] as String;
      if (!_stockCache.containsKey(productId)) {
        final stockQuantity = await apiService.getStockQuantity(productId);
        _stockCache[productId] = stockQuantity;
      }
    }
    setState(() {
      _isStockLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, secondaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Responsive(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: Row(
            children: [
              _buildCategoryList(width: 150),
              Expanded(child: _buildProductGrid()),
              _buildSalePanel(height: double.infinity),
            ],
          ),
        ),
        _buildRecentSales(),
      ],
    );
  }

  // Tablet Layout
  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: Row(
            children: [
              _buildCategoryList(width: 120),
              Expanded(child: _buildProductGrid()),
              _buildSalePanel(width: 250),
            ],
          ),
        ),
        _buildRecentSales(),
      ],
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
              ],
            ),
          ),
          expandedHeight: 150,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildCategoryList(isHorizontal: true, height: 60),
              _buildProductGrid(maxCrossAxisExtent: 150, childAspectRatio: 1.5, height: 400),
              _buildSalePanel(width: double.infinity, padding: const EdgeInsets.all(8)),
              _buildRecentSales(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Sotuv",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Padding(
      padding: padding,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Mahsulot qidirish',
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          searchQuery.value = value.toLowerCase();
        },
      ),
    );
  }

  Widget _buildCategoryList({double width = 150, bool isHorizontal = false, double height = 400}) {
    return Container(
      width: isHorizontal ? double.infinity : width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(
            () => isHorizontal
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryItem(null, "Barchasi"),
              ...controller.categories.map((category) => _buildCategoryItem(category['id'], category['name'])),
            ],
          ),
        )
            : ListView.builder(
          scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
          itemCount: controller.categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildCategoryItem(null, "Barchasi");
            final category = controller.categories[index - 1];
            return _buildCategoryItem(category['id'], category['name']);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String? id, String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryId = id;
          selectedProductId = null;
          _cachedStockQuantity = null;
          _resetSalePanel();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedCategoryId == id ? primaryColor : Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selectedCategoryId == id ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid({double maxCrossAxisExtent = 200, double childAspectRatio = 1.3, double height = 400}) {
    final filteredProducts = selectedCategoryId == null
        ? controller.products
        : controller.products.where((p) => p['category_id'] == selectedCategoryId).toList();

    return Obx(
          () {
        final searchedProducts = filteredProducts
            .where((p) => p['name'].toString().toLowerCase().contains(searchQuery.value))
            .toList();

        if (_isStockLoading) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        return searchedProducts.isEmpty
            ? const Center(child: Text("Mahsulot topilmadi", style: TextStyle(color: Colors.white70)))
            : SizedBox(
          height: height,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: searchedProducts.length,
            itemBuilder: (context, index) {
              final product = searchedProducts[index];
              final productId = product['id'] as String;
              final stockQuantity = _stockCache[productId] ?? 0.0;
              Color borderColor = Colors.transparent;
              if (stockQuantity == 0) {
                borderColor = Colors.red;
              } else if (stockQuantity <= 10) {
                borderColor = Colors.yellow;
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedProductId = product['id'];
                    _cachedStockQuantity = stockQuantity; // Keshdan qoldiqni olish
                    _resetSalePanel();
                    quantity = 1.0;
                    controller.quantityController.text = quantity.toString();
                  });
                },
                child: Card(
                  color: selectedProductId == product['id'] ? primaryColor : Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Narx: ${product['cost_price']} + ${product['selling_price'] - product['cost_price']} = ${product['selling_price']}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qoldiq: ${stockQuantity.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: borderColor == Colors.transparent ? Colors.white70 : borderColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSalePanel({double width = 300, EdgeInsets padding = const EdgeInsets.all(16), double? height}) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sotish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            if (selectedProductId != null) ...[
              Text(
                "Tanlangan: ${controller.products.firstWhere((p) => p['id'] == selectedProductId)['name']}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              if (_cachedStockQuantity != null) ...[
                Builder(
                  builder: (context) {
                    final stockQuantity = _cachedStockQuantity ?? 0.0;
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
                          style: TextStyle(color: quantityColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        if (stockQuantity == 0)
                          const Text(
                            "Mahsulot omborda mavjud emas",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
            _buildQuantityInput(),
            const SizedBox(height: 16),
            _buildPriceSummary(),
            const SizedBox(height: 16),
            _buildAdvancedOptionsToggle(),
            if (showCreditOptions || showDiscountOption) ...[
              const SizedBox(height: 16),
              if (showCreditOptions) _buildCreditOptions(),
              if (showDiscountOption) _buildDiscountInput(),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (selectedProductId == null ||
                  quantity <= 0 ||
                  _isSelling ||
                  _cachedStockQuantity == null ||
                  _cachedStockQuantity == 0)
                  ? null
                  : _sellProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: _isSelling
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Sotish", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSales() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Oxirgi sotuvlar",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<dynamic>>(
            future: _recentSalesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (snapshot.hasError) {
                return Text("Xato: ${snapshot.error}", style: const TextStyle(color: Colors.white70));
              }
              final recentSales = snapshot.data ?? [];
              return Column(
                children: [
                  ...recentSales.map(
                        (sale) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                sale['products']['name'] ?? 'Noma’lum mahsulot',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              if (sale['sales'] != null && _parseIsCredit(sale['sales']))
                                const Icon(Icons.credit_card, color: Colors.red, size: 16),
                              if (sale['products'] != null &&
                                  sale['selling_price'] < (sale['products']['selling_price'] ?? sale['selling_price']))
                                const Icon(Icons.discount, color: Colors.green, size: 16),
                            ],
                          ),
                          Text(
                            "${sale['quantity']} x ${sale['selling_price']} = ${sale['quantity'] * sale['selling_price']} so‘m",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _showAllSalesDialog(context);
                    },
                    child: const Text(
                      "Barchasini ko‘rish",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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

  void _showAllSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Barcha sotuvlar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: secondaryColor.withOpacity(0.9),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: FutureBuilder<List<dynamic>>(
            future: apiService.getAllSoldItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (snapshot.hasError) {
                return Text(
                  "Xato: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70),
                );
              }
              final allSales = snapshot.data ?? [];
              if (allSales.isEmpty) {
                return const Text(
                  "Sotuvlar mavjud emas",
                  style: TextStyle(color: Colors.white70),
                );
              }
              return ListView.builder(
                itemCount: allSales.length,
                itemBuilder: (context, index) {
                  final sale = allSales[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              sale['products']['name'] ?? 'Noma’lum mahsulot',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            if (sale['sales'] != null && _parseIsCredit(sale['sales']))
                              const Icon(Icons.credit_card, color: Colors.red, size: 16),
                            if (sale['products'] != null &&
                                sale['selling_price'] < (sale['products']['selling_price'] ?? sale['selling_price']))
                              const Icon(Icons.discount, color: Colors.green, size: 16),
                          ],
                        ),
                        Text(
                          "${sale['quantity']} x ${sale['selling_price']} = ${sale['quantity'] * sale['selling_price']} so‘m",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Yopish",
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  bool _parseIsCredit(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    if (value is List && value.isNotEmpty) {
      final firstSale = value[0];
      if (firstSale is Map && firstSale.containsKey('is_credit')) {
        return _parseIsCredit(firstSale['is_credit']);
      }
    }
    return false;
  }

  Widget _buildQuantityInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.quantityController,
            decoration: InputDecoration(
              labelText: 'Miqdor',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                quantity = double.tryParse(value) ?? 0.0;
                controller.quantityController.text = quantity.toString();
                if (showCreditOptions) {
                  creditAmount = getTotalPrice();
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.white),
          onPressed: () {
            setState(() {
              if (quantity > 0) quantity--;
              controller.quantityController.text = quantity.toString();
              if (showCreditOptions) {
                creditAmount = getTotalPrice();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            setState(() {
              quantity++;
              controller.quantityController.text = quantity.toString();
              if (showCreditOptions) {
                creditAmount = getTotalPrice();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = getTotalPrice();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedProductId != null && quantity > 0) ...[
          Text("Jami: $totalPrice so‘m", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          if (discount > 0) Text("Chegirma: $discount so‘m", style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Qarzga sotish", style: TextStyle(color: Colors.white)),
            Switch(
              value: showCreditOptions,
              onChanged: (value) {
                setState(() {
                  showCreditOptions = value;
                  if (value && selectedProductId != null && quantity > 0) {
                    creditAmount = getTotalPrice();
                  } else {
                    creditAmount = null;
                    selectedCustomerId = null;
                    newCustomerName = null;
                    newCustomerPhone = null;
                    newCustomerAddress = null;
                    creditDueDate = null;
                  }
                });
              },
              activeColor: primaryColor,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Chegirma qo‘shish", style: TextStyle(color: Colors.white)),
            Switch(
              value: showDiscountOption,
              onChanged: (value) {
                setState(() {
                  showDiscountOption = value;
                  if (!value) discount = 0.0;
                  if (showCreditOptions) {
                    creditAmount = getTotalPrice();
                  }
                });
              },
              activeColor: primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Qarzga sotish uchun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(
              () => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Mavjud mijozni tanlang',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            dropdownColor: secondaryColor,
            value: selectedCustomerId,
            items: controller.customers.map((customer) {
              return DropdownMenuItem<String>(
                value: customer['id'],
                child: Text(customer['full_name'], style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCustomerId = value;
                newCustomerName = null;
                newCustomerPhone = null;
                newCustomerAddress = null;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text("Yoki yangi mijoz qo‘shing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Ism',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              newCustomerName = value;
              selectedCustomerId = null;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Telefon',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              newCustomerPhone = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Manzil',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              newCustomerAddress = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Qarz summasi',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          initialValue: creditAmount?.toString() ?? getTotalPrice().toString(),
          onChanged: (value) {
            setState(() {
              creditAmount = double.tryParse(value) ?? getTotalPrice();
            });
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              setState(() {
                creditDueDate = pickedDate;
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text(
            creditDueDate == null ? 'Muddat tanlang' : 'Muddat: ${creditDueDate!.toString().substring(0, 10)}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Chegirma (so‘m)',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          discount = double.tryParse(value) ?? 0.0;
          if (showCreditOptions) {
            creditAmount = getTotalPrice();
          }
        });
      },
    );
  }

  void _resetSalePanel() {
    quantity = 0.0;
    showCreditOptions = false;
    showDiscountOption = false;
    selectedCustomerId = null;
    newCustomerName = null;
    newCustomerPhone = null;
    newCustomerAddress = null;
    creditAmount = null;
    creditDueDate = null;
    discount = 0.0;
    controller.quantityController.clear();
  }

  void _sellProduct() async {
    if (selectedProductId == null || quantity <= 0) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Mahsulot tanlang va miqdor 0 dan katta bo‘lsin', type: CustomToast.error);
      return;
    }
    if (_cachedStockQuantity != null && quantity > _cachedStockQuantity!) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Omborda yetarli mahsulot yo‘q', type: CustomToast.error);
      return;
    }
    if (showCreditOptions && (creditAmount == null || creditDueDate == null)) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Qarz uchun summa va muddatni kiriting', type: CustomToast.error);
      return;
    }
    if (showCreditOptions && selectedCustomerId == null && (newCustomerName == null || newCustomerName!.isEmpty)) {
      CustomToast.show(context: context, title: 'Xatolik', message: 'Mijozni tanlang yoki yangi mijoz ismini kiriting', type: CustomToast.error);
      return;
    }

    setState(() {
      _isSelling = true;
    });

    try {
      await apiService.sellProduct(
        productId: selectedProductId!,
        quantity: quantity,
        customerId: selectedCustomerId,
        customerName: newCustomerName,
        customerPhone: newCustomerPhone,
        customerAddress: newCustomerAddress,
        isCredit: showCreditOptions,
        creditAmount: creditAmount,
        creditDueDate: creditDueDate,
        discount: discount,
      );
      setState(() {
        // Sotuvdan so‘ng keshni yangilash
        _stockCache[selectedProductId!] = (_stockCache[selectedProductId!] ?? 0.0) - quantity;
        selectedProductId = null;
        _cachedStockQuantity = null;
        _resetSalePanel();
        _recentSalesFuture = apiService.getRecentSoldItems(limit: 3);
      });
      CustomToast.show(context: context, title: 'Muvaffaqiyat', message: 'Mahsulot sotildi', type: CustomToast.success);
    } catch (e) {
      CustomToast.show(context: context, title: 'Xatolik', message: e.toString(), type: CustomToast.error);
    } finally {
      setState(() {
        _isSelling = false;
      });
    }
  }
}