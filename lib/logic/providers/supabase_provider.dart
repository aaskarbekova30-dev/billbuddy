import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // Серверден келе турган топтордун жана чыгашалардын жандуу тизмеси
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _expenses = [];

  List<Map<String, dynamic>> get groups => _groups;
  List<Map<String, dynamic>> get expenses => _expenses;

  SupabaseProvider() {
    // Провайдер жаратылганда сервердеги маалыматтарды дароо угуп баштайт
    listenToGroups();
    listenToExpenses();
  }

  // 🌟 1. ЖАНДУУ ЛОГИКА: СЕРВЕРДЕГИ ТОПТОРДУ РЕАЛДУУ УБАҚЫТТА УГУУ
  void listenToGroups() {
    _supabase
        .from('groups')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          _groups = data;
          notifyListeners(); // Экранды заматта жаңылайт
        });
  }

  // 🌟 2. ЖАНДУУ ЛОГИКА: СЕРВЕРДЕГИ ЧЫГАШАЛАРДЫ РЕАЛДУУ УБАҚЫТТА УГУУ
  void listenToExpenses() {
    _supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          _expenses = data;
          notifyListeners(); // Экранды заматта жаңылайт
        });
  }

  // 🚀 3. МУЗКАЛЫК ФУНКЦИЯ: ЖАҢЫ ТОПТУ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
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

  // 🚀 4. МУЗКАЛЫК ФУНКЦИЯ: ЖАҢЫ ЧЫГАШАНЫ СЕРВЕРГЕ ЖӨНӨТҮҮ (INSERT)
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

  // 💳 5. ТӨЛӨМ СИСТЕМАСЫ: ТОПТУН КАРЫЗДАРЫН СЕРВЕРДЕН ТАЗАЛОО (DELETE/SETTLE UP)
  Future<void> settleUpGroup(String groupName) async {
    try {
      // Сервердеги 'expenses' таблицасынан ушул топко тиешелүү бардык чыгашаларды өчүрөбүз
      await _supabase.from('expenses').delete().eq('group_name', groupName);
    } catch (e) {
      debugPrint('Supabase эсептешүүдө ката: $e');
    }
  }
}
