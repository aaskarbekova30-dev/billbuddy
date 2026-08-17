import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Экран ачылганда базадан баардык маалыматтарды жаңылап жүктөйт
  void _refreshData() {
    context.read<LedgerManagerBloc>().add(LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String currentLang = langProvider.currentLang;

    final bool isKy = currentLang == 'ky';
    final bool isRu = currentLang == 'ru';

    String balanceTitle = isKy ? "ЖАЛПЫ БАЛАНС" : (isRu ? "ОБЩИЙ БАЛАНС" : "TOTAL BALANCE");
    String recentExpensesTitle = isKy ? "Акыркы чыгашалар" : (isRu ? "Последние расходы" : "Recent Expenses");
    String noExpensesText = isKy ? "Чыгымдар азырынча жок" : (isRu ? "Расходов пока нет" : "No expenses yet");
    String upcomingSubTitle = isKy ? "Жакынкы төлөмдөр" : (isRu ? "Ближайшие платежи" : "Upcoming Payments");

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: const Color(0xFF4ADE80),
          backgroundColor: const Color(0xFF1E252B),
          child: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
            builder: (context, state) {
              double totalBalance = 0.0;
              List<Map<String, dynamic>> allRecentExpenses = [];
              List<dynamic> subsList = [];

              // Блок Loaded абалында болгондо капчыктарды жана алардын ичиндеги чыгашаларды окуйбуз
              if (state is LedgerManagerLoaded) {
                final List<dynamic> hubsList = state.hubs;
                subsList = state.subscriptions; // Абонементтер

                for (var hub in hubsList) {
                  if (hub != null) {
                    // Ар бир капчыктын ичиндеги чыгашалардын тизмеси
                    final List<dynamic> expList = hub['expenses'] ?? [];
                    for (var exp in expList) {
                      if (exp != null) {
                        final double amt = (exp['amount'] ?? 0.0).toDouble();
                        totalBalance += amt; // Чыгашаларды жалпы баланска кошуу

                        // Акыркы чыгашалардын тизмесине кошуу
                        allRecentExpenses.add({
                          'id': exp['id'],
                          'description': (exp['description'] ?? '').toString().trim(),
                          'amount': amt,
                          'date': exp['created_at'] ?? '',
                          'hub_name': (hub['name'] ?? '') as String, // Кайсы капчыкка таандык экени
                        });
                      }
                    }
                  }
                }
                // Акыркы кошулган чыгашаларды эң өйдө жагына сорттоо (датасы боюнча)
                allRecentExpenses.sort((a, b) => (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
              }

              return SingleChildScrollView(
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
                            '-₽${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFFFB7185), fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. ЖАКЫНКЫ ТӨЛӨМДӨР (АБОНЕМЕНТТЕР)
                    Text(
                      upcomingSubTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (subsList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E252B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            isKy ? "Жазылуулар азырынча жок" : "Подписок пока нет", 
                            style: const TextStyle(color: Color(0xFF64748B))
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subsList.length,
                        itemBuilder: (context, index) {
                          final sub = subsList[index];
                          final String subName = sub['name'] ?? 'Подписка';
                          final double subAmount = (sub['amount'] ?? 0.0).toDouble();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E252B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: const Color(0xFF12161A), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    subName.toLowerCase().contains('тренировка') || subName.toLowerCase().contains('фитнес') || subName.toLowerCase().contains('ддх')
                                        ? Icons.fitness_center_rounded
                                        : (subName.toLowerCase().contains('medium') ? Icons.book_rounded : Icons.card_membership_rounded),
                                    color: const Color(0xFF4ADE80), size: 20
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    subName,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  "-₽${subAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // 3. АКЫРКЫ ЧЫГЫШАЛАР БӨЛҮМҮ (Капчыктардагы чыныгы чыгашалар ушул жерге чыгат!)
                    Text(
                      recentExpensesTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (allRecentExpenses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E252B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            noExpensesText,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allRecentExpenses.length > 5 ? 5 : allRecentExpenses.length, // Акыркы 5 чыгашаны гана көрсөтөт
                        itemBuilder: (context, index) {final expense = allRecentExpenses[index];final String desc = expense['description'];final double amt = expense['amount'];final String hubName = expense['hub_name']; // Кайсы капчыктан коротулганы
                        return Container(margin: const EdgeInsets.only(bottom: 12),padding: const EdgeInsets.all(16),decoration: BoxDecoration(color: const Color(0xFF1E252B),borderRadius: BorderRadius.circular(20),),child: Row(children: [Container(width: 40, height: 40,decoration: BoxDecoration(color: const Color(0xFF221314),borderRadius: BorderRadius.circular(12),),child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFFEF4444), size: 20),),const SizedBox(width: 14),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(desc.isEmpty ? "Чыгым" : desc,style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),),const SizedBox(height: 3),Text(hubName,
                         // Капчыктын аты (мис: Свадьба, Вечеринка)
                         style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),),],),),Text("-₽${amt.toStringAsFixed(2)}",style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),],),);},),],),);},),),),);}}
