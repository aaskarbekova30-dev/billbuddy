import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _userCurrency = 'RUB'; // Демейки валюта (По умолчанию Рубль)

  @override
  void initState() {
    super.initState();
    _refreshData();
    _loadUserCurrency(); // Экран ачылганда профилдеги валютаны жүктөп келет
  }

  void _refreshData() {
    context.read<LedgerManagerBloc>().add(LoadExpenses());
  }

  // Базадан колдонуучунун тандаган валютасын жүктөө
  Future<void> _loadUserCurrency() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('currency')
          .eq('id', user.id)
          .single();
      if (data['currency'] != null) {
        setState(() {
          _userCurrency = data['currency'].toString().toUpperCase().trim();
        });
      }
    } catch (e) {
      debugPrint('Валютаны жүктөөдө ката: $e');
    }
  }

  // Валюта кодуна карап тиешелүү символду кайтаруучу функция
  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'KGS': return 'с';
      case 'EUR': return '€';
      default: return '₽';
    }
  }

  // ДАТАНЫ ФФОРМАТТООЧУ КАТАСЫЗ КООПСУЗ ФУНКЦИЯ
  String _formatExpenseDate(String? createdAt, String lang) {
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      final DateTime parsedDate = DateTime.parse(createdAt).toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime expenseDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      if (expenseDay == today) {
        return lang == 'ky' ? 'Бүгүн' : (lang == 'en' ? 'Today' : 'Сегодня');
      } else if (expenseDay == yesterday) {
        return lang == 'ky' ? 'Кечээ' : (lang == 'en' ? 'Yesterday' : 'Вчера');
      } else {
        return DateFormat('dd.MM.yyyy').format(parsedDate);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    // Тилге жараша өзгөрүүчү тексттер (AppStrings'ге байланды)
    final translations = AppStrings.getTranslation(currentLang);
    String balanceTitle = translations['balance_title'] ?? "ЖАЛПЫ БАЛАНС";
    String recentExpensesTitle = translations['recent_expenses'] ?? "Акыркы чыгашалар";
    String noExpensesText = translations['no_expenses'] ?? "Чыгымдар азырынча жок";
    String clearAllText = translations['clear_all'] ?? "Баарын өчүрүү";

    final String currencySymbol = _getCurrencySymbol(_userCurrency);

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      body: SafeArea(
        child: BlocConsumer<LedgerManagerBloc, LedgerManagerState>(
          listener: (context, state) {},
          builder: (context, state) {
            double totalBalance = 0.0;
            List<dynamic> allRecentExpenses = [];

            if (state is LedgerManagerLoaded) {
              final List<dynamic> hubsList = state.hubs;
              final String defaultExpenseTitle = translations['expense'] ?? 'Чыгым';

              for (var hub in hubsList) {
                if (hub != null && hub['expenses'] != null) {
                  final List<dynamic> expList = hub['expenses'] ?? [];
                  for (var exp in expList) {
                    if (exp != null) {
                      final double amt = (exp['amount'] ?? 0.0).toDouble();
                      totalBalance += amt;
                      
                      String expDescription = (exp['description'] ?? '').toString().trim();
                      if (expDescription.isEmpty || expDescription == 'Чыгым') {
                        expDescription = defaultExpenseTitle;
                      }

                      allRecentExpenses.add({
                        'id': exp['id'],
                        'description': expDescription,
                        'amount': amt,
                        'date': exp['created_at'] ?? '',
                        'hub_name': (hub['name'] ?? 'Башка') as String,
                      });
                    }
                  }
                }
              }
              // Акыркы кошулган чыгымдарды биринчи көрсөтүү үчүн датасы менен сорттойбуз
              allRecentExpenses.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: const Color(0xFF4ADE80),
              backgroundColor: const Color(0xFF1E252B),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 1. ЖАЛПЫ БАЛАНС КАРТОЧКАСЫ
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E252B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balanceTitle.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+$currencySymbol${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                                        Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E252B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ТУУРАЛАНДЫ: Сол жактагы элементтер экрандан чыкпашы үчүн Expanded ичине алынды
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF221314), 
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFEF4444), size: 20),
                                ),
                                const SizedBox(width: 12),
                                // Бул жерге да Expanded кошулду, узун тексттерди автоматтык түрдө кыскартат
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        translations['spotify_title'] ?? 'Spotify жазылуусу', 
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        translations['spotify_remind'] ?? 'Ар айдын 12синде', 
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // Оң жана сол жактын ортосундагы аралык
                          
                          // ТУУРАЛАНДЫ: Тексттеги өзгөрмө туура форматталды
                          Text(
  '-$currencySymbol' '0.00', // Автоматически склеит символ валюты и цифры
  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
)

                        ],
                      ),
                    ),

                    // 3. АКЫРКЫ ЧЫГАШАЛАРДЫН ТИЗМЕСИ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          recentExpensesTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (allRecentExpenses.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              context.read<LedgerManagerBloc>().add(ClearAllExpensesEvent());
                            },
                            child: Text(
                              clearAllText,
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (state is LedgerManagerLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: Color(0xFF4ADE80)),
                        ),
                      )
                    else if (allRecentExpenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            noExpensesText,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allRecentExpenses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final expense = allRecentExpenses[index];
                          return Dismissible(
                            key: Key(expense['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              // ТУУРАЛАНДЫ: Именной параметр жана кашаалар жабылды
                              context.read<LedgerManagerBloc>().add(DeleteExpenseEvent(id: expense['id']));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E252B),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense['description'],
                                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${expense['hub_name']} • ${_formatExpenseDate(expense['date'], currentLang)}",
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '-$currencySymbol${(expense['amount'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


                  
