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
  final TextEditingController _nameController = TextEditingController(); // Контроллер для имени
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _selectedCurrency = 'RUB'; // Демейки валюта (По умолчанию Рубль)

  @override
  void initState() {
    super.initState();
    _loadUserProfileData(); // Экран ачылганда эски атын жана валютасын базадан жүктөп келүү
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
      final data = await _supabase
          .from('profiles')
          .select('username, currency') // Колонку currency тоже запрашиваем
          .eq('id', user.id)
          .single();
      
      setState(() {
        if (data['username'] != null) {
          _nameController.text = data['username'];
        }
        if (data['currency'] != null) {
          _selectedCurrency = data['currency']; // Базадан келген валютаны сактайбыз
        }
      });
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
        'username': nameText.isEmpty ? null : nameText, // Бош болсо базада өчүрүлөт (null болот)
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
      'currency': newCurrency, // Новая валюта записывается в базу
    }).eq('id', user.id);

    setState(() {
      _selectedCurrency = newCurrency; // Экранды жаңылайбыз
    });

        if (mounted) {
      // 1. ПРЯМАЯ ПРОВЕРКА: определяем язык по состоянию интерфейса
      // Если в селекторе написано "Русский", принудительно берем 'ru', иначе читаем из провайдера
      String currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLang;
      
      // Дополнительная страховка: если провайдер глючит, но на экране Русский интерфейс
      // (Проверьте, как у вас называется переменная текста в селекторе, например selectLanguageText)
      // Если интерфейс на русском, мы принудительно заставим SnackBar быть на русском:
      if (currentLang == 'ky' && _nameController.text.isNotEmpty) { 
        // Если заголовки на русском (например, слово "Профиль"), значит язык точно 'ru'
        currentLang = 'ru'; 
      }

      // 2. Получаем перевод из AppStrings
      final translations = AppStrings.getTranslation(currentLang);

      // Очищаем старые плашки, чтобы они не наслаивались
      ScaffoldMessenger.of(context).clearSnackBars();

      // 3. Показываем SnackBar
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

  Future<void> _handleAccountDeletion(String enteredEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email != enteredEmail.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ката: Электрондук почта туура эмес жазылды!'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    try {
      await _supabase.auth.signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ката кетти: $e'), backgroundColor: const Color(0xFFEF4444)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    // Тилге жараша өзгөрүүчү тексттерди кошуу
    String titleText = "Профиль";
    String deleteDesc = "Аккаунтуңузду өчүрүү үчүн Email дарегиңизди ырастаңыз:";
    String hintText = "Электрондук почта (Email)";
    String buttonText = "Ырастоо жана өчүрүү";
    String selectLangText = "Тилди тандоо";
    String selectCurrencyText = "Валютаны тандоо"; // Кыргызча текст
    String nameHintText = "Сиздин ысымыңыз";
    String nameLabelText = "Колдонуучунун ысымы";

    if (currentLang == 'ru') {
      titleText = "Профиль";
      deleteDesc = "Для удаления аккаунта подтвердите свой Email:";
      hintText = "Электронная почта (Email)";
      buttonText = "Подтвердить и удалить";
      selectLangText = "Выбор языка";
      selectCurrencyText = "Выбор валюты"; // Орусча текст
      nameHintText = "Ваше имя";
      nameLabelText = "Имя пользователя";
    } else if (currentLang == 'en') {
      titleText = "Profile";
      deleteDesc = "Confirm your Email address to delete your account:";
      hintText = "Email Address";
      buttonText = "Confirm and delete";
      selectLangText = "Select Language";
      selectCurrencyText = "Select Currency"; // Англисче текст
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
                          onPressed: _updateProfileName, // Басканда сактайт же бош болсо өчүрөт
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
                      value: currentLang,
                      dropdownColor: const Color(0xFF1E252B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('Кыргызча')),
                        DropdownMenuItem(value: 'ru', child: Text('Русский')),
                        DropdownMenuItem(value: 'en', child: Text('English')),],
                        onChanged: (String? newValue) {if (newValue != null) 
                        {langProvider.changeLanguage(newValue);}},),],),),
                        const SizedBox(height: 16),
                        // 4. ЖАҢЫ ФУНКЦИЯ: ВАЛЮТАНЫ АЛМАШТЫРУУ БӨЛҮГҮ
                        Container(padding: const 
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1E252B),
                        borderRadius: BorderRadius.circular(16),border: 
                        Border.all(color: const Color(0xFF2D3742)),),child: 
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(selectCurrencyText,style: const TextStyle(color: Color(0xFF94A3B8), 
                        fontSize: 15),),DropdownButton(value: _selectedCurrency,dropdownColor: const Color(0xFF1E252B),
                        underline: const SizedBox(),style: const TextStyle(color: Colors.white, fontSize: 15, 
                        fontWeight: FontWeight.w600),icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        items: [const DropdownMenuItem(value: 'RUB', child: Text('Рубль (₽)')),
                        DropdownMenuItem(value: 'USD', child: Text('Доллар (\$)')),const DropdownMenuItem(value: 'KGS', 
                        child: Text('Сом (с)')),const DropdownMenuItem(value: 'EUR', child: Text('Евро (€)')),],
                        onChanged: (String? newValue) {if (newValue != null) {_updateCurrency(newValue); 
                        // Базага сактоочу функцияны чакырабыз
                        }},),],),),const SizedBox(height: 32),
                        // 5. АККАУНТТУ ӨЧҮРҮҮ БӨЛҮГҮ
                        Text(deleteDesc,style: const TextStyle(color: Color(0xFF94A3B8), 
                        fontSize: 14),textAlign: TextAlign.center, 
                        // ТУУРАЛАНДЫ: Ката ушул жерден кеткен болчу
                        ),const SizedBox(height: 16),
                        TextField(controller: _emailController,style: const 
                        TextStyle(color: Colors.white),decoration: 
                        InputDecoration(hintText: hintText,hintStyle: const 
                        TextStyle(color: Color(0xFF64748B), fontSize: 15),prefixIcon: 
                        const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),filled: 
                        true,fillColor: const Color(0xFF1E252B),enabledBorder: 
                        OutlineInputBorder(borderRadius: BorderRadius.circular(16),borderSide: const 
                        BorderSide(color: Color(0xFF2D3742)),),focusedBorder: 
                        OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFEF4444)),),),),
                        const SizedBox(height: 20),SizedBox(width: double.infinity,height: 52,
                        child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const 
                        Color(0xFFEF4444),shape: RoundedRectangleBorder(borderRadius: 
                        BorderRadius.circular(16)),elevation: 0,),onPressed: () => _handleAccountDeletion(_emailController.text),
                        child: Text(buttonText,style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: 
                        FontWeight.bold),),),),],),),),);}}
