import 'package:billbuddy/main_navigation_screen.dart';
import 'package:billbuddy/logic/providers/language_provider.dart'; // 🌟 Импорт кошулду
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // 🌟 Провайдер үчүн импорт
import '../logic/bloc/auth_bloc.dart';
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Каталар глобалдык тилге (lang) жараша аныкталат
  String _getMultiLanguageErrorMessage(String originalMessage, String lang) {
    final lowerMessage = originalMessage.toLowerCase();
    if (lang == 'ru') {
      if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Неверный Email или пароль!';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Неверный формат Email.';
      if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'Пользователь не найден.';
      if (lowerMessage.contains('network')) return 'Ошибка сети. Проверьте internet-соединение.';
    } 
    else if (lang == 'en') {
      if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Invalid Email or password!';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Invalid Email format.';
      if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'User not found.';
      if (lowerMessage.contains('network')) return 'Network error. Please check your internet connection.';
    }
    if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Email же пароль туура эмес!';
    if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Email дарек туура эмес форматта.';
    if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'Мындай колдонуучу табылган жок.';
    if (lowerMessage.contains('network')) return 'Интернет байланышын текшерип, кайра аракет кылыңыз.';
    return originalMessage; 
  }

  // Интерфейс тексттери глобалдык тилди угат
  String _getInterfaceText(String key, String lang) {
    final Map<String, Map<String, String>> localizedValues = {
      'ru': {
        'title_login': 'Вход в приложение',
        'btn_login': 'Войти',
        'hint_empty': 'Заполните все поля!',
        'toggle_to_signup': 'Нет аккаунта? Зарегистрироваться',
      },
      'en': {
        'title_login': 'Sign In',
        'btn_login': 'Sign In',
        'hint_empty': 'Please fill all fields!',
        'toggle_to_signup': 'Don\'t have an account? Sign Up',
      },
      'ky': {
        'title_login': 'Кирүү',
        'btn_login': 'Кирүү',
        'hint_empty': 'Талааларды толтуруңуз!',
        'toggle_to_signup': 'Аккаунтуңуз жокпу? Регистрациядан өтүңүз',
      }
    };
    return localizedValues[lang]?[key] ?? '';
  }
    @override
  Widget build(BuildContext context) {
    // Глобалдык тил провайдерин угабыз
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1426), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: currentLang,
              dropdownColor: const Color(0xFF162541),
              icon: const Icon(Icons.language, color: Color(0xFF00E676)),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  // 🛠️ СИНХРОНДУУ ОҢДОЛДУ: Тилди провайдер аркылуу өзгөртөбүз
                  langProvider.changeLanguage(newLanguage);
                }
              },
              items: const [
                DropdownMenuItem(value: 'ky', child: Text('Кыргызча ')),
                DropdownMenuItem(value: 'ru', child: Text('Русский ')),
                DropdownMenuItem(value: 'en', child: Text('English ')),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            );
          }
          if (state is AuthError) {
            final localizedMsg = _getMultiLanguageErrorMessage(state.message, currentLang);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedMsg), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Color(0xFF00E676),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getInterfaceText('title_login', currentLang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF162541),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF162541),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                                    // Кирүү баскычы жана Жүктөө анимациясы
                  state is AuthLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                      : ElevatedButton(
                          onPressed: () {
                            if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getInterfaceText('hint_empty', currentLang)), 
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                              SignInRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _getInterfaceText('btn_login', currentLang),
                            style: const TextStyle(color: Color(0xFF0B1426), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                  const SizedBox(height: 16),
                  
                  // Катталуу барагына түз өтүүчү баскыч
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      _getInterfaceText('toggle_to_signup', currentLang),
                      style: const TextStyle(color: Color(0xFF00E676)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


