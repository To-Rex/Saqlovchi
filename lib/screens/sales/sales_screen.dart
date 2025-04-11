import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:sklad/controllers/get_controller.dart';
import 'package:sklad/constants.dart';

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
  double? creditAmount;
  DateTime? creditDueDate;
  double discount = 0.0;
  final RxString searchQuery = ''.obs; // searchQuery reaktiv qilindi

  double getTotalPrice() {
    if (selectedProductId == null || quantity <= 0) return 0.0;
    final product = controller.products.firstWhere((p) => p['id'] == selectedProductId);
    final sellingPrice = (product['selling_price'] as num).toDouble();
    final totalWithoutDiscount = sellingPrice * quantity;
    return totalWithoutDiscount - discount;
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
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: Row(
                  children: [
                    _buildCategoryList(),
                    Expanded(child: _buildProductGrid()),
                    _buildSalePanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          searchQuery.value = value.toLowerCase(); // Reaktiv o‘zgaruvchi yangilanadi
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(
            () => ListView.builder(
          itemCount: controller.categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategoryId = null;
                    selectedProductId = null;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedCategoryId == null ? primaryColor : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Barchasi",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }
            final category = controller.categories[index - 1];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryId = category['id'];
                  selectedProductId = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedCategoryId == category['id'] ? primaryColor : Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category['name'],
                  style: TextStyle(
                    color: selectedCategoryId == category['id'] ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = selectedCategoryId == null
        ? controller.products
        : controller.products.where((p) => p['category_id'] == selectedCategoryId).toList();

    return Obx(
          () {
        final searchedProducts = filteredProducts
            .where((p) => p['name'].toString().toLowerCase().contains(searchQuery.value))
            .toList();

        return searchedProducts.isEmpty
            ? const Center(child: Text("Mahsulot topilmadi", style: TextStyle(color: Colors.white70)))
            : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: searchedProducts.length,
          itemBuilder: (context, index) {
            final product = searchedProducts[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedProductId = product['id'];
                  quantity = 0.0;
                });
              },
              child: Card(
                color: selectedProductId == product['id'] ? primaryColor : Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSalePanel() {
    return Container(
      width: 300,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
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
              onPressed: selectedProductId == null || quantity <= 0 ? null : _sellProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text("Sotish", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
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
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            setState(() {
              quantity++;
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
          Text("Jami: $totalPrice so‘m", style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          if (discount > 0) Text("Chegirma: $discount so‘m", style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
              labelText: 'Mijoz (agar mavjud bo‘lsa)',
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
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Yangi mijoz ismi (ixtiyoriy)',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              newCustomerName = value;
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
          onChanged: (value) {
            setState(() {
              creditAmount = double.tryParse(value);
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
        });
      },
    );
  }

  void _sellProduct() async {
    if (selectedProductId == null || quantity <= 0) {
      Get.snackbar('Xatolik', 'Mahsulot tanlang va miqdor 0 dan katta bo‘lsin');
      return;
    }
    if (showCreditOptions && (creditAmount == null || creditDueDate == null)) {
      Get.snackbar('Xatolik', 'Qarz uchun summa va muddatni kiriting');
      return;
    }

    try {
      await apiService.sellProduct(
        productId: selectedProductId!,
        quantity: quantity,
        customerId: selectedCustomerId,
        customerName: newCustomerName,
        isCredit: showCreditOptions,
        creditAmount: creditAmount,
        creditDueDate: creditDueDate,
        discount: discount,
      );
      setState(() {
        selectedProductId = null;
        quantity = 0.0;
        showCreditOptions = false;
        showDiscountOption = false;
        selectedCustomerId = null;
        newCustomerName = null;
        creditAmount = null;
        creditDueDate = null;
        discount = 0.0;
      });
      Get.snackbar('Muvaffaqiyat', 'Mahsulot sotildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Sotuvda xato: $e');
    }
  }
}