import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/app_strings.dart';

class LanguageProvider with ChangeNotifier {
  final String _boxName = 'billbuddy_box';
  final String _langKey = 'current_language';

  // Баштапкы тил - кыргыз тили ('ky')
  String _currentLang = 'ky';

  String get currentLang => _currentLang;

  LanguageProvider() {
    _loadLanguage();
  }

  // Телефондун эс тутумунан сакталган тилди окуу
  void _loadLanguage() async {
    var box = await Hive.openBox(_boxName);
    _currentLang = box.get(_langKey, defaultValue: 'ky');
    notifyListeners();
  }

  // Тилди алмаштыруу жана Hive'га сактоо
  void changeLanguage(String langCode) async {
    _currentLang = langCode;
    notifyListeners(); // Экрандагы тилдерди дароо жаңылайт

    var box = Hive.box(_boxName);
    await box.put(_langKey, langCode);
  }

  // Экранга сөздөрдү тандалган тилде кайтаруучу негизги функция
  String translate(String key) {
    switch (_currentLang) {
      case 'ru':
        return AppStrings.ru[key] ?? key;
      case 'en':
        return AppStrings.en[key] ?? key;
      case 'ky':
      default:
        return AppStrings.ky[key] ?? key;
    }
  }
}
