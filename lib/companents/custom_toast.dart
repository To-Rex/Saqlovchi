import 'package:flutter/material.dart';

class CustomToast {
  // Toast turlarini aniqlash uchun konstantalar
  static const int normal = 1;
  static const int success = 2;
  static const int error = 3;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required int type,
    int durationInSeconds = 3,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: _ToastWidget(
            title: title,
            message: message,
            type: type,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Belgilangan vaqtdan keyin toastni o'chirish
    Future.delayed(Duration(seconds: durationInSeconds), () {
      overlayEntry.remove();
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final int type;

  const _ToastWidget({
    required this.title,
    required this.message,
    required this.type,
  });

  // Toast turiga qarab rang va ikonani aniqlash
  Color _getBackgroundColor() {
    switch (type) {
      case CustomToast.success:
        return Colors.green.shade600;
      case CustomToast.error:
        return Colors.red.shade600;
      case CustomToast.normal:
      default:
        return Colors.black54;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case CustomToast.success:
        return Icons.check_circle;
      case CustomToast.error:
        return Icons.error;
      case CustomToast.normal:
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikonka
          Padding(
            padding: EdgeInsets.only(right: 12.0, top: 4.0),
            child: Icon(
              _getIcon(),
              color: Colors.white,
              size: 24.0,
            ),
          ),
          // Matnlar
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
              ),
          ),
        ],
      ),
    );
  }
}