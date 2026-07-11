import 'package:billbuddy/expenses_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'groups_screen.dart';   
import 'analytics_screen.dart';
import '../logic/providers/language_provider.dart';
import 'screens/dashboard_screen.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 🌟 ТАРТИБИ ОҢДОЛДУ: Экрандар төмөнкү иконкалардын кезеги менен бирдей болушу керек
  final List<Widget> _screens = [
    const DashboardScreen(),     // 1. Башкы бет (Dashboard)
    const MyExpensesPage(),       // 2. Жаңы түзүлгөн Чыгымдар экраны
    const GroupsScreen(),         // 3. Группалар
    const AnalyticsScreen(),      // 4. Статистика
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF182747), 
        selectedItemColor: const Color(0xFF00E676), 
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          // 1. Башкы бет
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: langProvider.currentLang == 'ky' ? 'Башкы бет' : (langProvider.currentLang == 'ru' ? 'Главная' : 'Home'),
          ),
          // 2. Жаңы кошулган Чыгымдар бөлүмү
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_outlined),
            activeIcon: const Icon(Icons.list_alt),
            label: langProvider.currentLang == 'ky' ? 'Чыгымдар' : (langProvider.currentLang == 'ru' ? 'Расходы' : 'Expenses'),
          ),
          // 3. Группалар
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            activeIcon: const Icon(Icons.group),
            label: langProvider.translate('my_groups_title'),
          ),
          // 4. Статистика
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart),
            label: langProvider.currentLang == 'ky' ? 'Статистика' : (langProvider.currentLang == 'ru' ? 'Статистика' : 'Analytics'),
          ),
        ],
      ),
    );
  }
}
