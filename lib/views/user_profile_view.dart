import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Supabase кайра кошулду
import '../core/services/language_provider.dart';
import '../core/services/supabase_provider.dart'; // 2. Сиздин SupabaseProvider кошулду

class UserAccountView extends StatefulWidget {
  const UserAccountView({super.key});

  @override
  State<UserAccountView> createState() => _UserAccountViewState();
}

class _UserAccountViewState extends State<UserAccountView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController(); 
  
  // 3. Кайрадан Supabase кардары колдонулат
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  bool _isEmailValid = false;
  String _currentUserEmail = ''; 

  @override
  void initState() {
    super.initState();
    // 4. Учурдагы колдонуучунун email'ин Supabase аркылуу бир жолу сактап алабыз
    _currentUserEmail = _supabase.auth.currentUser?.email ?? '';
  } 

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // АККАУНТТУ СУПАБЕЙС АРКЫЛУУ ТОЛУК ӨЧҮРҮҮ
  Future<void> _handleAccountDeletion(String enteredEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final String cleanCurrentUserEmail = (user.email ?? '').trim().toLowerCase();

    // Ийгиликтүү өчүрүү маалымдамасы
    final String successMsg = langProvider.translate('delete_success_msg').isEmpty
        ? 'Your account and all data have been successfully deleted.'
        : langProvider.translate('delete_success_msg');

    try {
      setState(() => _isLoading = true);
      
      // 5. Сиздин SupabaseProvider аркылуу аккаунтту өчүрүү методун чакырабыз
      final authProvider = Provider.of<SupabaseProvider>(context, listen: false);
      await authProvider.deleteAccount(cleanCurrentUserEmail); 

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: const Color(0xFF4ADE80)),
        );
        // Авторизация экранына кайтаруу
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        String errorText = 'Error: $e';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    // Локализация текстери
    String getTxt(String key, String defaultText) {
      final translated = langProvider.translate(key);
      return (translated.isEmpty || translated == key) ? defaultText : translated;
    }

    // Тексттер (Кайрадан Supabase деп алмаштырылды)
    final String deleteDesc = getTxt('delete_dialog_content', 'Удаление учетной записи выполняется в соответствии с политикой обработки данных. Введите свой Email для подтверждения. Все ваши личные данные будут навсегда удалены из базы данных Supabase.');
    final String hintText = getTxt('hint_confirm_email', 'Электронная почта (Email)');
    final String buttonText = getTxt('delete_btn_confirm', 'Запросить удаление аккаунта');

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTxt('title_account_settings', 'Настройки аккаунта'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: 
             CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // ТЕКСТ-ПРЕДУПРЕЖДЕНИЕ
              Text(
                deleteDesc,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // ПОЛЕ ВВОДА EMAIL С ПРОВЕРКОЙ «НА ЛЕТУ»
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = value.trim().toLowerCase() == _currentUserEmail.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF1E252B),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2D3742)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _isEmailValid ? const Color(0xFF4ADE80) : const Color(0xFFEF4444)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // УМНАЯ БЛОКИРУЮЩАЯСЯ КНОПКА ПОДТВЕРЖДЕНИЯ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailValid ? const Color(0xFFEF4444) : const Color(0xFF2D3742),
                    disabledBackgroundColor: const Color(0xFF2D3742),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: (_isLoading || !_isEmailValid) 
                      ? null 
                      : () => _handleAccountDeletion(_emailController.text),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          buttonText,
                          style: TextStyle(
                            color: _isEmailValid ? Colors.white : const Color(0xFF64748B), 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
