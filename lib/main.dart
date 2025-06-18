import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';
import 'utils/constants.dart';
import 'screens/landing/landing_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/auth/forgot_password_page.dart';
import 'screens/auth/reset_password_page.dart';
import 'screens/lojista/lojista_homepage.dart';
import 'screens/tutor/tutor_homepage.dart';
import 'screens/veterinario/vet_homepage.dart';
import 'screens/admin/admin_homepage.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'Pet Conect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
      ),
    );
  }

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: Routes.landing,
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: Routes.lojista,
        builder: (context, state) => const LojistaHomepage(),
      ),
      GoRoute(
        path: Routes.tutor,
        builder: (context, state) => const TutorHomepage(),
      ),
      GoRoute(
        path: Routes.veterinario,
        builder: (context, state) => const VetHomepage(),
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminHomepage(),
      ),
    ],
    redirect: (context, state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = authService.isLoggedIn;
      final currentUser = authService.currentUser;
      
      // Se não estiver logado e tentar acessar páginas protegidas
      if (!isLoggedIn && state.fullPath != Routes.landing && 
          state.fullPath != Routes.login && state.fullPath != Routes.register &&
          state.fullPath != Routes.forgotPassword && state.fullPath != Routes.resetPassword) {
        return Routes.landing;
      }
      
      // Se estiver logado e estiver na landing page, redirecionar para a página correta
      if (isLoggedIn && currentUser != null && state.fullPath == Routes.landing) {
        switch (currentUser.userType) {
          case Constants.adminType:
            return Routes.admin;
          case Constants.lojistaType:
            return Routes.lojista;
          case Constants.veterinarioType:
            return Routes.veterinario;
          case Constants.tutorType:
          default:
            return Routes.tutor;
        }
      }
      
      // Se estiver logado e tentar acessar páginas de auth, redirecionar para a página correta
      if (isLoggedIn && currentUser != null && 
          (state.fullPath == Routes.login || state.fullPath == Routes.register ||
           state.fullPath == Routes.forgotPassword || state.fullPath == Routes.resetPassword)) {
        switch (currentUser.userType) {
          case Constants.adminType:
            return Routes.admin;
          case Constants.lojistaType:
            return Routes.lojista;
          case Constants.veterinarioType:
            return Routes.veterinario;
          case Constants.tutorType:
          default:
            return Routes.tutor;
        }
      }
      
      return null;
    },
  );
}