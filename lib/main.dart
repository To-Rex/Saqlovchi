import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
      path: '/',
      builder: (context, state) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuAppController()),
        ],
        child: MainScreen(),
      ),
    ),
  ],
  redirect: (context, state) async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    // If no session and trying to access protected route, redirect to login
    if (session == null && state.uri.toString() != '/login') {
      return '/login';
    }
    // If session exists and trying to access login, redirect to home
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Online Shop',
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