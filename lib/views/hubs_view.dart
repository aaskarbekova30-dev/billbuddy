import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/state/currency_bloc.dart';
import '../core/state/ledger_manager_bloc.dart';
import 'hub_settlement_view.dart';

class HubsView extends StatefulWidget {
  const HubsView({super.key});

  @override
  State<HubsView> createState() => _HubsViewState();
}

class _HubsViewState extends State<HubsView> {
  late TextEditingController _nameController;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _limitController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String activeLang = langProvider.currentLang;
    final translations = AppStrings.getTranslation(activeLang);

    final String hubsTitle = langProvider.translate('hubs_title');
    final String createHubText = langProvider.translate('create_hub');

    final currencyState = context.read<CurrencyBloc>().state;
    final String currentSymbol = currencyState.service.getSymbol(currencyState.selectedCurrency);

    String actionBtnText = activeLang == 'ky' ? "Кошуу" : activeLang == 'ru' ? "Добавить" : "Add";
        return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          hubsTitle.isNotEmpty ? hubsTitle : 'Кошельки',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Color(0xFF2ECC71)),
                label: Text(
                  createHubText.isNotEmpty ? createHubText : 'Создать новый кошелек',
                  style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  _nameController.clear();
                  _limitController.clear();
                  String internalSelectedCategory = 'Entertainment';

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF1E252B),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (sheetContext) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                          top: 24, left: 24, right: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translations['create_hub'] ?? 'Жаңы капчык түзүү',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: activeLang == 'ky' ? 'Капчыктын аталышы' : activeLang == 'ru' ? 'Название кошелька' : 'Wallet name',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true, fillColor: const Color(0xFF12161A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _limitController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '${translations['budget_limit'] ?? 'Бюджеттин лимити'} ($currentSymbol)',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true, fillColor: const Color(0xFF12161A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text('Категорияны тандаңыз:', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                                                        StatefulBuilder(
                              builder: (sheetContext, setModalState) {
                                final List<Map<String, dynamic>> myCategories = [
                                  {'id': 'Restaurant', 'labelKey': 'cat_restaurant', 'icon': Icons.restaurant_rounded, 'def': 'Ресторан'},
                                  {'id': 'Transport', 'labelKey': 'cat_transport', 'icon': Icons.directions_car_rounded, 'def': 'Транспорт'},
                                  {'id': 'Entertainment', 'labelKey': 'cat_entertainment', 'icon': Icons.celebration_rounded, 'def': 'Развлечение'},
                                  {'id': 'Other', 'labelKey': 'cat_other', 'icon': Icons.more_horiz_rounded, 'def': 'Другое'},
                                ];

                                return Wrap(
                                  spacing: 10, runSpacing: 10,
                                  children: myCategories.map((cat) {
                                    final bool isSelected = internalSelectedCategory == cat['id'];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => setModalState(() => internalSelectedCategory = cat['id']!),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF2ECC71) : const Color(0xFF12161A),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF1E3A2F), width: 1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(cat['icon'], color: isSelected ? const Color(0xFF12161A) : const Color(0xFF4ADE80), size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              translations[cat['labelKey']] ?? cat['def'],
                                              style: TextStyle(color: isSelected ? const Color(0xFF12161A) : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  if (_nameController.text.trim().isNotEmpty) {
                                    final double parsedLimit = double.tryParse(_limitController.text.trim()) ?? 0.0;
                                    
                                    // Маалымат базага катасыз сакталышы үчүн ивент оңдолду
                                    context.read<LedgerManagerBloc>().add(
                                      CreateHubEvent(
                                        name: _nameController.text.trim(),
                                        limitAmount: parsedLimit,
                                        limit: parsedLimit,
                                        category: internalSelectedCategory,
                                      ),
                                    );
                                    Navigator.pop(sheetContext);
                                  }
                                },
                                child: Text(actionBtnText, style: const TextStyle(color: Color(0xFF12161A), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
                         Expanded(
              child: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
                builder: (context, state) {
                  if (state is LedgerManagerLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
                  }

                  if (state is LedgerManagerError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
                  }

                  if (state is LedgerManagerLoaded) {
                    if (state.hubs.isEmpty) {
                      return const Center(child: Text("Капчыктар азырынча жок", style: TextStyle(color: Colors.white54)));
                    }

                    return ListView.builder(
                      itemCount: state.hubs.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> group = state.hubs[index];
                        
                        // 1. БАЛАНСТЫ АВТОМАТТЫК ЭСЕПТӨӨ: Блоктон келген чыгашалардын жалпы суммасын кошобуз
                        double calculatedBalance = 0.0;
                        if (group['expenses'] != null && group['expenses'] is List) {
                          for (var exp in group['expenses']) {
                            calculatedBalance += (exp['amount'] as num?)?.toDouble() ?? 0.0;
                          }
                        }

                        // 2. ЛИМИТТИН АТЫ ОҢДОЛДУ: Блокко ылайык 'limit_amount' деп окуйбуз
                        final double baseLimit = (group['limit_amount'] as num?)?.toDouble() ?? 0.0;

                        const double kgsRate = 89.5;
                        const double rubRate = 92.0;

                        // Профилде тандалган валютаны Блок аркылуу автоматтык аныктоо
                        final String selectedCurrencyCode = context.read<CurrencyBloc>().state.selectedCurrency.toString().toUpperCase();
                        
                        double displayBalance = calculatedBalance;
                        double displayLimit = baseLimit;
                        String currencySymbol = '\$';

                        if (selectedCurrencyCode.contains('KGS')) {
                          displayBalance = calculatedBalance * kgsRate;
                          displayLimit = baseLimit * kgsRate;
                          currencySymbol = 'сом';
                        } else if (selectedCurrencyCode.contains('RUB')) {
                          displayBalance = calculatedBalance * rubRate;
                          displayLimit = baseLimit * rubRate;
                          currencySymbol = 'руб';
                        }

                        final String balanceText = displayBalance.toStringAsFixed(displayBalance % 1 == 0 ? 0 : 1);
                        final String limitText = displayLimit.toStringAsFixed(displayLimit % 1 == 0 ? 0 : 1);

                        // Категорияны окуу
                        final String dbCategory = group['category'] ?? 'Other';
                        String displayCategory = 'Другое';
                        if (dbCategory == 'Restaurant') displayCategory = translations['cat_restaurant'] ?? 'Ресторан';
                        if (dbCategory == 'Transport') displayCategory = translations['cat_transport'] ?? 'Транспорт';
                        if (dbCategory == 'Entertainment') displayCategory = translations['cat_entertainment'] ?? 'Развлечение';
                        if (dbCategory == 'Other') displayCategory = translations['cat_other'] ?? 'Другое';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HubSettlementView(
                                  group: group,
                                  groupIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E252B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(group['name'] ?? 'Капчык', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(displayCategory, style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () {
                                        context.read<LedgerManagerBloc>().add(SettleUpGroupEvent(groupId: group['id']));
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(translations['budget_limit'] ?? 'Лимит бюджета', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                    Text(
                                      "$balanceText / $limitText $currencySymbol", 
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
          

