import 'package:billbuddy/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Кирүү экраныңыз
// Башкы экраныңыз

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Супабейс сессиясын Stream (агым) аркылуу автоматтык түрдө тыңшайбыз
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1426),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // Колдонуучу мурун кирген болсо, түз эле Башкы экран ачылат
          return const MainNavigationScreen();
        } else {
          // Колдонуучу кире элек болсо же Профилден "Чыгууну" басса, Логин экраны ачылат
          return const LoginScreen();
        }
      },
    );
  }
}
