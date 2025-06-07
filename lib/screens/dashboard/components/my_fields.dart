import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../companents/custom_loading_widget.dart';
import '../../../constants.dart';
import '../../../controllers/api_service.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';
import '../../../responsive.dart';
import 'file_info_card.dart';

/// Kategoriyalar va mahsulotlarni boshqarish uchun asosiy widget
class MyFiles extends StatelessWidget {
  final GetController controller;

  const MyFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.getPadding(context, basePadding: const EdgeInsets.all(defaultPadding)),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), const SizedBox(height: defaultPadding), CategoryGridView(controller: controller)]
      )
    );
  }

  /// Sarlavha va amal tugmalarini ko'rsatuvchi qism
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Kategoriyalar", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: Responsive.getFontSize(context, baseSize: 18), fontWeight: FontWeight.bold, color: Colors.white)),
        Row(
          children: [
            _buildActionButton(context, label: "Yangi kategoriya", icon: Icons.add, onPressed: () => DialogFunction().showAddCategoryDialog(context, controller), isFilled: true),
            SizedBox(width: Responsive.isMobile(context) ? defaultPadding / 3 : defaultPadding / 2),
            _buildActionButton(context, label: "Yangi mahsulot", icon: Icons.add, onPressed: () => DialogFunction().showAddProductDialog(context, controller), isFilled: false)
          ]
        )
      ]
    );
  }

  /// Harakat tugmasini yaratuvchi yordamchi funksiya
  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed, required bool isFilled}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.blue.shade200.withOpacity(0.3),
        highlightColor: Colors.blue.shade100.withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? defaultPadding / 2 : defaultPadding * 0.75, vertical: Responsive.isMobile(context) ? defaultPadding / 4 : defaultPadding / 3),
          decoration: BoxDecoration(
            color: isFilled ? Colors.blue.shade700 : Colors.transparent,
            border: Border.all(color: Colors.blue.shade700, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isFilled ? [BoxShadow(color: Colors.blue.shade700.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),] : null
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: Responsive.getFontSize(context, baseSize: 16), color: Colors.white),
              SizedBox(width: defaultPadding / 4),
              Text(label, style: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 13), fontWeight: FontWeight.w600))
            ]
          )
        )
      )
    );
  }
}

/// Kategoriyalarni grid ko'rinishida ko'rsatuvchi widget
class CategoryGridView extends StatelessWidget {
  final GetController controller;

  const CategoryGridView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: ApiService().getCategoryStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingWidget();
        }
        if (snapshot.hasError) {
          debugPrint('Snapshot xatosi: ${snapshot.error}');
          return _buildErrorMessage(context);
        }
        final categoryStats = snapshot.data ?? {};
        return Obx(() => controller.categories.isEmpty ? _buildEmptyMessage(context) : _buildCategoryGrid(context, categoryStats, size)
        );
      }
    );
  }

  /// Xato xabarini ko'rsatuvchi widget
  Widget _buildErrorMessage(BuildContext context) {
    return Center(child: Text('Ma\'lumotlarni yuklashda xato', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 14), color: Colors.white70)));
  }

  /// Kategoriyalar mavjud emasligi haqidagi xabar
  Widget _buildEmptyMessage(BuildContext context) {
    return Center(child: Text('Kategoriyalar mavjud emas', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 14), color: Colors.white70)));
  }

  /// Kategoriyalar gridini yaratuvchi widget
  Widget _buildCategoryGrid(
      BuildContext context,
      Map<String, Map<String, dynamic>> categoryStats,
      Size size,
      ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.getCrossAxisCount(context),
        crossAxisSpacing: Responsive.isMobile(context) ? defaultPadding / 4 : defaultPadding / 2,
        mainAxisSpacing: Responsive.isMobile(context) ? defaultPadding / 4 : defaultPadding / 2,
        childAspectRatio: size.width < 600 ? 1.3 : size.width < 900 ? 1.5 : size.width < 1200 ? 1.7 : 2.0,
      ),
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        final categoryId = category['id'].toString();
        final stats = categoryStats[categoryId] ?? {'name': category['name']?.toString() ?? 'Noma’lum', 'created_by': 'Noma’lum', 'created_at': 'Noma’lum', 'product_count': 0, 'total_quantity': 0.0};
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
    );
  }
}