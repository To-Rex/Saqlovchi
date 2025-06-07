import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/customers_screen_controller.dart';
import 'package:sklad/companents/custom_toast.dart';
import 'package:sklad/controllers/get_controller.dart';
import 'package:sklad/function/dialog_function.dart';
import 'package:sklad/responsive.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final controller = Get.put(CustomersScreenController());
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        controller.updateCustomers();
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor,
                    secondaryColor.withAlpha(229),
                    secondaryColor.withAlpha(179),
                    Colors.black.withAlpha(153),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Responsive.isMobile(context) ? 60 : 80,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mijozlar",
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, baseSize: 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info, color: Colors.white70, size: 20),
                          onPressed: () => DialogFunction().showToast('Diqqat!', 'Bu funksiya hali ishlab chiqilmagan', Colors.grey,2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ism yoki manzil bo‘yicha qidirish',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.getFontSize(context, baseSize: 14),
                      ),
                      filled: true,
                      fillColor: Colors.black.withAlpha(77),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getFontSize(context, baseSize: 14),
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Saralash',
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                            ),
                            filled: true,
                            fillColor: Colors.black.withAlpha(77),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          ),
                          value: controller.sortOrder.value,
                          dropdownColor: Colors.black.withAlpha(229),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Eng yangi')),
                            DropdownMenuItem(value: 'oldest', child: Text('Eng eski')),
                          ],
                          onChanged: controller.setSortOrder,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => _showAddCustomerDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Yangi mijoz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, baseSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FutureBuilder<List<dynamic>>(
                    future: controller.customersFuture.value,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          controller.isLoading.value) {
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
                      final customers = snapshot.data ?? [];
                      if (customers.isEmpty) {
                        return Center(
                          child: Text(
                            "Mijozlar mavjud emas",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.getFontSize(context, baseSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final customerId = customer['id'] as int?;
                          final fullName = customer['full_name'] as String? ?? 'Noma’lum';
                          final phoneNumber = customer['phone_number'] as String? ?? 'Noma’lum';
                          final address = customer['address'] as String? ?? 'Noma’lum';
                          final debtAmount = (customer['debt_amount'] as num?)?.toDouble() ?? 0.0;
                          final createdAt = customer['created_at'] as String?;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(128),
                                  Colors.grey.withAlpha(26),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withAlpha(77)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  color: Colors.grey,
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            fullName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Responsive.getFontSize(
                                                  context, baseSize: 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${GetController().getMoneyFormat(debtAmount.toString())} so‘m',
                                            style: TextStyle(
                                              color: debtAmount > 0
                                                  ? Colors.redAccent
                                                  : Colors.greenAccent,
                                              fontSize: Responsive.getFontSize(
                                                  context, baseSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        phoneNumber,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(
                                              context, baseSize: 12),
                                        ),
                                      ),
                                      Text(
                                        address,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(
                                              context, baseSize: 12),
                                        ),
                                      ),
                                      Text(
                                        createdAt != null
                                            ? DateFormat('yyyy-MM-dd HH:mm')
                                            .format(DateTime.parse(createdAt))
                                            : 'Noma’lum vaqt',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: Responsive.getFontSize(
                                              context, baseSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          if (debtAmount > 0)
                                            ElevatedButton(
                                              onPressed: controller.isLoading.value
                                                  ? null
                                                  : () => _showPayDebtDialog(
                                                context,
                                                controller,
                                                customerId,
                                                fullName,
                                                debtAmount,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.greenAccent,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(8)),
                                              ),
                                              child: Text(
                                                'To‘lash',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: Responsive.getFontSize(
                                                      context, baseSize: 12),
                                                ),
                                              ),
                                            ),
                                          if (debtAmount > 0) const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: controller.isLoading.value
                                                ? null
                                                : () => _showEditCustomerDialog(
                                                context, controller, customer),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(8)),
                                            ),
                                            child: Text(
                                              'Tahrirlash',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Responsive.getFontSize(
                                                    context, baseSize: 12),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: controller.isLoading.value
                                                ? null
                                                : () => _showDeleteCustomerDialog(
                                                context,
                                                controller,
                                                customerId,
                                                fullName),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(8)),
                                            ),
                                            child: Text(
                                              'O‘chirish',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Responsive.getFontSize(
                                                    context, baseSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, CustomersScreenController controller) {
    final fullNameController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          'Yangi mijoz qo‘shish',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Ism',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqami (ixtiyoriy)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Manzil (ixtiyoriy)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
              if (fullNameController.text.isEmpty) {
                CustomToast.show(
                  title: 'Xatolik',
                  context: context,
                  message: "Ism to‘ldirilishi shart",
                  type: CustomToast.error,
                );
                return;
              }
              await controller.addCustomer(
                fullName: fullNameController.text,
                phoneNumber: phoneNumberController.text,
                address: addressController.text,
                createdBy: controller.supabase.auth.currentUser!.id,
                context: context,
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Qo‘shish',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(
      BuildContext context, CustomersScreenController controller, Map<String, dynamic> customer) {
    final fullNameController = TextEditingController(text: customer['full_name'] ?? '');
    final phoneNumberController = TextEditingController(text: customer['phone_number'] ?? '');
    final addressController = TextEditingController(text: customer['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          'Mijoz ma‘lumotlarini tahrirlash',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Ism',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqami (ixtiyoriy)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Manzil (ixtiyoriy)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withAlpha(77),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
              if (fullNameController.text.isEmpty) {
                CustomToast.show(
                  title: 'Xatolik',
                  context: context,
                  message: "Ism to‘ldirilishi shart",
                  type: CustomToast.error,
                );
                return;
              }
              await controller.updateCustomer(
                customerId: customer['id'],
                fullName: fullNameController.text,
                phoneNumber: phoneNumberController.text,
                address: addressController.text,
                context: context,
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Saqlash',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCustomerDialog(
      BuildContext context, CustomersScreenController controller, int? customerId, String fullName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          'Mijoz o‘chirish',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: Text(
          '$fullName ni o‘chirishni tasdiqlaysizmi? Bu amalni qaytarib bo‘lmaydi.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: Responsive.getFontSize(context, baseSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
              await controller.deleteCustomer(customerId, context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'O‘chirish',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(
      BuildContext context,
      CustomersScreenController controller,
      int? customerId,
      String fullName,
      double debtAmount,
      ) {
    if (customerId == null) {
      CustomToast.show(
        title: 'Xatolik',
        context: context,
        message: 'Mijoz ID topilmadi',
        type: CustomToast.error,
      );
      return;
    }

    final paymentAmountController = TextEditingController();
    final selectedTransactions = <int, bool>{}.obs;
    final totalSelectedAmount = 0.0.obs;

    // Tanlangan tranzaksiyalarning umumiy summasini hisoblash
    void calculateTotalSelectedAmount(List<dynamic> debtSales) {
      double total = 0.0;
      for (var sale in debtSales) {
        if (selectedTransactions[sale['transaction_id']] == true) {
          total += (sale['amount'] as num).toDouble();
        }
      }
      totalSelectedAmount.value = total;
      paymentAmountController.text = total.toStringAsFixed(2);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          '$fullName uchun qarz to‘lash',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, baseSize: 18),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joriy qarz: ${GetController().getMoneyFormat(debtAmount.toStringAsFixed(2))} so‘m',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To‘lanmagan yoki qisman to‘langan qarzlar:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<dynamic>>(
                  future: controller.getDebtSales(customerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Xato: ${snapshot.error}',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                        ),
                      );
                    }
                    final debtSales = snapshot.data ?? [];
                    if (debtSales.isEmpty) {
                      return Text(
                        'To‘lanmagan yoki qisman to‘langan qarzlar mavjud emas',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: Responsive.getFontSize(context, baseSize: 12),
                        ),
                      );
                    }

                    selectedTransactions.clear();
                    for (var sale in debtSales) {
                      selectedTransactions[sale['transaction_id']] = false;
                    }

                    return SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Obx(() => Column(
                          children: debtSales.asMap().entries.map((entry) {
                            final sale = entry.value;
                            final items = sale['items'] as List<dynamic>;
                            return Card(
                              color: Colors.black.withAlpha(77),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: selectedTransactions[sale['transaction_id']] ?? false,
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectedTransactions[sale['transaction_id']] = value;
                                          calculateTotalSelectedAmount(debtSales);
                                        }
                                      },
                                      activeColor: primaryColor,
                                      checkColor: Colors.white,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tranzaksiya ID: ${sale['transaction_id']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                                            ),
                                          ),
                                          Text(
                                            'Umumiy summa: ${GetController().getMoneyFormat((sale['amount'] as num).toDouble().toStringAsFixed(2))} so‘m',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                                            ),
                                          ),
                                          Text(
                                            'Sana: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(sale['created_at']))}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: Responsive.getFontSize(context, baseSize: 12),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mahsulotlar:',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Responsive.getFontSize(context, baseSize: 12),
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
                                              '${item['product_name']}: ${item['quantity']} x ${GetController().getMoneyFormat((item['unit_price'] as num).toDouble().toStringAsFixed(2))} = ${GetController().getMoneyFormat((item['total_price'] as num).toDouble().toStringAsFixed(2))} so‘m',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: Responsive.getFontSize(context, baseSize: 12),
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: paymentAmountController,
                  decoration: InputDecoration(
                    labelText: 'To‘lov miqdori (so‘m)',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: Responsive.getFontSize(context, baseSize: 12),
                    ),
                    filled: true,
                    fillColor: Colors.black.withAlpha(77),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.getFontSize(context, baseSize: 14),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsedValue = double.tryParse(value) ?? 0.0;
                    if (parsedValue > totalSelectedAmount.value) {
                      paymentAmountController.text = totalSelectedAmount.value.toStringAsFixed(2);
                      paymentAmountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: paymentAmountController.text.length),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
              final paymentAmount = double.tryParse(paymentAmountController.text) ?? 0.0;
              if (paymentAmount <= 0) {
                CustomToast.show(
                  title: 'Xatolik',
                  context: context,
                  message: 'To‘lov miqdori musbat bo‘lishi kerak',
                  type: CustomToast.error,
                );
                return;
              }
              final selectedIds = selectedTransactions.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();
              if (selectedIds.isEmpty) {
                CustomToast.show(
                  title: 'Xatolik',
                  context: context,
                  message: 'Kamida bitta tranzaksiya tanlang',
                  type: CustomToast.error,
                );
                return;
              }
              await controller.payDebt(
                customerId: customerId,
                paymentAmount: paymentAmount,
                selectedTransactionIds: selectedIds,
                createdBy: controller.supabase.auth.currentUser!.id,
                context: context,
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'To‘lash',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}