import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/controllers/test_screen_controller.dart';
import '../../responsive.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestScreenController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor,
              secondaryColor.withOpacity(0.9),
              secondaryColor.withOpacity(0.7),
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Test ma\'lumotlarini tozalash',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.clearAllData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'Barcha ma\'lumotlarni tozalash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getFontSize(context, baseSize: 16),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}