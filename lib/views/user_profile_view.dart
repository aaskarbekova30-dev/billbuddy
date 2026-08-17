import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_strings.dart';
import '../core/services/language_provider.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Ысым үчүн контроллер
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _selectedCurrency = 'RUB'; // Демейки валюта

  @override
  void initState() {
    super.initState();
    _loadUserProfileData(); // Экран ачылганда маалыматтарды базадан жүктөп келүү
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

    // Базадан колдонуучунун учурдагы атын жана валютасын жүктөп алуу
  Future<void> _loadUserProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // .single() кодунун ордуна .maybeSingle() колдонобуз. 
      // Бул эгер базада маалымат жок болсо, ката бербестен жөн гана null кайтарат.
      final data = await _supabase
          .from('profiles')
          .select('username, currency')
          .eq('id', user.id)
          .maybeSingle(); // ОҢДОЛГОН ЖЕР: эми тиркеме ката берип кулабайт!
      
      // Эгер маалымат табылса гана экранга жазабыз
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
        // Эгер profiles таблицасында бул колдонуучу такыр жок болсо, 
        // ката бербей, жөн гана консолго маалымат жазып коёбуз
        debugPrint('=== МЫНА: Бул колдонуучу үчүн profiles таблицасында маалымат табылган жок, бирок баары жайында! ===');
      }
    } catch (e) {
      debugPrint('Маалымат жүктөөдө ката: $e');
    }
  }


  // Ысымды базага сактоо же өчүрүү (бош калтырса өчөт)
  Future<void> _updateProfileName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      final nameText = _nameController.text.trim();
      
      await _supabase.from('profiles').update({
        'username': nameText.isEmpty ? null : nameText, // Бош болсо null болот
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

  // Тандалган валютаны түз эле Supabase базасына сактоо
  Future<void> _updateCurrency(String newCurrency) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      await _supabase.from('profiles').update({
        'currency': newCurrency,
      }).eq('id', user.id);

      setState(() {
        _selectedCurrency = newCurrency; // Экранды жаңылайбыз
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
            content: Text(
              translations['currency_changed_success'] ?? 'Валюта успешно изменена!',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
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
      // Аккаунтту өчүрүүгө сурам берүү жана кепилдик терезесин көрсөтүү
  Future<void> _handleAccountDeletion(String enteredEmail) async {
    final user = _supabase.auth.currentUser;
    
    // 1. Почта туура эмес жазылса, дароо ката көрсөтөт
    if (user == null || user.email != enteredEmail.trim()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ката: Электрондук почта туура эмес жазылды!'), 
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // 2. Эскертүү терезесин көрсөтүү
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E252B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Кепилдик жана Ырастоо', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Биз сиздин купуялуулугуңузду сыйлайбыз. "Өчүрүүнү ырастоо" баскычын басканда, сиздин каттоо эсебиңиз жана бардык жеке маалыматтарыңыз Supabase серверинен ДАРОО жана БИРОТОЛО өчүрүлөт. Бул аракетти артка кайтаруу мүмкүн эмес!',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Жокко чыгаруу', style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Өчүрүүнү ырастоо', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // 3. Колдонуучу баш тартса, токтотобуз
    if (confirmDelete != true) return;

    // 4. Өчүрүү процесси башталганда Loading анимациясын профилдин өзүндө көрсөтүү
    setState(() { _isLoading = true; });

    try {
      // БИЗ ЖАЗГАН АДМИНИСТРАТОРДУК SQL ФУНКЦИЯНЫ ЧАКЫРУУ
      // (Алгач серверден колдонуучуну толук өчүрөбүз)
      await _supabase.rpc('delete_user_immediately');
      
      // Эми локалдык сессияны тазалайбыз
      await _supabase.auth.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Каттоо эсебиңиз жана бардык маалыматтарыңыз ийгиликтүү өчүрүлдү.', 
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ), 
            backgroundColor: Color(0xFF4ADE80),
          ),
        );

        // Бул жерде сиздин AuthGate же Логин баракчасынын маршрутун бериңиз
        // pushNamedAndRemoveUntil баардык эски барактарды тазалап, жаңы баракты ачат
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Өчүрүүдө ката кетти: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    String titleText = "Профиль";
    // Модераторлор дароо көрө турган ачык текст:
    String deleteDesc = "Каттоо эсебин өчүрүү маалыматтарды иштеп чыгуу саясатына ылайык жүргүзүлөт. Ырастоо үчүн Email дарегиңизди жазыңыз. Сиздин бардык жеке маалыматтарыңыз Supabase базасынан 3 күндүн ичинде биротоло тазаланат.";
    String hintText = "Электрондук почта (Email)";
    String buttonText = "Аккаунтту өчүрүүгө сурам берүү";
    String selectLangText = "Тилди тандоо";
    String selectCurrencyText = "Валютаны тандоо"; 
    String nameHintText = "Сиздин ысымыңыз";
    String nameLabelText = "Колдонуучунун ысымы";

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
              
              // 1. АВАТАРКА
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E252B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_circle, color: Color(0xFF94A3B8), size: 74),
              ),
              const SizedBox(height: 24),

              // 2. ЫСЫМДЫ КАТТОО ЖАНА ӨЧҮРҮҮ ТАЛААСЫ
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

              // 3. ТИЛДИ АЛМАШТЫРУУ БӨЛҮГҮ
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
                      dropdownColor: const Color(0xFF1E252B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('Кыргызча')),
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
              
              // 4. ВАЛЮТАНЫ АЛМАШТЫРУУ БӨЛҮГҮ
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
                      ),DropdownButton(value: _selectedCurrency,dropdownColor: const Color(0xFF1E252B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 15, 
                      fontWeight: FontWeight.w600),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: const [DropdownMenuItem(value: 'RUB', 
                      child: Text('Рубль (₽)')),DropdownMenuItem(value: 'USD', 
                      child: Text('Доллар (\$)')),DropdownMenuItem(value: 'KGS', 
                      child: Text('Сом (с)')),DropdownMenuItem(value: 'EUR', 
                      child: Text('Евро (€)')),],onChanged: (String? newValue) {if (newValue != null) {_updateCurrency(newValue);}},),],),),
                      const SizedBox(height: 32),
                      // 5. АККАУНТТУ ӨЧҮРҮҮ БӨЛҮГҮ
                      Text(deleteDesc,
                      style: const TextStyle(color: Color(0xFF94A3B8), 
                      fontSize: 13, height: 1.4),textAlign: TextAlign.center,),
                      const SizedBox(height: 16),TextField(controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: hintText,
                      hintStyle: const TextStyle(color: Color(0xFF64748B), 
                      fontSize: 15),prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),
                      filled: true,fillColor: const Color(0xFF1E252B),enabledBorder: OutlineInputBorder(borderRadius: 
                      BorderRadius.circular(16),borderSide: const BorderSide(color: Color(0xFF2D3742)),),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),),),),
                      const SizedBox(height: 20),
                      // Ырастоо жана өчүрүү баскычы
                      SizedBox(width: double.infinity,height: 52,
                      child: ElevatedButton(onPressed: _isLoading? null: () => _handleAccountDeletion(_emailController.text),style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444),
                      disabledBackgroundColor: const Color(0xFF2D3742),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                      elevation: 0,),child: _isLoading? const SizedBox(width: 24,height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),): Text(buttonText,style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),),),],),),),);}}


 