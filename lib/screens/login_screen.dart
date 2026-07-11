import 'package:billbuddy/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  String _currentLanguage = 'ky';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getMultiLanguageErrorMessage(String originalMessage) {
    final lowerMessage = originalMessage.toLowerCase();
    if (_currentLanguage == 'ru') {
      if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Неверный Email или пароль!';
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Этот Email уже зарегистрирован!';
      if (lowerMessage.contains('weak_password')) return 'Пароль слишком простой! Минимум 6 символов.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Неверный формат Email.';
      if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'Пользователь не найден.';
      if (lowerMessage.contains('network')) return 'Ошибка сети. Проверьте интернет-соединение.';
    } 
    else if (_currentLanguage == 'en') {
      if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Invalid Email or password!';
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'This Email is already registered!';
      if (lowerMessage.contains('weak_password')) return 'Password is too weak! Minimum 6 characters.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Invalid Email format.';
      if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'User not found.';
      if (lowerMessage.contains('network')) return 'Network error. Please check your internet connection.';
    }
    if (lowerMessage.contains('invalid_credentials') || lowerMessage.contains('invalid login credentials')) return 'Email же пароль туура эмес!';
    if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Бул Email дарек катталган!';
    if (lowerMessage.contains('weak_password')) return 'Пароль өтө жөнөкөй! Кеминде 6 символ болушу керек.';
    if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Email дарек туура эмес форматта.';
    if (lowerMessage.contains('user not found') || lowerMessage.contains('user_not_found')) return 'Мындай колдонуучу табылган жок.';
    if (lowerMessage.contains('network')) return 'Интернет байланышын текшерип, кайра аракет кылыңыз.';
    return originalMessage; 
  }

  String _getInterfaceText(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      'ru': {
        'title_login': 'Вход в приложение',
        'title_signup': 'Регистрация',
        'btn_login': 'Войти',
        'btn_signup': 'Регистрация',
        'hint_empty': 'Заполните все поля!',
        'toggle_to_signup': 'Нет аккаунта? Зарегистрироваться',
        'toggle_to_login': 'Уже есть аккаунт? Войти',
      },
      'en': {
        'title_login': 'Sign In',
        'title_signup': 'Sign Up',
        'btn_login': 'Sign In',
        'btn_signup': 'Sign Up',
        'hint_empty': 'Please fill all fields!',
        'toggle_to_signup': 'Don\'t have an account? Sign Up',
        'toggle_to_login': 'Already have an account? Sign In',
      },
      'ky': {
        'title_login': 'Кирүү',
        'title_signup': 'Регистрация',
        'btn_login': 'Кирүү',
        'btn_signup': 'Катталуу',
        'hint_empty': 'Талааларды толтуруңуз!',
        'toggle_to_signup': 'Аккаунтуңуз жокпу? Регистрациядан өтүңүз',
        'toggle_to_login': 'Аккаунтуңуз барбы? Кирүү барагына өтүңүз',
      }
    };
    return localizedValues[_currentLanguage]?[key] ?? '';
  }
    @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1426), 
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<String>(
                value: _currentLanguage,
                dropdownColor: const Color(0xFF162541),
                icon: const Icon(Icons.language, color: Color(0xFF00E676)),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    setState(() {
                      _currentLanguage = newLanguage;
                    });
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
              final localizedMsg = _getMultiLanguageErrorMessage(state.message);
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
                      _isSignUp ? _getInterfaceText('title_signup') : _getInterfaceText('title_login'),
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
                        labelText: _currentLanguage == 'en' ? 'Password' : 'Пароль',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF162541),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                                        state is AuthLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              if (email.isNotEmpty && password.isNotEmpty) {
                                if (_isSignUp) {
                                  context.read<AuthBloc>().add(SignUpRequested(email: email, password: password));
                                } else {
                                  context.read<AuthBloc>().add(SignInRequested(email: email, password: password));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_getInterfaceText('hint_empty')),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _isSignUp ? _getInterfaceText('btn_signup') : _getInterfaceText('btn_login'),
                              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _emailController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        _isSignUp ? _getInterfaceText('toggle_to_login') : _getInterfaceText('toggle_to_signup'),
                        style: const TextStyle(color: Color(0xFF00E676)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


