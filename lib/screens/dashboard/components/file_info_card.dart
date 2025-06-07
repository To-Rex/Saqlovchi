import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';
import '../../../responsive.dart';

class FileInfoCard extends StatelessWidget {
  final String title;
  final String addedUser;
  final String createdAt;
  final String productCount;
  final String totalQuantity;
  final GetController controller;
  final int categoryId;

  const FileInfoCard({super.key, required this.title, required this.addedUser, required this.createdAt, required this.productCount, required this.totalQuantity, required this.controller, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final isLowStock = (double.tryParse(totalQuantity) ?? 0) < 10;

    return InkWell(
      onTap: () {
        DialogFunction().showCategoryDetailsDialog(context, controller, categoryId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: Responsive.getPadding(context, basePadding: const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.8), isLowStock ? Colors.red.withOpacity(0.6) : primaryColor.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))]
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 14), fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1
                    )
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 14, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        DialogFunction().showEditCategoryDialog(context, controller, {
                          'id': categoryId,
                          'name': title,
                          'created_by': addedUser
                        });
                      } else if (value == 'delete') {
                        DialogFunction().showDeleteCategoryDialog(context, controller, {
                          'id': categoryId,
                          'name': title
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 12, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text('Tahrirlash', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 12, color: Colors.red),
                            const SizedBox(width: 6),
                            Text('O‘chirish', style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12))),
                          ],
                        ),
                      ),
                    ],
                    color: secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding / 4),
              _buildInfoRow(context, 'Mahsulotlar', productCount, maxLines: 1),
              _buildInfoRow(context, 'Miqdor', '$totalQuantity kg', maxLines: 1),
              if (isLowStock)
                Text(
                  'Kam miqdor!',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, baseSize: 10),
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 12),
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: Responsive.getFontSize(context, baseSize: 12), color: Colors.white, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines
            )
          )
        ]
      )
    );
  }
}