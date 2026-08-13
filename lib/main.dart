import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Провайдерлердин жана Блоктордун жаңы коопсуз даректери
import 'core/services/language_provider.dart';
import 'core/services/supabase_provider.dart';
import 'core/state/auth_bloc.dart'; // Сиздин AuthBloc жаңы папкадагы так дареги
import 'core/state/ledger_manager_bloc.dart';
import 'core/state/currency_bloc.dart'; // ➡️ ЖАҢЫ КОШУЛДУ: Валюта блогунун импорту
import 'views/auth_gate.dart';     // Биз жаңылаган Авторизация дарбазасы

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase ишке киргизүү (Чыныгы шилтемелер тырмакчада болот)
  await Supabase.initialize(
    url: 'https://iswtuketohftclhmncyi.supabase.co',// Сиздин чыныгы URL дарегиңиз
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

  // Жок кылынган пуш-билдирүү тутумунун инициализациясы алып салынды.
  // Бул тиркеменин коопсуз күйүшүн камсыздайт.

  // Hive кутучаларын ачуу
  await Hive.openBox('groups_box');
  await Hive.openBox('billbuddy_box');

  runApp(
    // Провайдерлер менен Блоктор бириктирилди, эски өчүрүлгөн ExpenseProvider алып салынды
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
        
        // AuthBloc глобалдык даракка коопсуз кайтарылды
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()), 

        // Валюта блогу тиркеме ачылганда эле иштей тургандай катталды
        BlocProvider<CurrencyBloc>(
          create: (_) => CurrencyBloc()..add(InitCurrencyEvent()),
        ),
      ],
      child: const BillBuddyApp(),
    ),
  );
}

class BillBuddyApp extends StatelessWidget {
  const BillBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ЖАНЫ СТРАТЕГИЯ: LedgerManagerBloc тиркеменин эң башына катталды
    return BlocProvider<LedgerManagerBloc>(
      create: (context) => LedgerManagerBloc(),
      child: MaterialApp(
        title: 'BillBuddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto', 
          useMaterial3: true,
          brightness: Brightness.dark, // Бардык экрандардын кочкул болушу үчүн
        ),
        home: const AuthGate(),
      ),
    );
  }
}
