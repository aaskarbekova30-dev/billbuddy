import 'package:billbuddy/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/expense_model.dart';
import '../../models/subscription_model.dart';

// 🔥 ЖАНЫ КОШУЛДУ: Сервистин кызыл болуп күйгөн катасын ушул импорт толугу менен оңдойт

class ExpenseProvider with ChangeNotifier {
  final String _boxName = 'billbuddy_box';
  final String _expensesKey = 'expenses_list_raw';
  final String _subsKey = 'subscriptions_list_raw';
  final String _notifsKey = 'notifications_list_raw';

  double _totalBalance = 0.0;
  List<ExpenseModel> _expenses = [];
  List<SubscriptionModel> _subscriptions = [];
  List<String> _notificationsHistory = []; // Борбордук билдирүүлөр тизмеси

  double _bakytBalance = 0.0;
  double _aibekBalance = 0.0;

  double get totalBalance => _totalBalance;
  List<ExpenseModel> get expenses => _expenses;
  List<SubscriptionModel> get subscriptions => _subscriptions;
  List<String> get notificationsHistory => _notificationsHistory;
  double get bakytBalance => _bakytBalance;
  double get aibekBalance => _aibekBalance;

  ExpenseProvider() {
    _initHive();
  }

  void _initHive() async {
    var box = await Hive.openBox(_boxName);

    _totalBalance = box.get('total_balance', defaultValue: 0.0);
    _bakytBalance = box.get('bakyt_balance', defaultValue: 0.0);
    _aibekBalance = box.get('aibek_balance', defaultValue: 0.0);

    final List<dynamic>? savedRaw = box.get(_expensesKey);
    if (savedRaw != null) {
      _expenses = savedRaw
          .map((item) => ExpenseModel.fromMap(item as Map))
          .toList();
    }

    final List<dynamic>? savedSubs = box.get(_subsKey);
    if (savedSubs != null) {
      _subscriptions = savedSubs
          .map((item) => SubscriptionModel.fromMap(item as Map))
          .toList();
    }

    final List<dynamic>? savedNotifs = box.get(_notifsKey);
    if (savedNotifs != null) {
      _notificationsHistory = List<String>.from(savedNotifs);
    }

    notifyListeners();
  }

  // 1. КАДИМКИ ЧЫГАША КОШУУ
  void addExpense(
    String title,
    double amount,
    bool splitWithBakyt,
    bool splitWithAibek,
  ) async {
    final newExpense = ExpenseModel(
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    _expenses.insert(0, newExpense);
    _totalBalance += amount;

    int peopleCount = 1;
    if (splitWithBakyt) peopleCount++;
    if (splitWithAibek) peopleCount++;
    double share = amount / peopleCount;

    if (splitWithBakyt) _bakytBalance += share;
    if (splitWithAibek) _aibekBalance += share;

    _notificationsHistory.insert(
      0,
      'Жаңы чыгаша кошулду: "$title" — \$$amount',
    );

    _saveToHive();
  }

  // 2. АЙЛЫК ТУРУКТУУ ЖАЗЫЛУУЛАРДЫ КОШУУ
  void addSubscription(String name, double price, int paymentDay) async {
    final int subId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final newSub = SubscriptionModel(
      id: subId.toString(),
      name: name,
      price: price,
      paymentDay: paymentDay,
    );

    _subscriptions.insert(0, newSub);

    var box = Hive.box(_boxName);
    String currentLang = box.get('current_language', defaultValue: 'ky');

    String subLabel = 'АБОНЕМЕНТ';
    if (currentLang == 'en') {
      subLabel = 'PASS';
    } else if (currentLang == 'ru') {
      subLabel = 'АБОНЕМЕНТ';
    }

    final autoExpense = ExpenseModel(
      title: '$name ($subLabel)',
      amount: price,
      date: DateTime.now(),
    );

    _expenses.insert(0, autoExpense);
    _totalBalance += price;

    double share = price / 3;
    _bakytBalance += share;
    _aibekBalance += share;

    _notificationsHistory.insert(
      0,
      'Жаңы жазылуу катталды: $name — \$$price (Ар айдын $paymentDay-чи күнү төлөнөт)',
    );

    _saveToHive();

    // Эми бул жерде импорт кошулгандыктан эч кандай ката чыкпайт
    await NotificationService().scheduleSubscriptionNotification(
      subId,
      name,
      price,
      paymentDay,
    );
  }

  // 3. ЧЫГАШАНЫ ӨЧҮРҮҮ
  void deleteExpense(int index) async {
    if (index >= 0 && index < _expenses.length) {
      double amountToRemove = _expenses[index].amount;
      String titleToRemove = _expenses[index].title;

      _expenses.removeAt(index);
      _totalBalance -= amountToRemove;
      double share = amountToRemove / 3;
      _bakytBalance -= share;
      _aibekBalance -= share;

      _notificationsHistory.insert(0, 'Чыгаша өчүрүлдү: "$titleToRemove"');

      _saveToHive();
    }
  }

  // 4. БИЛДИРҮҮЛӨРДҮ ТАЗАЛOО
  void clearNotifications() async {
    _notificationsHistory.clear();
    var box = Hive.box(_boxName);
    await box.put(_notifsKey, _notificationsHistory);
    notifyListeners();
  }

  // 5. БААРДЫК МААЛЫМАТТАРДЫ СБРОС КЫЛУУ
  void settleUpAll() async {
    _bakytBalance = 0.0;
    _aibekBalance = 0.0;
    _totalBalance = 0.0;
    _expenses.clear();
    _subscriptions.clear();
    _notificationsHistory.clear();
    _saveToHive();
  }

  void _saveToHive() async {
    var box = Hive.box(_boxName);
    await box.put('total_balance', _totalBalance);
    await box.put('bakyt_balance', _bakytBalance);
    await box.put('aibek_balance', _aibekBalance);

    final List<Map<String, dynamic>> rawList = _expenses
        .map((e) => e.toMap())
        .toList();
    await box.put(_expensesKey, rawList);

    final List<Map<String, dynamic>> rawSubs = _subscriptions
        .map((s) => s.toMap())
        .toList();
    await box.put(_subsKey, rawSubs);

    await box.put(_notifsKey, _notificationsHistory);

    notifyListeners();
  }
}
