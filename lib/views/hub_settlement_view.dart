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
    if (type == 'Көңүл ачуу' || type == 'Entertainment' || type == 'Развлечение' || type == 'type_entertainment') {
      return Icons.celebration_rounded;
    }
    return Icons.more_horiz_rounded;
  }

  void _executeDatabaseCleanup(int groupId) {
    try {
      context.read<LedgerManagerBloc>().add(SettleUpGroupEvent(groupId: groupId));
    } catch (e) {
      debugPrint('Settle Up катасы: $e');
    }
  }

  void _settleUpGroup(double totalAmount, String groupName, int groupId, LanguageProvider langProvider, String currentSymbol) {
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
          '${langProvider.translate('settle_dialog_desc')} "$groupName" ($currentSymbol${totalAmount.toStringAsFixed(2)})?',
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
    final translations = AppStrings.getTranslation(activeLang);

    final groupName = (widget.group['name'] ?? 'Bez nazvaniya') as String;
    final imagePath = (widget.group['imagePath'] ?? '') as String; 
    final groupType = (widget.group['category'] ?? 'Другое') as String;
    
    final int groupId = widget.group['id'] != null
        ? (int.tryParse(widget.group['id'].toString()) ?? widget.groupIndex)
        : widget.groupIndex;

    final double groupLimit = widget.group['limit_amount'] != null 
        ? (widget.group['limit_amount']).toDouble() 
        : (widget.group['limit'] != null ? (widget.group['limit']).toDouble() : 0.0);

    // Категорияны локализациялоо
    String displayType = translations['type_other'] ?? 'Другое';
    if (groupType == 'РЕСТОРАН' || groupType == 'Restaurant' || groupType == 'type_restaurant') {
      displayType = translations['type_cafe'] ?? 'Кафе/Праздник';
    } else if (groupType == 'Транспорт' || groupType == 'Transport' || groupType == 'type_transport') {
      displayType = translations['type_travel'] ?? 'Поездки';
    } else if (groupType == 'Entertainment' || groupType == 'Развлечение' || groupType == 'type_entertainment' || groupType == 'Көңүл ачуу') {
      displayType = translations['type_entertainment'] ?? 'Развлечения';
    } else if (groupType == 'Housing' || groupType == 'Жильё' || groupType == 'type_housing') {
      displayType = translations['type_housing'] ?? 'Жильё';
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
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, currencyState) {
          final String currentSymbol = currencyState.service.getSymbol(currencyState.selectedCurrency);

          return BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
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

              final double displayTotalSpent = currencyState.convertFromUsd(totalSpent);
              final double displayLimit = currencyState.convertFromUsd(groupLimit);

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      
                      // БАШКЫ СЕРЫЙ КАРТОЧКА
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Направление: $displayType',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$currentSymbol${displayTotalSpent.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: const Color(0xFF4ADE80),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Лимит бюджета: $currentSymbol${displayLimit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ОРТОДОГУ БОШ ТЕКСТ / ЧЫГАШАЛАРДЫН ТИЗМЕСИ
                      Expanded(
                        child: currentExpenses.isEmpty
                            ? Center(
                                child: Text(
                                  translations['no_expenses_yet'] ?? 'Расходы пока отсутствуют',
                                  style: const TextStyle(color: Color(0xFF475569), 
                                  fontSize: 16),),): ListView.builder(padding: const EdgeInsets.symmetric(vertical: 16),
                                  itemCount: currentExpenses.length,itemBuilder: (context, index) {
                                    final expense = currentExpenses[index];
                                    final expAmount = currencyState.convertFromUsd((expense['amount'] ?? 0.0).toDouble());
                                    final expTitle = expense['title'] ?? 'Расход';
                                    return ListTile(title: Text(expTitle, 
                                    style: const TextStyle(color: Colors.white)),trailing: 
                                    Text('$currentSymbol${expAmount.toStringAsFixed(2)}', 
                                    style: const TextStyle(color: Colors.white)),);},),),
                                    // ТӨМӨНКҮ ЭКИ БАСКЫЧ (ОҢДОЛДУ)
                                    Row(children: [
                                     // Добавить расход баскычы
Expanded(
  child: OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFF334155)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
             onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HubChargeCreateView(
            group: widget.group,
            groupIndex: widget.groupIndex,
            groupId: groupId,       // Муну да кошобуз
            groupName: groupName,   // Муну да кошобуз
          ),
        ),
      );
    },

    icon: const Icon(Icons.add, color: Color(0xFF4ADE80), size: 18),
    label: const Text(
      'Добавить\nрасход',
      textAlign: TextAlign.center,
      style: TextStyle(color: Color(0xFF4ADE80), fontSize: 14, height: 1.2),
    ),
  ),
),
const SizedBox(width: 12),

                                        // Рассчитаться баскычы
                                        Expanded(
                                          child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E252B),
                                          padding: const EdgeInsets.symmetric(vertical: 22),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
                                          side: const BorderSide(color: Color(0xFF334155)),),elevation: 0,),
                                          onPressed: () => _settleUpGroup(totalSpent,groupName,groupId,langProvider,currentSymbol,),
                                          child: const Text('Рассчитаться',style: TextStyle(color: Colors.white, 
                                          fontSize: 14, fontWeight: FontWeight.w600),),),),],),
                                          const SizedBox(height: 8),],),),);},);},),);}}
