import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'ru'; // Демейки тил
  
  // ОҢДОЛДУ: Баштапкы учурда словарь бош болбой, дароо орус тилиндеги сөздөрдү алат!
  // Бул СНГ аудиториясы үчүн тиркеме жаңы ачылганда ачкычтар (keys) көрүнүп калуусунан сактайт.
  Map<String, String> _localizedStrings = AppStrings.getTranslation('ru');

  String get currentLang => _currentLang;

  LanguageProvider() {
    _initLanguage(); 
  }

  Future<void> _initLanguage() async {
    try {
      final box = Hive.box('billbuddy_box');
      _currentLang = box.get('app_language', defaultValue: 'ru');
    } catch (e) {
      _currentLang = 'ru';
    }
    
    _localizedStrings = AppStrings.getTranslation(_currentLang);
    notifyListeners();
  }

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

    notifyListeners(); 
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key; 
  }
}
