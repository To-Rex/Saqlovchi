// screens/transfers_screen.dart
import 'package:flutter/material.dart';

import '../../constants.dart';


class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ko‘chirishlar", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: defaultPadding),
            const Text("Hozircha ko‘chirishlar mavjud emas"), // Keyinchalik `stock_transactions` dan ma’lumot olinadi
          ],
        ),
      ),
    );
  }
}