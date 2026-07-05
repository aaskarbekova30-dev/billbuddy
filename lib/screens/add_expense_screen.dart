import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Тандалган топтун атын сактоочу өзгөрмө
  String? _selectedGroupName;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 🚀 ЧЫГАШАНЫ САКТОО ФУНКЦИЯСЫ (ПРОВАЙДЕРГЕ 100% ЫЛАЙЫКТАШТЫРЫЛДЫ)
  void _submitData(
    ExpenseProvider expenseProvider,
    LanguageProvider langProvider,
  ) {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty || _selectedGroupName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля и выберите группу!'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректную сумму!'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    // 🌟 100% КАТАСЫЗ ОҢДОЛДУ: Сиздин Провайдердин 4 аргументине так дал келтирилди
    expenseProvider.addExpense(
      '$title ($_selectedGroupName)', // 1: Аталышы (Ичине топтун аты кошо жазылат)
      amount, // 2: Суммасы
      false, // 3: splitWithBakyt (Эски чекбокс иштебейт)
      false, // 4: splitWithAibek (Эски чекбокс иштебейт)
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$title" успешно сохранено!'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context); // Сакталгандан кийин артка кайтуу
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final langProvider = Provider.of<LanguageProvider>(context);
    final groupsBox = Hive.box('groups_box');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Жаңы чыгаша кошуу',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Чыгашанын аталышы',
                  labelStyle: TextStyle(color: AppColors.textGray),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textGray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Суммасы (\$)',
                  labelStyle: TextStyle(color: AppColors.textGray),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textGray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Выберите группу для деления',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // 🌟 ЖАҢЫ: Эски чекбокстордун ордуна реалдуу топторду тандоочу курал
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textGray.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGroupName,
                    hint: const Text(
                      'Топту тандаңыз',
                      style: TextStyle(color: AppColors.textGray),
                    ),
                    dropdownColor: AppColors.cardBg,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                    ),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroupName = newValue;
                      });
                    },
                    items: groupsBox.values.map<DropdownMenuItem<String>>((
                      group,
                    ) {
                      final gMap = group as Map;
                      return DropdownMenuItem<String>(
                        value: gMap['name'] as String,
                        child: Text(gMap['name'] as String),
                      );
                    }).toList(),
                  ),
                ),
              ),

              if (groupsBox.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'У вас пока нет групп! Сначала создайте группу во вкладке "Группы".',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => _submitData(expenseProvider, langProvider),
                  child: const Text(
                    'Сактоо',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
