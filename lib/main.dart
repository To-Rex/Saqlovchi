import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sklad/controllers/api_service.dart';
import 'package:sklad/screens/main/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'controllers/get_controller.dart';
import 'controllers/menu_app_controller.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'libs/pages/auth/login_page.dart';
import 'libs/resource/srting.dart';

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

// Define the router
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/', // Root yo‘li
      builder: (context, state) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuAppController()),
        ],
        child: const MainScreen(initialPage: ''), // Default bo‘sh sahifa
      ),
    ),
    GoRoute(
      path: '/:page', // Dinamik sahifa parametri
      builder: (context, state) {
        final page = state.pathParameters['page'] ?? '';
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => MenuAppController()),
          ],
          child: MainScreen(initialPage: page),
        );
      },
    ),
  ],

  redirect: (context, state) async {
    final suPaBase = Supabase.instance.client;
    final session = suPaBase.auth.currentSession;

    if (session == null && state.uri.toString() != '/login') {
      return '/login';
    }
    if (session != null && state.uri.toString() == '/login') {
      return '/';
    }
    return null;
  },
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Supabase.initialize(
    url: 'https://kzlqfcfrcybhrmvujoye.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bHFmY2ZyY3liaHJtdnVqb3llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4ODAwMjYsImV4cCI6MjA1NzQ1NjAyNn0.Rz3uCmYjDHFWH18xBt0vPFa2q0Sdocm3LLuPHukiwpY',
  );

  Get.put(GetController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Saqlovchi',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      translations: LocaleString(),
      locale: Get.find<GetController>().language,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}