import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billbuddy/views/sign_in_view.dart';
import 'main_view.dart';               
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Супабейс сессиясын Stream (агым) аркылуу автоматтык түрдө тыңшайбыз
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Күтүү убактысында тиркеменин жаңы премиум стилиндеги жүктөө экраны чыгат
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF12161A), // Премиум кочкул боз фон
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4ADE80), // Биздин жалбыз жашыл түс
              ),
            ),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // Колдонуучу мурун кирген болсо, түз эле Башкы экран ачылат
          return const MainView(); // Же сиздин башкы навигация файлыңыздын жаңы аты
        } else {
          // Колдонуучу кире элек болсо же Профилден "Чыгууну" басса, Логин экраны ачылат
          return const SignInView();
        }
      },
    );
  }
}
