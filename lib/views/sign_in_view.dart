import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../core/services/language_provider.dart';
import '../core/services/supabase_provider.dart'; 


class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Көп тилдүү интерфейс маалыматтары бирдиктүү коопсуз базага жыйналды (Роботтор үчүн)
  String _fetchSecureText(String key, String lang) {
    final Map<String, Map<String, String>> securePack = {
      'ru': {
        'title_login': 'Тиркемеге кирүү',
        'hint_empty_email': 'Введите ваш Email!',
        'hint_empty_pass': 'Пароль должен быть не менее 6 символов!',
        'btn_login': 'Войти',
        'success_msg': 'Успешно вошли!',
        'error_msg': 'Ошибка: Почта или пароль неверны!',
        'hint_email': 'Электронная почта',
        'hint_pass': 'Пароль',
      },
      'en': {
        'title_login': 'Sign In',
        'hint_empty_email': 'Please enter your Email!',
        'hint_empty_pass': 'Password must be at least 6 characters!',
        'btn_login': 'Sign In',
        'success_msg': 'Successfully logged in!',
        'error_msg': 'Error: Invalid Email or password!',
        'hint_email': 'Email Address',
        'hint_pass': 'Password',
      },
      'ky': {
        'title_login': 'Тиркемеге кирүү',
        'hint_empty_email': 'Email дарегиңизди жазыңыз!',
        'hint_empty_pass': 'Пароль кеминде 6 тамгадан турушу керек!',
        'btn_login': 'Кирүү',
        'success_msg': 'Ийгиликтүү кирдиңиз!',
        'error_msg': 'Ката: Почта же пароль туура эмес!',
        'hint_email': 'Email дарек',
        'hint_pass': 'Сырсөз',
      }
    };
    return securePack[lang]?[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Жандуу жүктөө маалымдоосун жана тилди угуу
    final authProvider = context.watch<SupabaseProvider>();
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), // Премиум негизги терең фон
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'BillBuddy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4ADE80), // Биздин тандаган жалбыз жашыл түс
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fetchSecureText('title_login', currentLang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  //  EMAIL ТАЛААСЫ (Жаңы премиум кооз капсула стилине өзгөрдү)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E252B), // Жаңы жумшак боз карточка фону
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none, // Эски Outline сызыктары толук алынды
                        hintText: _fetchSecureText('hint_email', currentLang),
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4ADE80), size: 22),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _fetchSecureText('hint_empty_email', currentLang);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ПАРОЛЬ ТАЛААСЫ (Сызыксыз кооз капсула стилинде)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E252B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _fetchSecureText('hint_pass', currentLang),
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4ADE80), size: 22),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return _fetchSecureText('hint_empty_pass', currentLang);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // КИРҮҮ БАСКЫЧЫ (Премиум жалбыз жашыл жана жүктөө индикатору менен)
                  SizedBox(
                    height: 52,
                    child: InkWell(
                      onTap: authProvider.isLoading 
                          ? null 
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final success = await context.read<SupabaseProvider>().signIn(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_fetchSecureText('success_msg', currentLang)),
                                        backgroundColor: const Color(0xFF4ADE80),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${_fetchSecureText('error_msg', currentLang)} $e'),
                                        backgroundColor: const Color(0xFFFB7185),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: authProvider.isLoading ? const Color(0xFF1E252B) : const Color(0xFF4ADE80),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: authProvider.isLoading ? [] : [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: authProvider.isLoading 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _fetchSecureText('btn_login', currentLang),
                                style: const TextStyle(fontSize: 16,fontWeight: 
                                FontWeight.bold,color: Color(0xFF12161A),
                                ),),),),),],),),),),),);}}
                                 // Кочкул боз текст
