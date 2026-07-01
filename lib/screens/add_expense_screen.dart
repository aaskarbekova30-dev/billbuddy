import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart'; // 🔥 Тил импорту

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _splitWithBakyt = false;
  bool _splitWithAibek = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context); // 🔥 Тилди угуу

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        // 🔥 ТИЛГЕ СЕЗИМТАЛ ТЕКСТ:
        title: Text(
          langProvider.translate('add_expense_title'),
          style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Аталышын киргизүү талаасы
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                // 🔥 ТИЛГЕ СЕЗИМТАЛ ТЕКСТ:
                labelText: langProvider.translate('expense_name'),
                labelStyle: const TextStyle(color: AppColors.textGray),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGray)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Сумманы киргизүү талаасы
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                // 🔥 ТИЛГЕ СЕЗИМТАЛ ТЕКСТ:
                labelText: langProvider.translate('amount'),
                labelStyle: const TextStyle(color: AppColors.textGray),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGray)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 30),

            // Бакыт менен бөлүшүү логикасы
            CheckboxListTile(
              title: Text(
                '${langProvider.translate('split_with')} Бакыт',
                style: const TextStyle(color: AppColors.textWhite),
              ),
              value: _splitWithBakyt,
              activeColor: AppColors.primary,
              checkColor: AppColors.background,
              onChanged: (val) {
                setState(() {
                  _splitWithBakyt = val ?? false;
                });
              },
            ),

            // Айбек менен бөлүшүү логикасы
            CheckboxListTile(
              title: Text(
                '${langProvider.translate('split_with')} Айбек',
                style: const TextStyle(color: AppColors.textWhite),
              ),
              value: _splitWithAibek,
              activeColor: AppColors.primary,
              checkColor: AppColors.background,
              onChanged: (val) {
                setState(() {
                  _splitWithAibek = val ?? false;
                });
              },
            ),
            
            const Spacer(),

            // САКТОО БАСКЫЧЫ
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final title = _titleController.text;
                  final amount = double.tryParse(_amountController.text);

                  if (title.isNotEmpty && amount != null && amount > 0) {
                    expenseProvider.addExpense(title, amount, _splitWithBakyt, _splitWithAibek);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(langProvider.translate('enter_all_fields'))),
                    );
                  }
                },
                // 🔥 ТИЛГЕ СЕЗИМТАЛ ТЕКСТ:
                child: Text(
                  langProvider.translate('save'),
                  style: const TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
