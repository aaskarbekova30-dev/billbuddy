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

  // --- ПРОФИЛЬ МЕНЕН ИШТӨӨ ФУНКЦИЯЛАРЫ ---

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

  // 3. МУЗКАЛЫК ФУНКЦИЯ: ЖАҢЫ ТОПТУ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
  // Базадагы 'image_path' устунуна туураланды
  Future<void> addGroup({
    required String name,
    required String type,
    String imagePath = '',
  }) async {
    try {
      await _supabase.from('groups').insert({
        'name': name,
        'type': type,
        'image_path': imagePath, 
      });
    } catch (e) {
      debugPrint('Supabase кошууда ката: $e');
    }
  }

  // ЖАҢЫ ЧЫГАШАНЫ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
  // Базадагы 'group_name' устунуна туураланды
  Future<void> addExpense({
    required String title,
    required double amount,
    required String groupName,
  }) async {
    try {
      await _supabase.from('expenses').insert({
        'title': title,
        'amount': amount,
        'group_name': groupName, 
      });
    } catch (e) {
      debugPrint('Supabase чыгаша кошууда ката: $e');
    }
  }

  // 5. ТӨЛӨМ СИСТЕМАСЫ: ТОПТУН КАРЫЗДАРЫН СЕРВЕРДЕН ТАЗАЛОО (DELETE/SETTLE UP)
  Future<void> settleUpGroup(String groupName) async {
    try {
      // Сервердеги 'expenses' таблицасынан ушул топко тиешелүү бардык чыгашаларды өчүрөбүз
      await _supabase.from('expenses').delete().eq('group_name', groupName);
    } catch (e) {
      debugPrint('Supabase эсептешүүдө ката: $e');
    }
  }
}
