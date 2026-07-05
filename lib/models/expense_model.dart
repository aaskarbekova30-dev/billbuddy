class ExpenseModel {
  final String title;
  final double amount;
  final DateTime date;

  ExpenseModel({required this.title, required this.amount, required this.date});

  // Жаңы кошулду: Маалыматты телефондун файлына текст (карта) түрүндө сактоо үчүн
  Map<String, dynamic> toMap() {
    return {'title': title, 'amount': amount, 'date': date.toIso8601String()};
  }

  // Жаңы кошулду: Телефондун файлынан маалыматты кайра окуп алуу үчүн
  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseModel(
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
