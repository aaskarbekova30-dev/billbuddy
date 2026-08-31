import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart';
import '../core/services/supabase_provider.dart';

//  Спамга каршы негизги класс аты LogChargeView деп өзгөртүлдү
class LogChargeView extends StatefulWidget {
  const LogChargeView({super.key});

  @override
  State<LogChargeView> createState() => _LogChargeViewState();
}

class _LogChargeViewState extends State<LogChargeView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final supabaseProvider = Provider.of<SupabaseProvider>(context, listen: false);

    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('enter_all_fields')),
          backgroundColor: const Color(0xFFFB7185), //  Жумшак кызыл ката түсү
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;

    // Серверге (Supabase) коопсуз жүктөө
    try {
      supabaseProvider.addExpense(
        title: title,
        amount: amount,
        groupName: 'Общий',
      );
    } catch (e) {
      debugPrint('Серверге кошууда ката: $e');
    }

    try {
      supabaseProvider.addSubscription(
        title: title,
        amount: amount,
        groupName: 'Общий',
      );
    } catch (e) {
      debugPrint('Серверге кошууда ката: $e');
    }

    String successMsg = '"$title" сумасы \$$amount ийгиликтүү кошулду!';
    if (langProvider.currentLang == 'ru') {
      successMsg = 'Расход "$title" на сумму \$$amount успешно добавлен!';
    } else if (langProvider.currentLang == 'en') {
      successMsg = 'Expense "$title" worth \$$amount added successfully!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        backgroundColor: const Color(0xFF4ADE80), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    Navigator.pop(context);
  }
    @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    String expenseTitleHint = langProvider.translate('expense_title_hint');
    String amountHint = langProvider.translate('amount_hint');
    String cancelBtnText = langProvider.translate('cancel');
    String addBtnText = langProvider.translate('add');

    if (langProvider.currentLang == 'ru') {
      expenseTitleHint = 'Название расхода';
      amountHint = 'Сумма (\$)';
      cancelBtnText = 'Отмена';
      addBtnText = 'Добавить';
    } else if (langProvider.currentLang == 'en') {
      expenseTitleHint = 'Expense Title';
      amountHint = 'Amount (\$)';
      cancelBtnText = 'Cancel';
      addBtnText = 'Add';
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
          langProvider.translate('add_expense_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E252B),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
                          child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80).withValues(alpha: 0.12), 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF4ADE80), 
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          langProvider.translate('add_expense_title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Чыгашанын аталышын киргизүүчү премиум кутуча
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12161A), // Ички терең боз фон
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: expenseTitleHint,
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF4ADE80), size: 22),
                        border: InputBorder.none, // Эски сызыктар толук алынды
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Сумманы киргизүүчү премиум кутуча
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12161A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: amountHint,
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF4ADE80), size: 22),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Баскычтардын заманбап катары (Отмена / Добавить)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          cancelBtnText,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Жаңы премиум стилдеги "Добавить" баскычы
                      InkWell(
                        onTap: _submitExpense,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80), // 🌟 Жалбыз жашыл
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ADE80).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            addBtnText,
                            style: const TextStyle(
                              color: Color(0xFF12161A), // Кочкул боз текст
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}


