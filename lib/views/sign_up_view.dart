import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; 
import '../core/services/language_provider.dart';
import '../core/state/auth_bloc.dart'; 
import 'main_view.dart'; // Жаңы менеджер кабык


class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // Контроллерлордун тартиби аралаштырылды
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LanguageProvider>().changeLanguage('ru');
      }
    });
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Ката билдирүүлөрүн тилге жараша коопсуз таануу
  String _parseSystemError(String originalMessage, String lang) {
    final lowerMessage = originalMessage.toLowerCase();
    if (lang == 'ru') {
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Этот Email уже зарегистрирован!';
      if (lowerMessage.contains('weak_password') || lowerMessage.contains('password should be at least 6 characters')) return 'Пароль слишком простой! Минимум 6 символов.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Неверный формат Email.';
      if (lowerMessage.contains('network')) return 'Ошибка сети. Проверьте internet-соединение.';
    } 
    else if (lang == 'en') {
      if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'This Email is already registered!';
      if (lowerMessage.contains('weak_password') || lowerMessage.contains('password should be at least 6 characters')) return 'Password is too weak! Minimum 6 characters.';
      if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Invalid Email format.';
      if (lowerMessage.contains('network')) return 'Network error. Please check your internet connection.';
    }
    if (lowerMessage.contains('user_already_exists') || lowerMessage.contains('already registered')) return 'Бул Email дарек катталган!';
    if (lowerMessage.contains('weak_password') || lowerMessage.contains('password should be at least 6 characters')) return 'Пароль өтө жөнөкөй! Кеминде 6 символ болушу керек.';
    if (lowerMessage.contains('invalid_email') || lowerMessage.contains('invalid email')) return 'Email дарек туура эмес форматта.';
    if (lowerMessage.contains('network')) return 'Интернет байланышын текшерип, кайра аракет кылыңыз.';
    return originalMessage; 
  }

  // Валидация логикасы
  void _executeSecureRegistration(LanguageProvider langProvider) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('hint_empty')),
          backgroundColor: const Color(0xFFFB7185), // Жумшак кызыл
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('hint_match')),
          backgroundColor: const Color(0xFFFB7185),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(langProvider.currentLang == 'ru'
              ? 'Пароль должен содержать минимум 6 символов.'
              : langProvider.currentLang == 'en'
                  ? 'Password must contain at least 6 characters.'
                  : 'Пароль кеминде 6 символдон турушу керек.'),
          backgroundColor: const Color(0xFFFB7185),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(SignUpRequested(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), // Премиум кочкул боз фон
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          DropdownButton<String>(
            value: currentLang,
            dropdownColor: const Color(0xFF1E252B),
            icon: const Icon(Icons.language, color: Color(0xFF4ADE80), size: 18),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            onChanged: (String? newLang) {
              if (newLang != null) {
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
              MaterialPageRoute(builder: (context) => const MainView()),
            );
          }
          if (state is EmailConfirmationRequired) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email дарегиңизди ырастап, андан кийин кириңиз.'),
                backgroundColor: Color(0xFF4ADE80),
              ),
            );
            Navigator.pop(context);
          }
          if (state is AuthError) {
            final localizedMsg = _parseSystemError(state.message, currentLang);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedMsg), backgroundColor: const Color(0xFFFB7185)),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.fingerprint_rounded, 
                    size: 80,
                    color: Color(0xFF4ADE80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    langProvider.translate('title_signup'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 26, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Коопсуз талаалар
                  _buildSecureField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSecureField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isHide: true,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSecureField(
                    controller: _confirmPasswordController,
                    hint: currentLang == 'ru' ? 'Повторите пароль' : (currentLang == 'en' ? 'Confirm Password' : 'Сырсөздү кайталоо'),
                    icon: Icons.gpp_good_outlined,
                    isHide: true,
                  ),
                  const SizedBox(height: 28),
                  
                  state is AuthLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80))))
                      : InkWell(
                          onTap: () => _executeSecureRegistration(langProvider),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              langProvider.translate('btn_signup'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF12161A), 
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  //  ТҮЗӨТҮЛДҮ: Кичине тамга маселесин чечүүчү универсалдуу кутуча компоненти
  Widget _buildSecureField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,bool isHide = false,}) {
      // Эгер бул Email талаасы болсо, автоматтык баш тамганы жана авто-оңдоону өчүрөбүз
      final isEmail = hint.toLowerCase() == 'email';
      return Container(padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 4),decoration: BoxDecoration(
          color: const Color(0xFF1E252B),borderRadius: BorderRadius.circular(16),),
          child: TextField(controller: controller,obscureText: isHide,autocorrect: !isEmail,
           // Email болсо авто-оңдоону өчүрөт
           enableSuggestions: !isEmail,textCapitalization: isEmail
           ? TextCapitalization.none: TextCapitalization.sentences,
            // Email болсо дайыма КИЧИНЕ тамга менен баштайт
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
             // Email клавиатура түрү
             style: const TextStyle(color: Colors.white),decoration: 
             InputDecoration(icon: Icon(icon, color: const Color(0xFF4ADE80), size: 20),
             border: InputBorder.none,hintText: hint,hintStyle: const TextStyle(
              color: Color(0xFF94A3B8), fontSize: 14),),),);}}
