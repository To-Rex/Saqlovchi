import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/controllers/api_service.dart';
import '../../constants.dart';
import '../../controllers/expense_controller.dart';
import '../../responsive.dart';

class ExpensesPage extends StatelessWidget {
  ExpensesPage({super.key});
  final controller = Get.put(ExpensesController());

  String _monthName(int month) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
    ];
    return months[month - 1];
  }


  String _formatCurrency(dynamic value) {
    final amount = double.tryParse(value.toString()) ?? 0.0;
    return "${amount.toStringAsFixed(0)} so‘m";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: Responsive.getPadding(context, basePadding: const EdgeInsets.all(defaultPadding)),
          child: Column(
            children: [
              _buildHeader(context),
              _buildInputSection(context),
              const SizedBox(height: defaultPadding),
              Expanded(child: _buildExpenseList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Center(
        child: Text(
          'Xarajatlar',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, baseSize: 22),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.expenseNameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Xarajat nomi'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: defaultPadding / 2),
        TextField(
          controller: controller.amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Miqdori (UZS)'),
          onSubmitted: (_) => controller.submitExpense(),
        ),
        const SizedBox(height: defaultPadding),
        Obx(() => controller.isSubmitting.value
            ? const CircularProgressIndicator(color: Colors.white)
            : _animatedSubmitButton(context)),
      ],
    );
  }

  Widget _animatedSubmitButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => controller.setButtonScale(0.95),
      onTapUp: (_) => controller.setButtonScale(1.0),
      onTapCancel: () => controller.setButtonScale(1.0),
      onTap: controller.submitExpense,
      child: Obx(() => AnimatedScale(
        scale: controller.buttonScale.value,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 6)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Kiritish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )),
    );
  }


  Widget _buildExpenseList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService().fetchExpensesWithUserStats(), // RPC chaqiruv
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Xarajatlar topilmadi", style: TextStyle(color: Colors.white70)),
          );
        }

        final expenses = snapshot.data!;
        return ListView.separated(
          itemCount: expenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = expenses[index];
            final createdAt = DateTime.tryParse(item['created_at']);
            final formattedDate = createdAt != null
                ? "${createdAt.day.toString().padLeft(2, '0')}-${_monthName(createdAt.month)} ${createdAt.year}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
                : "Noma'lum sana";

            return Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item['amount'].toStringAsFixed(0)} so‘m",
                        style: const TextStyle(fontSize: 14, color: Colors.greenAccent),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.white12),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "👤 ${item['full_name'] ?? 'Noma’lum'}",
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      Text(
                        "Umumiy: ${_formatCurrency(item['total_user_expense'])}",
                        style: const TextStyle(fontSize: 13, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.black.withOpacity(0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
