import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../companents/ware_house_stats.dart';
import '../../constants.dart';
import '../../controllers/api_service.dart';
import '../../controllers/get_controller.dart';
import '../../responsive.dart';
import 'components/header.dart';
import 'components/my_fields.dart';
import 'components/recent_files.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final GetController controller = Get.put(GetController());
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(controller: controller),
                      const SizedBox(height: defaultPadding),
                      RecentFiles(),
                      if (Responsive.isMobile(context)) const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) WarehouseStats(stats: {}),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context)) const SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: WarehouseStats(stats: {}),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}