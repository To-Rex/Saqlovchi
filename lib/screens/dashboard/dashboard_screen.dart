import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/api_service.dart';
import '../../controllers/get_controller.dart';
import '../../libs/companents/custom_loading_widget.dart';
import '../../libs/companents/warehouse_stats.dart';
import '../../responsive.dart';
import 'components/header.dart';
import 'components/my_fields.dart';
import 'components/recent_files.dart';
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final GetController controller = Get.put(GetController());
  final ApiService apiService = ApiService();

  Widget _buildWarehouseStats(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: apiService.getWarehouseStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingWidget();
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text("Xato: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }
        return WarehouseStats(stats: snapshot.data!);
      },
    );
  }

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
                      if (Responsive.isMobile(context)) _buildWarehouseStats(context),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context)) const SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: _buildWarehouseStats(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}