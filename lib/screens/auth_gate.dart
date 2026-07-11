import 'package:billbuddy/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Сиздин кирүү экраныңыз
// Сиздин башкы навигация экраныңыз

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase'дин сессия өзгөрүүсүн агым (Stream) аркылуу тыңшайбыз
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Эгер маалыматтар али келе элек болсо, ортосуна жүктөө иконкасын көрсөтөбүз
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1426),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
          );
        }

        // Сессияны текшеребиз
        final session = snapshot.data?.session;

        if (session != null) {
          // Эгер колдонуучу мурун кирген болсо, ДАРОО башкы экран ачылат!
          return const MainNavigationScreen();
        } else {
          // Эгер сессия жок болсо же колдонуучу Профилден "Чыгууну" басса, Логин экраны ачылат
          return const LoginScreen();
        }
      },
    );
  }
}
