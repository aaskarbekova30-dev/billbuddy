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

  // Телефондун эс тутумунан сакталган тилди коопсуз окуу
  void _loadLanguage() async {
    try {
      var box = await Hive.openBox(_boxName);
      _currentLang = box.get(_langKey, defaultValue: 'ky');
      notifyListeners();
    } catch (e) {
      _currentLang = 'ky'; // Ката чыкса дефолттук кыргыз тили калат
      notifyListeners();
    }
  }
    // Тилди алмаштыруу жана Hive'га коопсуз сактоо
  void changeLanguage(String langCode) async {
    _currentLang = langCode;
    notifyListeners(); // Экрандагы тилдерди дароо жаңылайт

    try {
      var box = Hive.box(_boxName);
      await box.put(_langKey, langCode);
    } catch (e) {
      // База убактылуу ачыла элек болсо тиркеме сынбайт
    }
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

