import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../companents/custom_loading_widget.dart';
import '../../../constants.dart';
import '../../../controllers/api_service.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';
import '../../../responsive.dart';
import 'file_info_card.dart';

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
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
          "Kategoriyalar",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: Responsive.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
            children: [
              _buildActionButton(context, label: "Yangi kategoriya", icon: Icons.add, onPressed: () => DialogFunction().showAddCategoryDialog(context, controller)),
              SizedBox(width: defaultPadding / 2),
              _buildActionButton(context, label: "Yangi mahsulot", icon: Icons.add, onPressed: () => DialogFunction().showAddProductDialog(context, controller)),
            ],
        ),
          ],
          ),
            SizedBox(height: defaultPadding),
            FileInfoCardGridView(controller: controller),
          ],
        ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: defaultPadding * 0.8, vertical: defaultPadding / (Responsive.isMobile(context) ? 2 : 1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white, fontSize: Responsive.getFontSize(context, baseSize: 14)))
      )
    );
  }
}


class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({super.key, required this.controller});

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
            childAspectRatio: size.width < 700 ? 1.5 : size.width < 1100 ? 1.7 : 2.0
          ),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final categoryId = category['id'].toString();
            final stats = categoryStats[categoryId] ?? {
              'name': category['name']?.toString() ?? 'Noma’lum',
              'created_by': 'Noma’lum',
              'created_at': 'Noma’lum',
              'product_count': 0,
              'total_quantity': 0.0
            };
            return FileInfoCard(
              title: stats['name'],
              addedUser: stats['created_by'],
              createdAt: stats['created_at'],
              productCount: stats['product_count'].toString(),
              totalQuantity: stats['total_quantity'].toStringAsFixed(2),
              controller: controller,
              categoryId: int.parse(categoryId)
            );
          }
        ));
      }
    );
  }
}