import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import '../../../controllers/get_controller.dart';
import '../../../function/dialog_function.dart';

class FileInfoCard extends StatelessWidget {
  final String title;
  final String addedUser;
  final GetController controller;

  const FileInfoCard({super.key, required this.title, required this.addedUser, required this.controller});


  @override
  Widget build(BuildContext context) {
    final category = controller.categories.firstWhere((element) => element['name'] == title);
    final creator = category['users'] ?? {};
    return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: EdgeInsets.all(defaultPadding * 0.75),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                      child: SvgPicture.asset('assets/icons/menu_doc.svg', colorFilter: ColorFilter.mode(Colors.white,BlendMode.srcIn))
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    onSelected: (value) {
                      if (value == 'edit') {
                        DialogFunction().showEditCategoryDialog(context, controller, category);
                      } else if (value == 'delete') {
                        DialogFunction().showDeleteCategoryDialog(context, controller, category);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
                      const PopupMenuItem(value: 'delete', child: Text('O‘chirish')),
                    ],
                  ),
                ],
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              Text(
                'Qo‘shgan: ${creator['full_name'] ?? 'Noma\'lum'}',
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ]
        )
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, this.color = primaryColor, required this.percentage,});

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
