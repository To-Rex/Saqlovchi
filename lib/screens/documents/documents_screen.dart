import 'package:flutter/material.dart';
import 'package:sklad/constants.dart';
import 'package:sklad/screens/documents/customers_screen.dart';
import 'package:sklad/responsive.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CustomersScreen()
    );
  }
}