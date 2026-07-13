import 'package:billbuddy/app_config.dart'; // 🌟 ЖАҢЫ КОШУЛДУ
import 'package:billbuddy/logic/providers/expense_provider.dart';
import 'package:billbuddy/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Тил провайдеринин файлы
import 'package:billbuddy/logic/providers/language_provider.dart';

// Билдирүү тутумунун импорту
import 'package:billbuddy/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Навигация экранын бул жерге импорттодук
import 'logic/providers/supabase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 КООПСУЗДУК ОҢДОЛДУ: Эми ачкычтар app_config.dart файлынан түз жана туруктуу окулат
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Hive базасын ишке киргизүү
  await Hive.initFlutter();

  try {
    await initializeDateFormatting('ky_KG', null);
    await initializeDateFormatting('ru_RU', null);
    await initializeDateFormatting('en_US', null);
  } catch (e) {
    // Эгер симулятордо ката чыкса, тиркеме баары бир коопсуз күйө берет
  }

  // Тиркеме күйгөндө билдирүү тутумун активдештирүү
  await NotificationService().initNotification();

  // Топторду сактоо үчүн Hive кутучасын ачабыз
  await Hive.openBox('groups_box');
  await Hive.openBox('billbuddy_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
      ],
      child: const BillBuddyApp(),
    ),
  );
}

class BillBuddyApp extends StatelessWidget {
  const BillBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
