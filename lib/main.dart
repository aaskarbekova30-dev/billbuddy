import 'package:billbuddy/logic/providers/expense_provider.dart';
import 'package:billbuddy/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
// Дарегин текшерип коюңуз

// 🔥 ДАРОО КОШУЛДУ: Тил провайдеринин файлы
import 'package:billbuddy/logic/providers/language_provider.dart';

// Билдирүү тутумунун импорту
import 'package:billbuddy/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🌟 ЖАҢЫ КОШУЛДУ: Жаңы навигация экранын бул жерге импорттодук
import 'logic/providers/supabase_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fsrkrdadsqgxgiyjmhxq.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_4c10uxNTK6uBU6M8QL0sRw_5Z3cPvpA',
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
    // 💡 ОҢДОЛГОН: Бир нече провайдерди чогуу каттоо үчүн MultiProvider колдонулду
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
      // 🌟 ОҢДОЛДУ: Эми тиркеме түз эле навигация менюсу бар баракты ачат
      home: const AuthGate(),
    );
  }
}
