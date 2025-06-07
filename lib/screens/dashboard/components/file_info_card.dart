import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';
import '../../../responsive.dart';

/// Kategoriya ma'lumotlari kartasi
class FileInfoCard extends StatelessWidget {
  final String title;
  final String addedUser;
  final String createdAt;
  final String productCount;
  final String totalQuantity;
  final GetController controller;
  final int categoryId;

  const FileInfoCard({
    super.key,
    required this.title,
    required this.addedUser,
    required this.createdAt,
    required this.productCount,
    required this.totalQuantity,
    required this.controller,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = (double.tryParse(totalQuantity) ?? 0) < 10;

    return InkWell(
      onTap: () => DialogFunction().showCategoryDetailsDialog(context, controller, categoryId),
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.blue.shade200.withOpacity(0.3),
      highlightColor: Colors.blue.shade100.withOpacity(0.2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: Responsive.getPadding(
          context,
          basePadding: const EdgeInsets.all(defaultPadding / 3),
        ),
        decoration: BoxDecoration(
          color: isLowStock ? Colors.red.shade700.withOpacity(0.05) : Colors.blue.shade800.withOpacity(0.05),
          border: Border.all(
            color: isLowStock ? Colors.red.shade400 : Colors.blue.shade600,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Responsive.isMobile(context) ? 80 : 100,
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
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
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, baseSize: 13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    _buildPopupMenu(context, isLowStock),
                  ],
                ),
                SizedBox(height: defaultPadding / 6),
                _buildInfoRow(context, 'Mahsulotlar', productCount),
                _buildInfoRow(context, 'Miqdor', '$totalQuantity kg'),
                if (isLowStock) _buildLowStockBadge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Popup menyuni yaratuvchi funksiya
  Widget _buildPopupMenu(BuildContext context, bool isLowStock) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: Responsive.getFontSize(context, baseSize: 14),
        color: Colors.white.withOpacity(0.8),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          DialogFunction().showEditCategoryDialog(context, controller, {
            'id': categoryId,
            'name': title,
            'created_by': addedUser,
          });
        } else if (value == 'delete') {
          DialogFunction().showDeleteCategoryDialog(context, controller, {
            'id': categoryId,
            'name': title,
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: Responsive.getFontSize(context, baseSize: 11),
                color: Colors.blue.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'Tahrirlash',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 11),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: Responsive.getFontSize(context, baseSize: 11),
                color: Colors.red.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'O‘chirish',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, baseSize: 11),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
      color: secondaryColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  /// Ma'lumot qatorini yaratuvchi funksiya
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, baseSize: 11),
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, baseSize: 11),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Kam miqdor badge'ini yaratuvchi funksiya
  Widget _buildLowStockBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 4,
        vertical: defaultPadding / 6,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Kam miqdor!',
        style: TextStyle(
          fontSize: Responsive.getFontSize(context, baseSize: 9),
          color: Colors.red.shade400,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}