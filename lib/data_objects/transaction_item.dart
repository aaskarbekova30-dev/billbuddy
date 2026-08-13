class ExpenseModel {
  final String title;
  final double amount;
  final DateTime date;
  final String currency; // Жаңы: 'USD', 'KGS' же 'RUB'
  final String category; // Жаңы: 'Ресторан', 'Транспорт', 'Развлечение', 'Другое'

  ExpenseModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.currency, // Конструкторго кошулду
    required this.category, // Конструкторго кошулду
  });

  // Маалыматтар базасына (Supabase/JSON) сактоо үчүн
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'currency': currency, // Базага сакталат
      'category': category, // Базага сакталат
    };
  }

  // Маалыматтар базасынан окуу үчүн
  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;

    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return ExpenseModel(
      title: (map['title'] ?? '') as String,
      amount: (map['amount'] ?? 0.0) as double,
      date: parsedDate,
      currency: (map['currency'] ?? 'USD') as String, // Эгер базада жок болсо, дефолт 'USD'
      category: (map['category'] ?? 'Другое') as String, // Эгер базада жок болсо, дефолт 'Другое'
    );
  }

  // --- ВАЛЮТА КОНВЕРТАЦИЯЛОО ГЕТТЕРЛЕРИ ---
  // Бул жерге учурдагы доллар, сом жана рубль курстарын жазыңыз
  static const double _usdToKgs = 89.5;
  static const double _usdToRub = 92.0;

  // Сумманы автоматтык түрдө 3 валютага тең айландырып берүүчү геттер
  Map<String, double> get multiCurrencyAmounts {
    double amountInUsd = 0;

    // Биринчи кадам: Бардык кирген сумманы АКШ долларына айландырып алабыз
    if (currency == 'USD') {
      amountInUsd = amount;
    } else if (currency == 'KGS') {
      amountInUsd = amount / _usdToKgs;
    } else if (currency == 'RUB') {
      amountInUsd = amount / _usdToRub;
    }

    // Экинчи кадам: Доллардагы сумманы калган валюталарга көбөйтүп кайтарабыз
    return {
      'USD': amountInUsd,
      'KGS': amountInUsd * _usdToKgs,
      'RUB': amountInUsd * _usdToRub,
    };
  }
}
