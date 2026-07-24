import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/supabase_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
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
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final supabaseProvider = Provider.of<SupabaseProvider>(context, listen: false);

    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('enter_all_fields')),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;

    // Ашыкча "as bool" мажбурлоолору тазаланды
    try {
      expenseProvider.addExpense(
        title,
        amount,
        'Общий' as bool,
        DateTime.now() as bool,
      );
    } catch (e) {
      debugPrint('Провайдерге кошууда ката: $e');
    }

    // Серверге (Supabase) жүктөө
    try {
      supabaseProvider.addExpense(
        title: title,
        amount: amount,
        groupName: 'Общий',
      );
    } catch (e) {
      debugPrint('Серверге кошууда ката: $e');
    }

    // Ийгиликтүү кошулду билдирүүсү тилге жараша чыгат
    String successMsg = '"$title" сумасы \$$amount ийгиликтүү кошулду!';
    if (langProvider.currentLang == 'ru') {
      successMsg = 'Расход "$title" на сумму \$$amount успешно добавлен!';
    } else if (langProvider.currentLang == 'en') {
      successMsg = 'Expense "$title" worth \$$amount added successfully!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    // 🛠️ ЖАҢЫЛАНДЫ: Талаалардын жана баскычтардын тексттери тилге байланды
    String expenseTitleHint = langProvider.translate('expense_title_hint');
    String amountHint = langProvider.translate('amount_hint');
    String cancelBtnText = langProvider.translate('cancel');
    String addBtnText = langProvider.translate('add');

    // Эгер локализация файлдарыңызда (JSON) атайын ачкычтар жок болсо, коопсуз кол менен тууралоо:
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langProvider.translate('add_expense_title'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.translate('add_expense_title'),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: expenseTitleHint,
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: amountHint,
                    labelStyle: const TextStyle(color: AppColors.textGray),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        cancelBtnText,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: _submitExpense,
                        child: Text(
                          addBtnText,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 16,
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

