import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Провайдерлердин жана Блоктордун даректери
import 'core/services/language_provider.dart';
import 'core/services/supabase_provider.dart';
import 'core/state/auth_bloc.dart'; 
import 'core/state/ledger_manager_bloc.dart';
import 'core/state/currency_bloc.dart'; 
import 'views/auth_gate.dart';     

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase ишке киргизүү
  await Supabase.initialize(
    url: 'https://iswtuketohftclhmncyi.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_CqCzKytkrPQyKlWlhhe-gA_RIIi1XGG', 
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

  // Hive кутучаларын ачуу
  await Hive.openBox('groups_box');
  await Hive.openBox('billbuddy_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
        
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()), 

        BlocProvider<CurrencyBloc>(
          create: (_) => CurrencyBloc()..add(InitCurrencyEvent()),
        ),

        // Глобалдык LedgerManagerBloc бир гана жолу ушул жерде түзүлөт жана маалыматтарды жүктөйт
        BlocProvider<LedgerManagerBloc>(
          create: (_) => LedgerManagerBloc()..add(LoadExpenses()),
        ),
      ],
      child: const BillBuddyApp(),
    ),
  );
} // main() функциясынын жабылуу кашаасы өз ордуна келди


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
      brightness: Brightness.dark, 
    ),
    home: const AuthGate(),
    // БУЛ ЖЕРГЕ МАРШРУТТАРДЫ КОШУҢУЗ:
    routes: {
      '/auth': (context) => const AuthGate(), // же сиздин кирүү экраныңыздын классы (мис: SignInScreen())
    },
  );
}
}
