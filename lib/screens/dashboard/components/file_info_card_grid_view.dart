import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../companents/custom_loading_widget.dart';
import '../../../constants.dart';
import '../../../controllers/api_service.dart';
import '../../../controllers/get_controller.dart';
import '../../../responsive.dart';
import 'file_info_card.dart';

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    super.key,
    required this.controller,
  });

  final GetController controller;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: ApiService().getCategoryStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomLoadingWidget();
        }
        if (snapshot.hasError) {
          print('Snapshot xatosi: ${snapshot.error}');
          return Center(
            child: Text(
              'Ma\'lumotlarni yuklashda xato',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 14),
                color: Colors.white70,
              ),
            ),
          );
        }
        final categoryStats = snapshot.data ?? {};
        return Obx(() => controller.categories.isEmpty
            ? Center(
          child: Text(
            'Kategoriyalar mavjud emas',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 14),
              color: Colors.white70,
            ),
          ),
        )
            : GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: controller.categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getCrossAxisCount(context),
            crossAxisSpacing: defaultPadding / 2,
            mainAxisSpacing: defaultPadding / 2,
            childAspectRatio: size.width < 700
                ? 2.5
                : size.width < 1100
                ? 2.7
                : 3.0, // Balandlikni yanada ko‘paytirish uchun kamaytirdik
          ),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final categoryId = category['id'].toString();
            final stats = categoryStats[categoryId] ?? {
              'name': category['name']?.toString() ?? 'Noma’lum',
              'created_by': 'Noma’lum',
              'created_at': 'Noma’lum',
              'product_count': 0,
              'total_quantity': 0.0,
            };
            return FileInfoCard(
              title: stats['name'],
              addedUser: stats['created_by'],
              createdAt: stats['created_at'],
              productCount: stats['product_count'].toString(),
              totalQuantity: stats['total_quantity'].toStringAsFixed(2),
              controller: controller,
              categoryId: int.parse(categoryId),
            );
          },
        ));
      },
    );
  }
}