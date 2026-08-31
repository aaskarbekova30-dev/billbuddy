import 'package:billbuddy/views/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
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
  bool _isGoogleLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    // ТАЗА GOOGLE АВТОРИЗАЦИЯ ФУНКЦИЯСЫ (ТОЛУК ОҢДОЛГОН ВЕРСИЯСЫ 7.x)
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isGoogleLoading = true);

      // 1. Пакеттин жаңы синглтон объектисин чакыруу
      final googleSignIn = g_auth.GoogleSignIn.instance;
      await googleSignIn.initialize();
      
      // 2. БУЛ САП СӨЗСҮЗ БОЛУШУ КЕРЕК (Сизде өчүп калган сап):
      final googleUser = await googleSignIn.authenticate(); 


      // 3. Идентификациялык токенди алуу (idToken)
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      // 4. Жаңы 7.x версиясынын стандарты боюнча accessToken алуу:
      final authorization = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      if (idToken == null || accessToken == null) {
        throw 'Google токендери табылган жок';
      }

      if (mounted) {
        final authProvider = Provider.of<SupabaseProvider>(context, listen: false);
        await authProvider.signInWithGoogle(
          idToken: idToken,
          accessToken: accessToken,
        );
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ката кетти: $error"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }


  // EMAIL МЕНЕН КИРҮҮ ФУНКЦИЯСЫ
  Future<void> _handleEmailSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<SupabaseProvider>(context, listen: false);
        
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Ката кетти: $error"),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
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

    final isGeneralLoading = authProvider.isLoading || _isGoogleLoading;

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
                      enabled: !isGeneralLoading,
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
                      enabled: !isGeneralLoading,
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
                      onPressed: isGeneralLoading
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
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(getTxt('reset_success', 'Сырсөздү калыбына келтирүү шилтемеси почтаңызга жөнөтүлдү!')),
                                      backgroundColor: const Color(0xFF4ADE80),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Ката: $e"),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text(
                        getTxt('btn_forgot', 'Сырсөздү унутуп койдуңузбу?'),
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // КИРҮҮ БАСКЫЧЫ (EMAIL)
                  ElevatedButton(
                    onPressed: isGeneralLoading ? null : _handleEmailSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ADE80),
                      foregroundColor: const Color(0xFF12161A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isGeneralLoading && !_isGoogleLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF12161A)),
                          )
                        : Text(
                            getTxt('btn_login', 'Кирүү'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ЖЕ БӨЛҮГҮ
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF1E252B), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          getTxt('txt_or', 'же'),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF1E252B), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // GOOGLE МЕНЕН КИРҮҮ БАСКЫЧЫ
                  ElevatedButton.icon(
                    onPressed: isGeneralLoading ? null : _handleGoogleSignIn,
                    icon: _isGoogleLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.g_mobiledata, size: 30),
                    label: Text(getTxt('btn_google', 'Google менен кирүү')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E252B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // КАТТАЛУУ БАРАКЧАСЫНА ӨТҮҮ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTxt('txt_dont_have_account', 'Аккаунтуңуз жокпу? '),
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      GestureDetector(
                        onTap: isGeneralLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpView()),
                                );
                              },
                        child: Text(
                          getTxt('btn_register', 'Катталуу'),
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


