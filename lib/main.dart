import 'package:billbuddy/logic/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// 🔥 ДАРОО КОШУЛДУ: Билдирүү тутумунун катасын толук оңдоочу импорт
import 'package:billbuddy/services/notification_service.dart';

import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive базасын ишке киргизүү
  await Hive.initFlutter();

  // Тиркеме күйгөндө билдирүү тутумун активдештирүү
  // Эми бул жерде такыр ката чыкпайт!
  await NotificationService().initNotification();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
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
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const DashboardScreen(), 
    );
  }
}
