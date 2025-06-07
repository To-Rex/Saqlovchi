import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/get_controller.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../documents/documents_screen.dart';
import '../expenses/expenses_page.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_screen.dart';
import '../transfers/transactions_screen.dart';
import '../users.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final String initialPage;

  const MainScreen({super.key, this.initialPage = ''});

  @override
  Widget build(BuildContext context) {
    print('MainScreen ochildi: initialPage=$initialPage'); // Log qo‘shish
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: _buildMainContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final String currentPage = initialPage;
    final controller = Get.find<GetController>();
    final role = controller.role.value;

    print('Sahifa tanlanmoqda: currentPage=$currentPage, role=$role'); // Log qo‘shish

    // Seller roli uchun /home ga kirish cheklanadi
    if (role == 'seller' && currentPage == 'home') {
      print('Seller home sahifasiga kirdi, SalesScreen ga yo‘naltirilmoqda');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).replace('/sales');
      });
      return SalesScreen(); // Vaqtincha SalesScreen ko‘rsatiladi
    }

    switch (currentPage) {
      case 'home':
        return DashboardScreen(); // Admin va manager uchun DashboardScreen
      case 'transfers':
        return TransactionsScreen();
      case 'documents':
        return const DocumentsScreen();
      case 'sales':
        return SalesScreen();
      case 'users':
        return const UsersScreen();
        case 'expenses':
        return ExpensesPage();
      case 'settings':
        return SettingsScreen();
      case '':
        return role == 'seller' ? SalesScreen() : DashboardScreen(); // Default holat
      default:
        return role == 'seller' ? SalesScreen() : DashboardScreen(); // Agar sahifa topilmasa
    }
  }
}