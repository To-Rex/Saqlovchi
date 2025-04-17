import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/transactions_screen_controller.dart';
import '../../responsive.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionsScreenController());

    return Scaffold(
      body: Container(
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
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sarlavha va orqaga tugmasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tranzaksiyalar",
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                // Umumiy statistika
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Umumiy statistika",
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => FutureBuilder<Map<String, dynamic>>(
                        future: controller.statsFuture.value,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: primaryColor),
                            );
                          }
                          final stats =
                              snapshot.data ?? {'income': 0.0, 'expense': 0.0, 'profit': 0.0};
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                context,
                                'Kirim',
                                stats['income'].toStringAsFixed(0),
                                Colors.greenAccent,
                                Icons.arrow_upward,
                              ),
                              _buildStatCard(
                                context,
                                'Chiqim',
                                stats['expense'].toStringAsFixed(0),
                                Colors.redAccent,
                                Icons.arrow_downward,
                              ),
                              _buildStatCard(
                                context,
                                stats['profit'] >= 0 ? 'Foyda' : 'Zarar',
                                stats['profit'].abs().toStringAsFixed(0),
                                stats['profit'] >= 0 ? Colors.blueAccent : Colors.orangeAccent,
                                stats['profit'] >= 0 ? Icons.trending_up : Icons.trending_down,
                              ),
                            ],
                          );
                        },
                      )),
                    ],
                  ),
                ),
                // Filtrlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filtrlar",
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Mijoz yoki sharh bo‘yicha qidirish',
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
                        onChanged: controller.setSearchQuery,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                                  () => DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Tranzaksiya turi',
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
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                ),
                                value: controller.selectedType.value,
                                dropdownColor: Colors.black.withOpacity(0.9),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                                ),
                                items: [
                                  DropdownMenuItem(value: 'all', child: Text('Barchasi')),
                                  DropdownMenuItem(value: 'debt_sale', child: Text('Qarzga sotuv')),
                                  DropdownMenuItem(value: 'payment', child: Text('To‘lov')),
                                  DropdownMenuItem(value: 'debt_payment', child: Text('Qarz to‘lovi')),
                                  DropdownMenuItem(value: 'return', child: Text('Qaytarish')),
                                  DropdownMenuItem(value: 'income', child: Text('Kirim')),
                                  DropdownMenuItem(value: 'expense', child: Text('Chiqim')),
                                ],
                                onChanged: controller.setType,
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
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                ),
                                value: controller.sortOrder.value,
                                dropdownColor: Colors.black.withOpacity(0.9),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.getFontSize(context, baseSize: 12),
                                ),
                                items: [
                                  DropdownMenuItem(value: 'newest', child: Text('Eng yangi')),
                                  DropdownMenuItem(value: 'oldest', child: Text('Eng eski')),
                                  DropdownMenuItem(value: 'amount_asc', child: Text('Miqdor (o‘sish)')),
                                  DropdownMenuItem(value: 'amount_desc', child: Text('Miqdor (kamayish)')),
                                ],
                                onChanged: controller.setSortOrder,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                                  () => ElevatedButton(
                                onPressed: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: controller.startDate.value ?? DateTime.now(),
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
                                    controller.setStartDate(selectedDate);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  controller.startDate.value == null
                                      ? 'Boshlang‘ich sana'
                                      : 'Boshlang‘ich: ${controller.startDate.value!.toString().substring(0, 10)}',
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
                                    initialDate: controller.endDate.value ?? DateTime.now(),
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
                                    controller.setEndDate(selectedDate);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  controller.endDate.value == null
                                      ? 'Oxirgi sana'
                                      : 'Oxirgi: ${controller.endDate.value!.toString().substring(0, 10)}',
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
                    ],
                  ),
                ),
                // Tranzaksiya turlari statistikasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tranzaksiya turlari bo‘yicha",
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => FutureBuilder<Map<String, Map<String, dynamic>>>(
                        future: controller.typeStatsFuture.value,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: primaryColor),
                            );
                          }
                          final typeStats = snapshot.data ??
                              {
                                'debt_sale': {'total': 0.0, 'count': 0},
                                'payment': {'total': 0.0, 'count': 0},
                                'debt_payment': {'total': 0.0, 'count': 0},
                                'return': {'total': 0.0, 'count': 0},
                                'income': {'total': 0.0, 'count': 0},
                                'expense': {'total': 0.0, 'count': 0},
                              };
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildTypeStatCard(
                                context,
                                'Qarzga sotuv',
                                typeStats['debt_sale']!['total'].toStringAsFixed(0),
                                typeStats['debt_sale']!['count'].toString(),
                                Colors.redAccent,
                              ),
                              _buildTypeStatCard(
                                context,
                                'Naqd to‘lov',
                                typeStats['payment']!['total'].toStringAsFixed(0),
                                typeStats['payment']!['count'].toString(),
                                Colors.greenAccent,
                              ),
                              _buildTypeStatCard(
                                context,
                                'Qarz to‘lovi',
                                typeStats['debt_payment']!['total'].toStringAsFixed(0),
                                typeStats['debt_payment']!['count'].toString(),
                                Colors.blueAccent,
                              ),
                              _buildTypeStatCard(
                                context,
                                'Qaytarish',
                                typeStats['return']!['total'].toStringAsFixed(0),
                                typeStats['return']!['count'].toString(),
                                Colors.orangeAccent,
                              ),
                              _buildTypeStatCard(
                                context,
                                'Kirim',
                                typeStats['income']!['total'].toStringAsFixed(0),
                                typeStats['income']!['count'].toString(),
                                Colors.greenAccent,
                              ),
                              _buildTypeStatCard(
                                context,
                                'Chiqim',
                                typeStats['expense']!['total'].toStringAsFixed(0),
                                typeStats['expense']!['count'].toString(),
                                Colors.redAccent,
                              ),
                            ],
                          );
                        },
                      )),
                    ],
                  ),
                ),
                // Tranzaksiyalar ro‘yxati
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tranzaksiyalar ro‘yxati",
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => FutureBuilder<List<dynamic>>(
                        future: controller.transactionsFuture.value,
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
                          final transactions = snapshot.data ?? [];
                          if (transactions.isEmpty) {
                            return Center(
                              child: Text(
                                "Tranzaksiyalar mavjud emas",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.getFontSize(context, baseSize: 14),
                                ),
                              ),
                            );
                          }

                          // Saralash
                          final sortedTransactions = transactions.toList();
                          if (controller.sortOrder.value == 'amount_asc') {
                            sortedTransactions.sort((a, b) =>
                                (a['amount'] as num).compareTo(b['amount'] as num));
                          } else if (controller.sortOrder.value == 'amount_desc') {
                            sortedTransactions.sort((a, b) =>
                                (b['amount'] as num).compareTo(a['amount'] as num));
                          } else if (controller.sortOrder.value == 'oldest') {
                            sortedTransactions.sort((a, b) => DateTime.parse(a['created_at'])
                                .compareTo(DateTime.parse(b['created_at'])));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: sortedTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = sortedTransactions[index];
                              Color typeColor;
                              String typeLabel;
                              switch (transaction['transaction_type']) {
                                case 'debt_sale':
                                  typeColor = Colors.redAccent;
                                  typeLabel = 'Qarzga sotuv';
                                  break;
                                case 'payment':
                                  typeColor = Colors.greenAccent;
                                  typeLabel = 'To‘lov';
                                  break;
                                case 'debt_payment':
                                  typeColor = Colors.blueAccent;
                                  typeLabel = 'Qarz to‘lovi';
                                  break;
                                case 'return':
                                  typeColor = Colors.orangeAccent;
                                  typeLabel = 'Qaytarish';
                                  break;
                                case 'income':
                                  typeColor = Colors.greenAccent;
                                  typeLabel = 'Kirim';
                                  break;
                                case 'expense':
                                  typeColor = Colors.redAccent;
                                  typeLabel = 'Chiqim';
                                  break;
                                default:
                                  typeColor = Colors.white70;
                                  typeLabel = 'Noma’lum';
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          typeLabel,
                                          style: TextStyle(
                                            color: typeColor,
                                            fontSize:
                                            Responsive.getFontSize(context, baseSize: 14),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${(transaction['amount'] as num).toStringAsFixed(0)} so‘m",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            Responsive.getFontSize(context, baseSize: 14),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      transaction['customers'] != null
                                          ? transaction['customers']['full_name'] ??
                                          'Noma’lum mijoz'
                                          : 'Mijozsiz',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize:
                                        Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    Text(
                                      transaction['sale_id'] != null
                                          ? 'Sotuv ID: ${transaction['sale_id']}'
                                          : 'Sotuvsiz',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize:
                                        Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    Text(
                                      transaction['created_at'] != null
                                          ? transaction['created_at'].substring(0, 16)
                                          : 'Noma’lum vaqt',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize:
                                        Responsive.getFontSize(context, baseSize: 12),
                                      ),
                                    ),
                                    if (transaction['comments'] != null)
                                      Text(
                                        transaction['comments'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize:
                                          Responsive.getFontSize(context, baseSize: 12),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.28
          : 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: Responsive.getFontSize(context, baseSize: 12),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$value so‘m",
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.getFontSize(context, baseSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStatCard(
      BuildContext context,
      String title,
      String total,
      String count,
      Color color,
      ) {
    return Container(
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.45
          : 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: Responsive.getFontSize(context, baseSize: 12),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "$total so‘m",
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.getFontSize(context, baseSize: 12),
            ),
          ),
          Text(
            "$count ta",
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.getFontSize(context, baseSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}