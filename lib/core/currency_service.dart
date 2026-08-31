import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiUrl = 'https://frankfurter.app';

  // Камдык курстар
  final Map<String, double> rates = {
    'USD': 1.0,
    'KGS': 87.5,
    'RUB': 91.0,
  };

  Future<void> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final fetchedRates = data['rates'] as Map<String, dynamic>;
        
        rates['KGS'] = (fetchedRates['KGS'] as num).toDouble();
        rates['RUB'] = (fetchedRates['RUB'] as num).toDouble();
        rates['USD'] = 1.0;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Курстарды жүктөөдө ката кетти: $e");
    }
  }

  String getSymbol(String currencyCode) {
    switch (currencyCode) {
      case 'KGS': return 'С';
      case 'RUB': return '₽';
      default: return '\$';
    }
  }
}
