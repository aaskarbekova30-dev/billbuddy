class SubscriptionModel {
  final String id;          // Ар бир жазылуу үчүн уникалдуу ID
  final String name;        // Тиркеменин аты (мис: Netflix, Spotify)
  final double price;       // Айына канча төлөнөт (мис: 9.99)
  final int paymentDay;     // Айдын кайсы күнү акча кармалат (мис: 15-чи күнү)

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.paymentDay,
  });

  // Телефондун файлына сактоо үчүн картага (текстке) айландыруу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'paymentDay': paymentDay,
    };
  }

  // Файлдан кайра окуп алуу
  factory SubscriptionModel.fromMap(Map<dynamic, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      paymentDay: map['paymentDay'] as int,
    );
  }
}
