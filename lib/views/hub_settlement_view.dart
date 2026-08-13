import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';
import 'hub_charge_create_view.dart';
import '../core/state/currency_bloc.dart';


class HubSettlementView extends StatefulWidget {
  final Map group;
  final int groupIndex;

  const HubSettlementView({
    super.key,
    required this.group,
    required this.groupIndex,
  });

  @override
  State<HubSettlementView> createState() => _HubSettlementViewState();
}

class _HubSettlementViewState extends State<HubSettlementView> {
  
  
  IconData _getIconForType(String type) {
    if (type == 'РЕСТОРАН' || type == 'Restaurant') return Icons.restaurant_rounded;
    if (type == 'Транспорт' || type == 'Transport') return Icons.directions_car_rounded;
    if (type == 'Көңүл ачуу' || type == 'Entertainment') return Icons.celebration_rounded;
    return Icons.more_horiz_rounded;
  }

  void _executeDatabaseCleanup(int groupId) {
    try {
      context.read<LedgerManagerBloc>().add(SettleUpGroupEvent(groupId: groupId));
    } catch (e) {
      debugPrint('Settle Up катасы: $e');
    }
  }

  void _settleUpGroup(double totalAmount, String groupName, int groupId, LanguageProvider langProvider) {
    if (totalAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('all_debts_closed')),
          backgroundColor: const Color(0xFF4ADE80),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E252B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          langProvider.translate('settle_dialog_title'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '${langProvider.translate('settle_dialog_desc')} "$groupName" (\$$totalAmount)?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(langProvider.translate('cancel'), style: const TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _executeDatabaseCleanup(groupId);
              setState(() {});
            },
            child: Text(
              langProvider.translate('yes'),
              style: const TextStyle(color: Color(0xFF12161A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String activeLang = langProvider.currentLang;
    AppStrings.getTranslation(activeLang);
    final translations = AppStrings.getTranslation(activeLang);


    
    final groupName = (widget.group['name'] ?? 'Bez nazvaniya') as String;
    final imagePath = (widget.group['imagePath'] ?? '') as String; 
    final groupType = (widget.group['category'] ?? 'Другое') as String;
    final int groupId = widget.groupIndex; 

  
    String displayType = langProvider.translate('type_other');
    if (groupType == 'РЕСТОРАН' || groupType == 'Restaurant') {
      displayType = langProvider.translate('type_restaurant');
    } else if (groupType == 'Транспорт' || groupType == 'Transport') {
      displayType = langProvider.translate('type_transport');
    } else if (groupType == 'Көңүл ачуу' || groupType == 'Entertainment') {
      displayType = langProvider.translate('type_entertainment');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          groupName, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
        builder: (context, state) {
          double totalSpent = 0.0;
          List<dynamic> currentExpenses = [];

          if (state is LedgerManagerLoaded) {
            for (var h in state.hubs) {
              if (h['id'] == groupId) {
                currentExpenses = h['expenses'] ?? [];
                for (var exp in currentExpenses) {
                  totalSpent += (exp['amount'] ?? 0.0).toDouble();
                }
                break;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E252B),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12161A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4ADE80), width: 1.5),
                        ),
                        child: imagePath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(File(imagePath), fit: BoxFit.cover),
                              )
                            : Icon(_getIconForType(groupType), color: const Color(0xFF4ADE80), size: 34),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        groupName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${langProvider.translate('group_direction_label')}: $displayType',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                 Expanded(
  child: currentExpenses.isEmpty
      ? Center(
          child: Text(
            // Текст AppStrings файлынан таза окулат
            translations['no_expenses_message'] ?? 'Чыгашалар азырынча жок',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        )
      : BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, currencyState) {
            final String symbol = currencyState.service.getSymbol(currencyState.selectedCurrency);

            return ListView.builder(
              itemCount: currentExpenses.length,
              itemBuilder: (context, index) {
                final expense = currentExpenses[index];
                final int expenseId = (expense['id'] ?? 0) as int;
                final String desc = expense['description'] ?? 'Чыгаша';
                final double amt = (expense['amount'] ?? 0.0).toDouble();

                // Доллар суммасын тандалган валютага айлантуу
                final double displayAmt = currencyState.convertFromUsd(amt);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E252B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(desc, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${displayAmt.toStringAsFixed(2)} $symbol', 
                            style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 14),
                          ),
                        ],
                      ),
                      // ӨЧҮРҮҮ БАСКЫЧЫ
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                        onPressed: () {
                          context.read<LedgerManagerBloc>().add(
                            DeleteExpenseEvent(id: expenseId),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
),
            
                
                const SizedBox(height: 10),

                // Кнопкалар: Расход кошуу жана Эсептешүү
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, color: Color(0xFF4ADE80)),
                          label: Text(
                            langProvider.translate('add_new_expense_btn'),
                            style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HubChargeCreateView(
                                  groupId: groupId,
                                  groupName: groupName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E252B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFF64748B), width: 0.5),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _settleUpGroup(totalSpent, groupName, groupId, langProvider),
                          child: Text(
                            langProvider.translate('settle_up_btn'),
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}


