import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart';
import 'home_view.dart'; 
import 'hubs_view.dart'; 
import 'timeline_view.dart'; 
import 'user_account_view.dart';
//  ОҢДОЛДУ: MetricsView ордуна профиль барагынын импорту кошулду

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(), 
    const HubsView(),
    const TimelineView(),
    const UserAccountView(), 
  ];
    @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF1E252B).withValues(alpha: 0.5), 
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E252B), // Жумшак боз панель фону
          selectedItemColor: const Color(0xFF4ADE80), // Жалбыз жашыл активдүү түс
          unselectedItemColor: const Color(0xFF94A3B8), // Активдүү эмес түс
          selectedFontSize: 11,
          unselectedFontSize: 11,
          // Тексттин калыңдыгы туура форматка (TextStyle) өткөрүлдү
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.space_dashboard_outlined, size: 22)),
              activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.space_dashboard, size: 22)),
              label: langProvider.translate('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.diversity_3_outlined, size: 22)),
              activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.diversity_3, size: 22)),
              label: langProvider.translate('nav_groups'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.calendar_today_outlined, size: 20)),
              activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.calendar_today, size: 20)),
              label: langProvider.translate('nav_calendar'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.analytics_outlined, size: 22)),
              activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.analytics, size: 22)),
              label: langProvider.translate('nav_analytics'),
            ),
          ],
        ),
      ),
    );
  }
}

