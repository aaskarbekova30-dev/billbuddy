import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart'; // Локализация тутуму
import '../core/state/ledger_manager_bloc.dart';

class HubDetailsView extends StatefulWidget {
  final Map<String, dynamic> hub;

  const HubDetailsView({super.key, required this.hub});

  @override
  State<HubDetailsView> createState() => _HubDetailsViewState();
}

class _HubDetailsViewState extends State<HubDetailsView> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Окно добавления расхода с поддержкой смены языков
  void _showAddExpenseBottomSheet(BuildContext parentContext) {
    final langProvider = Provider.of<LanguageProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E252B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langProvider.translate('add_expense_title').isEmpty ? "Добавить расход в кошелек" : langProvider.translate('add_expense_title'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(langProvider.translate('hint_expense_name').isEmpty ? "Название расхода" : langProvider.translate('hint_expense_name')),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(langProvider.translate('hint_expense_amount').isEmpty ? "Сумма (RUB)" : langProvider.translate('hint_expense_amount')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ADE80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final String title = _titleController.text.trim();
                    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                    final int groupId = widget.hub['id'] as int;

                    if (title.isNotEmpty && amount > 0) {
                      parentContext.read<LedgerManagerBloc>().add(
                        AddExpenseEvent(
                          title: title,
                          amount: amount,
                          groupId: groupId,
                          currency: 'RUB',
                          category: widget.hub['category'] ?? 'Other',
                        ),
                      );
                      
                      _titleController.clear();
                      _amountController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    langProvider.translate('btn_save_expense').isEmpty ? "Сохранить расход" : langProvider.translate('btn_save_expense'),
                    style: const TextStyle(color: Color(0xFF12161A), fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSplitBillDialog(double totalSpent, LanguageProvider langProvider) {
    final memberCountController = TextEditingController(text: "2");
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E252B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(widget.hub['name'] ?? 'Wallet', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${langProvider.translate('total_spent_lbl')} $totalSpent RUB", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              const SizedBox(height: 20),
              const Text("Разделить на сколько человек?", style: TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: memberCountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Количество людей"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final int people = int.tryParse(memberCountController.text.trim()) ?? 1;
                if (people > 0) {
                  final double perPerson = totalSpent / people;
                  Navigator.pop(context);
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF12161A),
                      title: const Text("Результат", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      content: Text(
                        "Каждый человек должен оплатить:\n\n₽${perPerson.toStringAsFixed(2)} RUB",
                        style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK", style: TextStyle(color: Color(0xFF4ADE80))),
                        )
                      ],
                    ),
                  );
                }
              },
              child: const Text("Разделить", style: TextStyle(color: Color(0xFF12161A), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String groupName = widget.hub['name'] ?? 'Wallet';
    final double limitAmount = (widget.hub['limit_amount'] ?? 0.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(groupName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFB7185)),
            onPressed: () {
              context.read<LedgerManagerBloc>().add(SettleUpGroupEvent(groupId: widget.hub['id'] as int));
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
        builder: (context, state) {
          List<dynamic> currentExpenses = [];
          
          if (state is LedgerManagerLoaded) {
            final currentHub = state.hubs.firstWhere(
              (h) => h != null && h['id'] == widget.hub['id'],
              orElse: () => <String, dynamic>{},
            );
            if (currentHub.isNotEmpty) {
              currentExpenses = currentHub['expenses'] ?? [];
            }
          }

          double totalSpent = 0.0;
          for (var exp in currentExpenses) {
            totalSpent += (exp['amount'] ?? 0.0).toDouble();
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Главная карточка лимитов
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1E252B), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       langProvider.translate('total_wallet_limit').isEmpty ? "ОБЩИЙ ЛИМИТ КОШЕЛЬКА" : langProvider.translate('total_wallet_limit'),style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),const SizedBox(height: 6),Text("₽$limitAmount RUB", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),const SizedBox(height: 16),const Divider(color: Color(0xFF12161A)),const SizedBox(height: 10),Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(langProvider.translate('total_spent_lbl').isEmpty ? "Потрачено всего:" : langProvider.translate('total_spent_lbl'),style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),Text("₽$totalSpent RUB", style: const TextStyle(color: Color(0xFFFB7185), fontSize: 16, fontWeight: FontWeight.bold)),],),],),),const SizedBox(height: 24),
                       // Кнопка деления счета
                       if (currentExpenses.isNotEmpty)SizedBox(width: double.infinity,height: 50,child: OutlinedButton.icon(style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4ADE80), width: 1.5),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),),onPressed: () => _showSplitBillDialog(totalSpent, langProvider),icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF4ADE80), size: 20),label: Text(langProvider.translate('split_with_friends').isEmpty ? "Разделить расходы с друзьями" : langProvider.translate('split_with_friends'),style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),),),const SizedBox(height: 30),Text(langProvider.translate('expense_list_lbl').isEmpty ? "Список расходов:" : langProvider.translate('expense_list_lbl'),style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.bold)),const SizedBox(height: 14),
                       // Список расходов в кошельке
                       Expanded(child: currentExpenses.isEmpty? Center(child: Text(langProvider.translate('no_expenses_yet').isEmpty ? "В этом кошельке расходов пока нет" : langProvider.translate('no_expenses_yet'),style: const TextStyle(color: Color(0xFF64748B)))): ListView.separated(physics: const BouncingScrollPhysics(),itemCount: currentExpenses.length,separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E252B)),itemBuilder: (context, index) {final exp = currentExpenses[index];final String desc = exp['description'] ?? 'Expense';final double amt = (exp['amount'] ?? 0.0).toDouble();return ListTile(contentPadding: EdgeInsets.zero,leading: Container(width: 40, height: 40,decoration: BoxDecoration(color: const Color(0xFF12161A), borderRadius: BorderRadius.circular(12)),child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFFFB7185), size: 18),),title: Text(desc, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),trailing: Text("-₽$amt", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),);},),),
                       // Нижняя кнопка добавления
                       SizedBox(width: double.infinity,height: 54,child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),),onPressed: () => _showAddExpenseBottomSheet(context),child: Text(langProvider.translate('btn_save_expense').isEmpty ? "+ Добавить расход" : "+ ${langProvider.translate('btn_save_expense')}",style: const TextStyle(color: Color(0xFF12161A), fontSize: 16, fontWeight: FontWeight.bold)),),),],),);},),);}InputDecoration _inputDecoration(String hint) {return InputDecoration(hintText: hint,hintStyle: const TextStyle(color: Color(0xFF64748B)),fillColor: const Color(0xFF12161A),filled: true,border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),);}} 
