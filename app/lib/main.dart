import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwms/providers/auth_provider.dart';
import 'package:smartwms/providers/theme_provider.dart';
import 'package:smartwms/pages/auth/login_page.dart';
import 'package:smartwms/pages/home/main_page.dart';

void main() {
  runApp(const SmartWMSApp());
}

class SmartWMSApp extends StatelessWidget {
  const SmartWMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SmartWMS',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF165DFF),
              primaryColorLight: const Color(0xFF4080FF),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF165DFF),
                primary: const Color(0xFF165DFF),
                secondary: const Color(0xFF722ED1),
                surface: const Color(0xFFF2F3F5),
              ),
              scaffoldBackgroundColor: const Color(0xFFF2F3F5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1D2129),
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E6EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E6EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF165DFF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF165DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF165DFF),
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF165DFF),
                unselectedItemColor: Color(0xFF86909C),
                type: BottomNavigationBarType.fixed,
                elevation: 8,
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFFE5E6EB),
                thickness: 1,
              ),
              fontFamily: 'PingFang SC',
            ),
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return authProvider.isLoggedIn ? const MainPage() : const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
