import 'package:hive_flutter/hive_flutter.dart';
import '../../data_objects/subscription_model.dart';
import '../../data_objects/transaction_item.dart'; // ExpenseModel ушул файлдан келет

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final String _boxName = 'billbuddy_box';
  final String _expensesKey = 'expenses_list_raw';
  final String _subsKey = 'subscriptions_list_raw';
  final String _notifsKey = 'notifications_list_raw';

  Box get _box => Hive.box(_boxName);

  Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  List<ExpenseModel> getExpenses() {
    final List<dynamic>? savedRaw = _box.get(_expensesKey);
    if (savedRaw == null) return [];
    return savedRaw
        .map((item) => ExpenseModel.fromMap(item as Map))
        .toList();
  }

  List<SubscriptionModel> getSubscriptions() {
    final List<dynamic>? savedSubs = _box.get(_subsKey);
    if (savedSubs == null) return [];
    return savedSubs
        .map((item) => SubscriptionModel.fromMap(item as Map))
        .toList();
  }

  List<String> getNotificationsHistory() {
    final List<dynamic>? savedNotifs = _box.get(_notifsKey);
    if (savedNotifs == null) return [];
    return List<String>.from(savedNotifs);
  }

  double getTotalBalance() => _box.get('total_balance', defaultValue: 0.0);
  double getBakytBalance() => _box.get('bakyt_balance', defaultValue: 0.0);
  double getAibekBalance() => _box.get('aibek_balance', defaultValue: 0.0);

  // --- ВАЛЮТА КУРСТАРЫ (Жөнөкөйлүк үчүн бул жерде, кийин өзгөртсө болот) ---
  static const double _usdToKgs = 89.5;
  static const double _usdToRub = 92.0;

  // Киргизилген сумманы баланстар үчүн долларга айландыруучу жардамчы функция
  double _convertToUsd(double amount, String currency) {
    if (currency == 'KGS') return amount / _usdToKgs;
    if (currency == 'RUB') return amount / _usdToRub;
    return amount; // USD болсо өзү калат
  }

  // ОҢДОЛДУ: currency жана category параметрлери кошулду
  Future<void> syncAddExpense({
    required String title,
    required double amount,
    required String currency, // Жаңы параметр
    required String category, // Жаңы параметр
    required bool splitWithBakyt,
    required bool splitWithAibek,
  }) async {
    final expenses = getExpenses();
    
    final newExpense = ExpenseModel(
      title: title,
      amount: amount,
      date: DateTime.now(),
      currency: currency, // Жаңы моделге берилди
      category: category, // Жаңы моделге берилди
    );
    expenses.insert(0, newExpense);

    // Баланстарды бир валютада (USD) туура эсептөө үчүн сумманы долларга айландырабыз
    double amountInUsd = _convertToUsd(amount, currency);

    double totalBalance = getTotalBalance() + amountInUsd;
    double bakytBalance = getBakytBalance();
    double aibekBalance = getAibekBalance();

    int peopleCount = 1;
    if (splitWithBakyt) peopleCount++;
    if (splitWithAibek) peopleCount++;
    double share = amountInUsd / peopleCount;

    if (splitWithBakyt) bakytBalance += share;
    if (splitWithAibek) aibekBalance += share;

    // Валюта белгисин аныктоо
    String currencySymbol = currency == 'USD' ? '\$' : (currency == 'KGS' ? 'сом' : 'руб');
    final notifications = getNotificationsHistory();
    notifications.insert(0, 'Жаңы чыгаша кошулду [$category]: "$title" — $amount $currencySymbol');

    await _box.put('total_balance', totalBalance);
    await _box.put('bakyt_balance', bakytBalance);
    await _box.put('aibek_balance', aibekBalance);
    await _box.put(_expensesKey, expenses.map((e) => e.toMap()).toList());
    await _box.put(_notifsKey, notifications);
  }

  // ОҢДОЛДУ: Жазылуулар демейки боюнча кандайдыр бир валюта жана категория менен кошулат
  Future<void> syncAddSubscription({
    required String name,
    required double price,
    required int paymentDay,
    String currency = 'USD', // Демейки боюнча жазылуулар USD же каалаган валютада
  }) async {
    final int subId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final subscriptions = getSubscriptions();
    
    final newSub = SubscriptionModel(
      id: subId.toString(),
      name: name,
      price: price,
      paymentDay: paymentDay,
    );
    subscriptions.insert(0, newSub);

    String currentLang = _box.get('current_language', defaultValue: 'ky');
    String subLabel = (currentLang == 'en') ? 'PASS' : 'АБОНЕМЕНТ';

    final expenses = getExpenses();
    
    // ОҢДОЛДУ: Жазылуу чыгашасы автоматтык түрдө түзүлгөндө дефолт маанилер берилди
    final autoExpense = ExpenseModel(
      title: '$name ($subLabel)',
      amount: price,
      date: DateTime.now(),
      currency: currency,
      category: 'Развлечение', // Же туруктуу 'Подписки' деп койсоңуз болот
    );
    expenses.insert(0, autoExpense);

    double priceInUsd = _convertToUsd(price, currency);

    double totalBalance = getTotalBalance() + priceInUsd;
    double share = priceInUsd / 3;
    double bakytBalance = getBakytBalance() + share;
    double aibekBalance = getAibekBalance() + share;

    String currencySymbol = currency == 'USD' ? '\$' : (currency == 'KGS' ? 'сом' : 'руб');
    final notifications = getNotificationsHistory();
    notifications.insert(
      0,
      'Жаңы жазылуу катталды: $name — $price $currencySymbol (Ар айдын $paymentDay-чи күнү төлөнөт)',
    );

    await _box.put('total_balance', totalBalance);
    await _box.put('bakyt_balance', bakytBalance);
    await _box.put('aibek_balance', aibekBalance);
    await _box.put(_subsKey, subscriptions.map((s) => s.toMap()).toList());
    await _box.put(_expensesKey, expenses.map((e) => e.toMap()).toList());
    await _box.put(_notifsKey, notifications);
  }

  Future<void> syncDeleteExpense(int index) async {
    final expenses = getExpenses();
    if (index >= 0 && index < expenses.length) {
      // Ичиндеги өчүрүлө турган чыгашанын өз валютасын эске алуу менен долларга айландырабыз
      double originalAmount = expenses[index].amount;
      String originalCurrency = expenses[index].currency;
      double amountToRemoveInUsd = _convertToUsd(originalAmount, originalCurrency);
      
      String titleToRemove = expenses[index].title;

      expenses.removeAt(index);
      
      double totalBalance = getTotalBalance() - amountToRemoveInUsd;
      double share = amountToRemoveInUsd / 3;
      double bakytBalance = getBakytBalance() - share;
      double aibekBalance = getAibekBalance() - share;

      final notifications = getNotificationsHistory();
      notifications.insert(0, 'Чыгаша өчүрүлдү: "$titleToRemove"');

      await _box.put('total_balance', totalBalance);
      await _box.put('bakyt_balance', bakytBalance);
      await _box.put('aibek_balance', aibekBalance);
      await _box.put(_expensesKey, expenses.map((e) => e.toMap()).toList());
      await _box.put(_notifsKey, notifications);
    }
  }

  Future<void> clearNotifications() async {
    await _box.put(_notifsKey, <String>[]);
  }

  Future<void> settleUpAll() async {
    await _box.put('total_balance', 0.0);
    await _box.put('bakyt_balance', 0.0);
    await _box.put('aibek_balance', 0.0);
    await _box.put(_expensesKey, []);
    await _box.put(_subsKey, []);
    await _box.put(_notifsKey, []);
  }
}
