import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';

class FileInfoCard extends StatelessWidget {
  final String title;
  final String addedUser;
  final String productCount;
  final String totalQuantity;
  final GetController controller;

  const FileInfoCard({
    super.key,
    required this.title,
    required this.addedUser,
    required this.productCount,
    required this.totalQuantity,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Column o‘lchamini minimallashtirish
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4), // Bo‘sh joyni qisqartirish
          Text(
            'Yaratuvchi: $addedUser',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Mahsulotlar: $productCount',
            style: TextStyle(fontSize: 12, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Qoldiq: $totalQuantity',
            style: TextStyle(fontSize: 12, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}