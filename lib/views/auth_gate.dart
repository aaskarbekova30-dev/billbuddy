import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:billbuddy/views/sign_in_view.dart';
import 'main_view.dart';               

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF12161A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4ADE80),
              ),
            ),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const MainView();
        } else {
          return const SignInView();
        }
      },
    );
  }
}
