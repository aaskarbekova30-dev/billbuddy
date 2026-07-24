import 'package:billbuddy/main_navigation_screen.dart';
import 'package:billbuddy/logic/providers/language_provider.dart'; // 🌟 Импорт кошулду
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // 🌟 Провайдер үчүн импорт
import '../logic/bloc/auth_bloc.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Ката билдирүүлөрү глобалдык тилди түз колдонот
  String _getMultiLanguageErrorMessage(String originalMessage, String lang) {
    final lowerMessage = originalMessage.toLowerCase();
    if (lang == 'ru') {
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Этот Email уже зарегистрирован!';
      if (lowerMessage.contains('weak_password')) return 'Пароль слишком простой! Минимум 6 символов.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Неверный формат Email.';
      if (lowerMessage.contains('network')) return 'Ошибка сети. Проверьте internet-соединение.';
    } 
    else if (lang == 'en') {
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'This Email is already registered!';
      if (lowerMessage.contains('weak_password')) return 'Password is too weak! Minimum 6 characters.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Invalid Email format.';
      if (lowerMessage.contains('network')) return 'Network error. Please check your internet connection.';
    }
    if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Бул Email дарек катталган!';
    if (lowerMessage.contains('weak_password')) return 'Пароль өтө жөнөкөй! Кеминде 6 символ болушу керек.';
    if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Email дарек туура эмес форматта.';
    if (lowerMessage.contains('network')) return 'Интернет байланышын текшерип, кайра аракет кылыңыз.';
    return originalMessage; 
  }

  String _getInterfaceText(String key, String lang) {
    final Map<String, Map<String, String>> localizedValues = {
      'ru': {
        'title_signup': 'Регистрация',
        'hint_empty': 'Заполните все поля!',
        'hint_match': 'Пароли не совпадают!',
        'btn_signup': 'Зарегистрироваться',
      },
      'en': {
        'title_signup': 'Sign Up',
        'hint_empty': 'Please fill all fields!',
        'hint_match': 'Passwords do not match!',
        'btn_signup': 'Sign Up',
      },
      'ky': {
        'title_signup': 'Катталуу',
        'hint_empty': 'Талааларды толтуруңуз!',
        'hint_match': 'Сырсөздөр biри-бирине дал келген жок!',
        'btn_signup': 'Катталуу',
      }
    };
    return localizedValues[lang]?[key] ?? '';
  }

  void _completeRegistration(LanguageProvider langProvider) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getInterfaceText('hint_empty', langProvider.currentLang)),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getInterfaceText('hint_match', langProvider.currentLang)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(SignUpRequested(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    // Глобалдык тил провайдерин чакырабыз
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1426), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          DropdownButton<String>(
            value: currentLang,
            dropdownColor: const Color(0xFF162541),
            icon: const Icon(Icons.language, color: Color(0xFF00E676), size: 18),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            onChanged: (String? newLang) {
              if (newLang != null) {
                // 🛠️ СИНХРОНДУУ ОҢДОЛДУ: Тил провайдер аркылуу өзгөрөт
                langProvider.changeLanguage(newLang);
              }
            },
            items: const [
              DropdownMenuItem(value: 'ky', child: Text(' KG ')),
              DropdownMenuItem(value: 'ru', child: Text(' RU ')),
              DropdownMenuItem(value: 'en', child: Text(' EN ')),
            ],
          ),
          const SizedBox(width: 16),
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
              child: _buildRegisterForm(state, langProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterForm(AuthState state, LanguageProvider langProvider) {
    final currentLang = langProvider.currentLang;

    String emailLabel = "Email дарек";
    String passwordLabel = "Сырсөз (Password)";
    String confirmPasswordLabel = "Сырсөздү кайталоо";

    if (currentLang == 'ru') {
      emailLabel = "Email адрес";
      passwordLabel = "Пароль";
      confirmPasswordLabel = "Повторите пароль";
    } else if (currentLang == 'en') {
      emailLabel = "Email Address";
      passwordLabel = "Password";
      confirmPasswordLabel = "Confirm Password";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Color(0xFF00E676)),
        const SizedBox(height: 16),
        Text(
          _getInterfaceText('title_signup', currentLang),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: emailLabel,
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
            labelText: passwordLabel,
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF162541),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: confirmPasswordLabel,
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF162541),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        state is AuthLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              )
            : ElevatedButton(
                onPressed: () => _completeRegistration(langProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                _getInterfaceText('btn_signup', currentLang),style: const TextStyle(
                  color: Color(0xFF0B1426), fontSize: 16, 
                  fontWeight: FontWeight.bold),),),],);}}  
