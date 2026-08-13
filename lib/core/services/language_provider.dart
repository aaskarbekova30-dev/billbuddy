import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'ru'; // Демейки тил
  Map<String, String> _localizedStrings = {};

  String get currentLang => _currentLang;

  LanguageProvider() {
    _initLanguage(); // Инициализация учурунда тилди асинхрондуу жүктөйт
  }

  // Асинхрондуу түрдө телефондун эстутумунан тандалган тилди жүктөө
  Future<void> _initLanguage() async {
    try {
      final box = Hive.box('billbuddy_box');
      _currentLang = box.get('app_language', defaultValue: 'ru');
    } catch (e) {
      _currentLang = 'ru';
    }
    // Жаңыланган AppStrings аркылуу сөздүктү коопсуз тартабыз
    _localizedStrings = AppStrings.getTranslation(_currentLang);
    notifyListeners();
  }

  // Тилди реалдуу убакытта алмаштыруу жана Hive кутусуна сактоо
  Future<void> changeLanguage(String newLangCode) async {
    if (_currentLang == newLangCode) return;

    _currentLang = newLangCode;
    _localizedStrings = AppStrings.getTranslation(newLangCode);
    
    try {
      final box = Hive.box('billbuddy_box');
      await box.put('app_language', newLangCode);
    } catch (e) {
      debugPrint('Тилди сактоодо ката: $e');
    }

    notifyListeners(); // Бардык экрандарды реалдуу убакытта жаңылоо
  }

  // ЭКРАНГА СӨЗДӨРДҮ ТАНДАЛГАН ТИЛДЕ КАЙТАРУУЧУ НЕГИЗГИ ФУНКЦИЯ (Switch-case жок, таза вариант)
  String translate(String key) {
    return _localizedStrings[key] ?? key; // Эгер ачкыч табылбаса, ката бербей өзүн калтырат
  }
}
