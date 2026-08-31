import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // Серверден келе турган топтордун жана чыгашалардын жандуу тизмеси
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _expenses = [];

  // Профиль үчүн өзгөрмөлөр
  bool _isLoading = false;
  String _userName = 'Колдонуучу';

  List<Map<String, dynamic>> get groups => _groups;
  List<Map<String, dynamic>> get expenses => _expenses;

  // Геттерлер экрандан маалыматты окуу үчүн
  bool get isLoading => _isLoading;
  String get userName => _userName;

  SupabaseProvider() {
    // Провайдер жаратылганда сервердеги маалыматтарды дароо угуп баштайт
    listenToGroups();
    listenToExpenses();
    // Провайдер ишке киргенде колдонуучунун атын да кошо жүктөп алат
    fetchProfile();
  }

  void listenToGroups() {
    _supabase
        .from('groups')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          _groups = data;
          notifyListeners(); // Экранды заматта жаңылайт
        }, onError: (error) {
          debugPrint('Groups агымында ката: $error');
        });
  }

  void listenToExpenses() {
    _supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          _expenses = data;
          notifyListeners(); // Экранды заматта жаңылайт
        }, onError: (error) {
          debugPrint('Expenses агымында ката: $error');
        });
  }

  // ПРОФИЛЬ МЕНЕН ИШТӨӨ ФУНКЦИЯЛАРЫ

  // 1. Булуттан колдонуучунун атын окуу (Fetch)
  Future<void> fetchProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle(); // Эгер профиль жок болсо, ката бербей null кайтарат
      
      if (data != null && data['username'] != null) {
        _userName = data['username'].toString();
      } else {
        _userName = 'Айжамал'; // Эгер базада аты жок болсо, баштапкы ат
      }
    } catch (e) {
      debugPrint("Профилди жүктөөдө ката: $e");
      _userName = 'Колдонуучу';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Жаңы атты булутка сактоо же жаңыртуу (Upsert)
  Future<void> updateProfile(String newName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'username': newName,
        'updated_at': DateTime.now().toIso8601String(),
      });
      _userName = newName;
    } catch (e) {
      debugPrint("Профилди булутка жаңыртууда ката: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. ЖАҢЫ ТОПТУ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
  Future<void> addGroup({
    required String name,
    required String type,
    String imagePath = '',
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('groups').insert({
        'name': name,
        'type': type,
        'image_path': imagePath,
        if (user != null) 'user_id': user.id,
      });
    } catch (e) {
      debugPrint('Supabase кошууда ката: $e');
    }
  }

  // 4. ЖАҢЫ ЧЫГАШАНЫ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
  Future<void> addExpense({
    required String title,
    required double amount,
    required String groupName,
    DateTime? date,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      final expenseDate = date ?? DateTime.now();

      await _supabase.from('expenses').insert({
        'title': title,
        'amount': amount,
        'group_name': groupName,
        'created_at': expenseDate.toIso8601String(),
        if (user != null) 'user_id': user.id,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Supabase чыгаша кошууда ката: $e');
    }
  }

  // 5. ТӨЛӨМ СИСТЕМАСЫ: ТОПТУН КАРЫЗДАРЫН СЕРВЕРДЕН ТАЗАЛОО (DELETE/SETTLE UP)
  Future<void> settleUpGroup(String groupName) async {
    try {
      await _supabase.from('expenses').delete().eq('group_name', groupName);
    } catch (e) {
      debugPrint('Supabase эсептешүүдө ката: $e');
    }
  }

  void addSubscription({required String title, required double amount, required String groupName}) {
    // Бул жерге келечекте жазылууларды кошуу логикасын жазсаңыз болот
  }

  // ==========================================
  // АВТОРИЗАЦИЯ ФУНКЦИЯЛАРЫ
  // ==========================================

  // Электрондук почта жана пароль аркылуу кирүү (Войти)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true; // Ийгиликтүү кирди
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Supabase кирүүдө ката: $e');
      rethrow; // Каталыкты экранга өткөрүп берет
    }
  }

  // Google менен кирүү функциясы (КАТАСЫЗ ВЕРСИЯ)
  Future<bool> signInWithGoogle({required String idToken, required String accessToken}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = _supabase.auth.currentUser;
      if (user != null) {
        final username = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Колдонуучу';
        
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'username': username,
          'updated_at': DateTime.now().toIso8601String(),
        });
        _userName = username;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Supabase Google менен кирүүдө ката: $e');
      rethrow;
    }
  }

  // Электрондук почта, пароль жана колдонуучунун аты менен катталуу (Регистрация)
  Future<bool> signUp(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'updated_at': DateTime.now().toIso8601String(),
        });
        _userName = username;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Supabase катталууда ката: $e');
      rethrow;
    }
  }

  // Сырсөздү унутуп калганда электрондук почтага шилтеме жөнөтүү (Восстановление пароля)
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.billbuddy://login-callback', 
      );
    } catch (e) {
      debugPrint('Supabase сырсөздү калыбына келтирүүдө ката: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // АККАУНТТУ ТОЛУГУ МЕНЕН ӨЧҮРҮҮ ФУНКЦИЯСЫ
  Future<bool> deleteAccount(String confirmedEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Колдонуучу табылган жок!');
    }

    if (user.email != confirmedEmail) {
      throw Exception('Электрондук почта туура эмес киргизилди!');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.rpc('delete_current_user');
      await _supabase.auth.signOut();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Аккаунтту өчүрүүдө ката кетти: $e');
      rethrow;
    }
  }

  // Тиркемеден чыгуу (Выйти)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
