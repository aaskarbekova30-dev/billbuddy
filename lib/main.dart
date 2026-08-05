import 'package:billbuddy/logic/providers/expense_provider.dart';
import 'package:billbuddy/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🌟 ЖАҢЫ КОШУЛДУ
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Провайдерлердин импорттору
import 'package:billbuddy/logic/providers/language_provider.dart';
import 'package:billbuddy/logic/providers/supabase_provider.dart';
import 'package:billbuddy/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Сиздин AuthBloc файлыңыз жайгашкан жолду тактаңыз:
import 'package:billbuddy/logic/bloc/auth_bloc.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Supabase ишке киргизүү
  //  ТУУРА ВАРИАНТ (Чыныгы шилтемелер тырмакчада)
await Supabase.initialize(
  url: 'https://iswtuketohftclhmncyi.supabase.co', // Сиздин чыныгы URL дарегиңиз
  // ignore: deprecated_member_use
  anonKey: 'sb_publishable_CqCzKytkrPQyKlWlhhe-gA_RIIi1XGG', // Жаңы көчүрүп келген узун ачкычыңыз
);



  // Hive базасын ишке киргизүү
  await Hive.initFlutter();

  try {
    await initializeDateFormatting('ky_KG', null);
    await initializeDateFormatting('ru_RU', null);
    await initializeDateFormatting('en_US', null);
  } catch (e) {
    // Ката чыкса, тиркеме коопсуз күйө берет
  }

  // Билдирүү тутумун активдештирүү
  await NotificationService().initNotification();

  // Hive кутучаларын ачуу
  await Hive.openBox('groups_box');
  await Hive.openBox('billbuddy_box');

  runApp(
    // Провайдерлер менен Блоктор бириктирилди
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
        
        // AuthBloc глобалдык даракка кайтарылды
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()), 
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
