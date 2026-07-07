import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Провайдер кошулду
import 'groups_screen.dart';   
import 'analytics_screen.dart';
import '../logic/providers/language_provider.dart';
import 'screens/dashboard_screen.dart'; // Тил провайдери

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), 
    const GroupsScreen(),    
    const AnalyticsScreen(), 
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
          // 🌟 ОҢДОЛДУ: Менюнун жазуулары да тил файлдарынан динамикалык окулат
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: langProvider.currentLang == 'ky' ? 'Башкы бет' : (langProvider.currentLang == 'ru' ? 'Главная' : 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            activeIcon: const Icon(Icons.group),
            label: langProvider.translate('my_groups_title'),
          ),
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
