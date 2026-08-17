import 'package:billbuddy/views/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../core/services/language_provider.dart';
import '../../core/services/supabase_provider.dart'; 

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState(); 
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<SupabaseProvider>();
    final langProvider = Provider.of<LanguageProvider>(context);

    // Тилди автоматтык башкаруу (Кыргызча/Орусча/Англисче)
    String getTxt(String key, String defaultText) {
      final translated = langProvider.translate(key);
      return (translated.isEmpty || translated == key) ? defaultText : translated;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), 
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
                      color: Color(0xFF4ADE80), 
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getTxt('title_login', 'Тиркемеге кирүү'), 
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ТАЛАА: EMAIL
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E252B), 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none, 
                        hintText: getTxt('hint_email', 'Электрондук почта'),
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4ADE80), size: 22),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return getTxt('hint_empty_email', 'Введите ваш Email!');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ТАЛАА: ПАРОЛЬ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E252B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure, 
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: getTxt('hint_pass', 'Сырсөз'),
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4ADE80), size: 22),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return getTxt('hint_empty_pass', 'Введите пароль!');
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // СЫРСӨЗДҮ УНУТТУҢУЗБУ?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(getTxt('hint_empty_email', 'Введите ваш Email!')),
                                    backgroundColor: const Color(0xFFFFB785),
                                  ),
                                );
                                return;
                              }

                              try {
                                await authProvider.resetPassword(email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(getTxt('msg_reset_sent', 'Ссылка для сброса пароля отправлена на вашу почту!')),
                                      backgroundColor: const Color(0xFF4ADE80),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ошибка: ${e.toString()}'),
                                      backgroundColor: const Color(0xFFFFB785),
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text(
                        getTxt('link_forgot_pass', 'Забыли пароль?'),
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // БАСКЫЧ: КИРҮҮ (SIGN IN)
                  SizedBox(
                    height: 52,
                    child: Material( 
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          debugPrint("Кнопка 'Войти' была нажата!");
                          
                          if (authProvider.isLoading) {
                            debugPrint("Кнопка заблокирована: идет загрузка (isLoading = true)");
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            debugPrint("Валидация прошла успешно. Попытка входа...");
                            try {
                              final success = await authProvider.signIn(
                                _emailController.text.trim(), 
                                _passwordController.text.trim(),
                              );

                              if (success && context.mounted) {
                                debugPrint("Вход успешный! Переходим на главный экран.");
                              }
                                                        } catch (e) {
                              debugPrint("Ошибка при входе в Supabase: $e");
                              if (context.mounted) {
                                // 1. Переводим техническую ошибку в строковый ключ
                                String mapServerExceptionToKey(String serverError) {
                                  if (serverError.contains('invalid_credentials')) {
                                    return 'error_invalid_credentials';
                                  }
                                  if (serverError.contains('SocketException') || serverError.contains('network_error')) {
                                    return 'error_network';
                                  }
                                  return 'error_unknown';
                                }

                                String errorKey = mapServerExceptionToKey(e.toString());
                                
                                // 2. Используем ваш встроенный метод getTxt для перевода ключа ошибки!
                                // Теперь не нужно вызывать методы из AppStrings напрямую здесь.
                                String humanMessage = getTxt(errorKey, 'Ошибка входа. Проверьте данные.');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(humanMessage), 
                                    backgroundColor: const Color(0xFFFFB785),
                                  ),
                                );
                              }
                            }

                                      } else {
                                        debugPrint("Валидация не прошла!");}},
                                        child: Container(
                                          decoration: BoxDecoration(color: authProvider.isLoading? const Color(0xFF1E252B): const Color(0xFF4ADE80),
                                          borderRadius: BorderRadius.circular(16),),
                                          alignment: Alignment.center,
                                          child: authProvider.isLoading? const SizedBox(height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),): 
                                          Text(getTxt('btn_login', 'Войти'),
                                          style: TextStyle(color: authProvider.isLoading? Colors.grey: const Color(0xFF12161A),
                                          fontSize: 16,fontWeight: FontWeight.bold,),),),),),),
                                          const SizedBox(height: 32),
                                          // КАТТАЛУУГА ӨТҮҮ ШИЛТЕМЕСИ
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [Text(getTxt('txt_no_account', 'Аккаунтуңуз жокпу? '),
                                            style: const TextStyle(color: Color(0xFF94A3B8), 
                                            fontSize: 14),),GestureDetector(
                                              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => const SignUpView()),);},
                                              child: Text(getTxt('link_register', 'Катталуу'),
                                              style: const TextStyle(color: Color(0xFF4ADE80),
                                              fontSize: 14,fontWeight: FontWeight.bold,),),),],),],),),),),),);}}  
