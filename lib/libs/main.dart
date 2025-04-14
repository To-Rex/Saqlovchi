import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sklad/libs/pages/auth/login_page.dart';
import 'package:sklad/libs/pages/auth/sign_up_page.dart';
import 'package:sklad/libs/pages/samples/sample_page.dart';
import 'package:sklad/libs/resource/srting.dart';
import 'package:sklad/screens/dashboard/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sklad/controllers/get_controller.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_web_plugins/url_strategy.dart';


void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await Supabase.initialize(
    url: 'https://kzlqfcfrcybhrmvujoye.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bHFmY2ZyY3liaHJtdnVqb3llIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4ODAwMjYsImV4cCI6MjA1NzQ1NjAyNn0.Rz3uCmYjDHFWH18xBt0vPFa2q0Sdocm3LLuPHukiwpY',
  );

  // GetController’ni global darajada instansiya qilish
  Get.put(GetController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Online Shop',
          theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Schyler'),
          translations: LocaleString(),
          locale: Get.find<GetController>().language,
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => LoginPage()),
            GetPage(name: '/home', page: () => SamplePage()),
            //GetPage(name: '/home', page: () => HomePage()),
            GetPage(name: '/signup', page: () => SignUpPage()),
          ],
        );
      },
    );
  }

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => DashboardScreen(),
      ),
      GoRoute(
        path: '/:page',
        builder: (context, state) {
          final page = state.pathParameters['page'];
          html.window.history.replaceState(null, '', '/$page');
          return DashboardScreen();
        },
      ),
    ],
  );
}