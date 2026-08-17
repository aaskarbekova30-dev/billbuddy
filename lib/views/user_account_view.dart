import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/services/supabase_provider.dart';

class UserAccountView extends StatefulWidget {
  const UserAccountView({super.key});

  @override
  State<UserAccountView> createState() => _UserAccountViewState();
}

class _UserAccountViewState extends State<UserAccountView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _selectedCurrency = 'RUB';

  @override
  void initState() {
    super.initState();
    _loadUserProfileData(); // Экран ачылганда маалыматтарды коопсуз жүктөө
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // БАЗАДАН МААЛЫМАТТАРДЫ ЖҮКТӨӨ (ОҢДОЛГОН ЖЕР: .maybeSingle() катаны алдын алат)
  Future<void> _loadUserProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select('username, currency')
          .eq('id', user.id)
          .maybeSingle(); // Жаңы коопсуз коду, эгер маалымат жок болсо null кайтарат
      
      if (data != null) {
        setState(() {
          if (data['username'] != null) {
            _nameController.text = data['username'];
          }
          if (data['currency'] != null) {
            _selectedCurrency = data['currency'];
          }
        });
      } else {
        debugPrint('=== Profiles таблицасында бул колдонуучу жок, бирок ката берген жок! ===');
      }
    } catch (e) {
      debugPrint('Маалымат жүктөөдө ката: $e');
    }
  }

  // ЫСЫМДЫ ЖАҢЫЛОО ФУНКЦИЯСЫ
  Future<void> _updateProfileName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      final nameText = _nameController.text.trim();
      
      await _supabase.from('profiles').update({
        'username': nameText.isEmpty ? null : nameText,
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nameText.isEmpty ? 'Ысым ийгиликтүү өчүрүлдү!' : 'Ысым ийгиликтүү сакталды!'),
            backgroundColor: const Color(0xFF4ADE80),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ката кетти: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // ВАЛЮТАНЫ ЖАҢЫЛОО ФУНКЦИЯСЫ
  Future<void> _updateCurrency(String newCurrency) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      await _supabase.from('profiles').update({
        'currency': newCurrency,
      }).eq('id', user.id);

      setState(() {
        _selectedCurrency = newCurrency;
      });

      if (mounted) {
        String currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLang;
        if (currentLang == 'ky' && _nameController.text.isNotEmpty) { 
          currentLang = 'ru'; 
        }
        final translations = AppStrings.getTranslation(currentLang);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['currency_changed_success'] ?? 'Валюта успешно изменена!'),
            backgroundColor: const Color(0xFF4ADE80),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ката кетти: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
     // АККАУНТТУ БИРОТОЛО ӨЧҮРҮҮ ЖАНА ТАСТЫКТОО ТЕРЕЗЕСИН КӨРСӨТҮҮ
  Future<void> _handleAccountDeletion(String enteredEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // МУРУНКУ listen: false БӨЛҮГҮ АЛЫП САЛЫНДЫ! 
    // Эми тилди түздөн-түз баскыч басылган учурда жаңылап алып турабыз:
    final currentLang = context.read<LanguageProvider>().currentLang;

    final String cleanEnteredEmail = enteredEmail.trim().toLowerCase();
    final String cleanCurrentUserEmail = (user.email ?? '').trim().toLowerCase();

    // Жүктөлгөн файлдардагы тилдер борборунан (AppStrings) актуалдуу тилдеги сөздөрдү чакыруу
    final String errorMsg = AppStrings.getTranslation(currentLang)['delete_error_email'] ?? 'Error: The email address was entered incorrectly!';
    final String youEnteredLabel = AppStrings.getTranslation(currentLang)['delete_you_entered'] ?? 'You entered:';
    final String registeredLabel = AppStrings.getTranslation(currentLang)['delete_registered_email'] ?? 'Registered:';
    final String successMsg = AppStrings.getTranslation(currentLang)['delete_success_msg'] ?? 'Your account and all data have been successfully deleted.';

    // Эгер колдонуучу жазган почта туура эмес болсо (Скриншоттогу кызыл эскертүү терезеси):
    if (cleanEnteredEmail != cleanCurrentUserEmail) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444), // Кызыл түс
            duration: const Duration(seconds: 5),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMsg,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '$youEnteredLabel "$enteredEmail"', // Эми English тилинде так чыгат!
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Text(
                  '$registeredLabel "$cleanCurrentUserEmail"', // Эми English тилинде так чыгат!
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }
      return; 
    }

    // Эгер почта туура жазылса, өчүрүү логикасы башталат:
    try {
      setState(() => _isLoading = true);
      
      // Сиздин SupabaseProvider ичиндеги функцияңызды чакыруу (катаны болтурбоо үчүн Context берилди)
      final authProvider = Provider.of<SupabaseProvider>(context, listen: false);
      await authProvider.deleteAccount(cleanCurrentUserEmail); // же мурунку ката берген аргументти жазыңыз

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: const Color(0xFF4ADE80)),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)),
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
    final currentLang = langProvider.currentLang;
    
    String titleText = "Профиль";
    String deleteDesc = "Каттоо эсебин өчүрүү маалыматтарди иштеп чыгуу саясатына ылайык жүргүзүлөт. Ырастоо үчүн Email дарегиңизди жазыңыз. Сиздин бардык жеке маалыматтарыңыз Supabase базасынан биротоло тазаланат.";
    String hintText = "Электрондук почта (Email)";
    String buttonText = "Аккаунтту өчүрүүгө сурам берүү";
    String selectLangText = "Тилди тандоо";
    String selectCurrencyText = "Валютаны тандоо"; 
    String nameHintText = "Сиздин ысымыңыз";
    String nameLabelText = "Колдонуучунун ысымы";

    if (currentLang == 'ru') {
      titleText = "Профиль";
      deleteDesc = "Удаление учетной записи выполняется в соответствии с политикой обработки данных. Введите свой Email для подтверждения. Все ваши личные данные будут навсегда удалены из базы данных Supabase.";
      hintText = "Электронная почта (Email)";
      buttonText = "Запросить удаление аккаунта";
      selectLangText = "Выбор языка";
      selectCurrencyText = "Выбор валюты";
      nameHintText = "Ваше имя";
      nameLabelText = "Имя пользователя";
    } else if (currentLang == 'en') {
      titleText = "Profile";
      deleteDesc = "Account deletion is performed in accordance with the data processing policy. Enter your Email to confirm. All your personal data will be permanently deleted from the Supabase database.";
      hintText = "Email Address";
      buttonText = "Request Account Deletion";
      selectLangText = "Select Language";
      selectCurrencyText = "Select Currency";
      nameHintText = "Your name";
      nameLabelText = "Username";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          titleText,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // АВАТАРКА СТИЛИ
              Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4ADE80), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xFF1E252B),
                    child: Icon(Icons.person_outline_rounded, size: 45, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ЫСЫМДЫ КАТТОО ТАЛААСЫ
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: nameLabelText,
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  hintText: nameHintText,
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                  suffixIcon: _isLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(color: Color(0xFF4ADE80), strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4ADE80)),
                          onPressed: _updateProfileName, 
                        ),
                  filled: true,
                  fillColor: const Color(0xFF12161A),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2D3742)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4ADE80)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ТИЛДИ АЛМАШТЫРУУ БӨЛҮГҮ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E252B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2D3742)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectLangText,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    DropdownButton<String>(
                      value: currentLang,
                      dropdownColor: const Color(0xFF1E252B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'ky', child: Text('Кыргызча')),
                        DropdownMenuItem(value: 'ru', child: Text('Русский')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          langProvider.changeLanguage(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ВАЛЮТАНЫ АЛМАШТЫРУУ БӨЛҮГҮ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E252B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2D3742)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectCurrencyText,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    ),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      dropdownColor: const Color(0xFF1E252B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'RUB', child: Text('Рубль (₽)')),
                        DropdownMenuItem(value: 'USD', child: Text('Доллар (\$)')),
                        DropdownMenuItem(value: 'KGS', child: Text('Сом (с)')),
                        DropdownMenuItem(value: 'EUR', child: Text('Евро (€)')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _updateCurrency(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // АККАУНТТУ ӨЧҮРҮҮ БӨЛҮГҮ
              Text(
                deleteDesc,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
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
                    borderSide: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // КООПСУЗ ЖАНА БЕКЕМ КЫЗЫЛ БАСКЫЧ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    disabledBackgroundColor: const Color(0xFF2D3742),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),elevation: 0,),
                      onPressed: _isLoading ? null : () => _handleAccountDeletion(_emailController.text),
                      child: _isLoading? const SizedBox(width: 24,height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),): 
                      Text(
                        buttonText,style: const TextStyle(color: Colors.white, fontSize: 16, 
                        fontWeight: FontWeight.bold),),),),],),),),);}}


