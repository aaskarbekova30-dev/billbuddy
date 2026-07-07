class ExpenseModel {
  final String title;
  final double amount;
  final DateTime date;

  ExpenseModel({required this.title, required this.amount, required this.date});

  // Маалыматты телефондун файлына текст (карта) түрүндө сактоо үчүн
  Map<String, dynamic> toMap() {
    return {'title': title, 'amount': amount, 'date': date.toIso8601String()};
  }

  // 🌟 ЖАҢЫЛАНДЫ: Эми маалымат кандай типте келбесин тиркеме такыр сынбайт!
  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;

    if (rawDate is DateTime) {
      parsedDate = rawDate; // Эгер базада даяр DateTime болсо, түз эле алат
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(
        rawDate,
      ); // Эгер Текст болсо, убакытка айландырат
    } else {
      parsedDate =
          DateTime.now(); // Эгер бош же белгисиз болсо, азыркы убакты коёт
    }

    return ExpenseModel(
      title: (map['title'] ?? '') as String,
      amount: (map['amount'] ?? 0.0) as double,
      date: parsedDate,
    );
  }
}
