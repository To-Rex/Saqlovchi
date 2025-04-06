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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(controller: controller),
                      SizedBox(height: defaultPadding),
                      RecentFiles(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        FutureBuilder<Map<String, dynamic>>(
                          future: apiService.getWarehouseStats(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CustomLoadingWidget();
                            }
                            if (snapshot.hasError) {
                              return Text("Xato: ${snapshot.error}");
                            }
                            return WarehouseStats(stats: snapshot.data!);
                          },
                        ),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: apiService.getWarehouseStats(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CustomLoadingWidget();
                        }
                        if (snapshot.hasError) {
                          return Text("Xato: ${snapshot.error}");
                        }
                        return WarehouseStats(stats: snapshot.data!);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}