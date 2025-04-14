import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../libs/function/dialog_function.dart';
import '../../../responsive.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  final GetController controller;
  const MyFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Kategoriyalar", style: Theme.of(context).textTheme.titleMedium),
            Spacer(),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 0.8,
                  vertical: defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                DialogFunction().showAddCategoryDialog(context, controller);
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Yangi kategoriya", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: defaultPadding),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 0.8,
                  vertical: defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                DialogFunction().showAddProductDialog(context, controller);
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Yangi mahsulot", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: size.width < 650 ? 2 : 4,
            childAspectRatio: size.width < 650 && size.width > 350 ? 1.3 : 1,
            controller: controller,
          ),
          tablet: FileInfoCardGridView(controller: controller),
          desktop: FileInfoCardGridView(
            childAspectRatio: size.width < 1400 ? 1.1 : 1.4,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    super.key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
    required this.controller,
  });

  final GetController controller;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.categories.isNotEmpty ? controller.categories.length : 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(
        title: controller.categories[index]['name'],
        addedUser: controller.categories[index]['created_by'] ?? '',
        controller: controller,
      ),
    ));
  }
}