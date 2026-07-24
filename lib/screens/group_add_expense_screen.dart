import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart';
import '../logic/providers/supabase_provider.dart';

class GroupAddExpenseScreen extends StatefulWidget {
  final String groupName; // Кайсы топтун ичинен ачылганын билүү үчүн

  const GroupAddExpenseScreen({super.key, required this.groupName});

  @override
  State<GroupAddExpenseScreen> createState() => _GroupAddExpenseScreenState();
}

class _GroupAddExpenseScreenState extends State<GroupAddExpenseScreen> {
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
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;

    // Чыгаша ушул конкреттүү топтун аты менен Супабейс булутуна так сакталат!
    supabaseProvider.addExpense(
      title: title,
      amount: amount,
      groupName: widget.groupName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$title" сумасы \$$amount ийгиликтүү кошулду!'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Добавить в ${widget.groupName}', style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Новый расход группы', style: const TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Топ: ${widget.groupName}', style: const TextStyle(color: AppColors.textGray, fontSize: 14)),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Чыгымдын аталышы',
                    labelStyle: TextStyle(color: AppColors.textGray),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Суммасы (\$)',
                    labelStyle: TextStyle(color: AppColors.textGray),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Жокко чыгаруу', style: TextStyle(color: AppColors.textGray, fontSize: 16)),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _submitExpense,
                      child: const Text('Кошуу', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
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
