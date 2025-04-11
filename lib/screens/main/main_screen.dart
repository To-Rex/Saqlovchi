import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/dashboard_screen.dart';
import '../documents/documents_screen.dart';
import '../notifications/notifications_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/tasks_screen.dart';
import '../transfers/transfers_screen.dart';
import '../users.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final String initialPage;

  const MainScreen({super.key, this.initialPage = ''});

  @override
  Widget build(BuildContext context) {
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
    // Joriy sahifa initialPage dan olinadi
    final String currentPage = initialPage;

    switch (currentPage) {
      case 'home':
        return DashboardScreen();
      case 'transfers':
        return const TransfersScreen();
      case 'tasks':
        return const TasksScreen();
      case 'documents':
        return const DocumentsScreen();
      case 'sales':
        return SalesScreen();
      case 'notifications':
        return const NotificationsScreen();
      case 'users':
        return const UsersScreen();
      case 'settings':
        return const SettingsScreen();
      case '':
        return DashboardScreen(); // Default holatda Dashboard
      default:
        return DashboardScreen(); // Agar sahifa topilmasa
    }
  }
}