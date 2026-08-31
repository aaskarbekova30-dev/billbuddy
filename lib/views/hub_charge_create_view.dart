import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';

class HubChargeCreateView extends StatefulWidget {
  final String groupName;
  final int groupId; 

  const HubChargeCreateView({
    super.key,
    required this.groupName,
    required this.groupId, required int groupIndex, required Map<dynamic, dynamic> group, 
  });

  @override
  State<HubChargeCreateView> createState() => _HubChargeCreateViewState();
}

class _HubChargeCreateViewState extends State<HubChargeCreateView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // --- ХРАНЕНИЕ ВЫБРАННЫХ ЗНАЧЕНИЙ ---
  String _selectedCurrency = 'USD'; // По умолчанию USD
  String _selectedCategory = 'Другое'; // По умолчанию Другое

  // Списки доступных вариантов
  final List<String> _currencies = ['USD', 'KGS', 'RUB'];
  final List<String> _categories = ['Ресторан', 'Транспорт', 'Развлечение', 'Другое'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    final String titleText = _titleController.text.trim();
    final double amountValue = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (titleText.isNotEmpty && amountValue > 0) {
      // 1. Отправляем событие в БЛок (с новыми параметрами currency и category)
      context.read<LedgerManagerBloc>().add(
        AddExpenseEvent(
          title: titleText, 
          amount: amountValue,
          currency: _selectedCurrency,   // Передаем выбранную валюту
          category: _selectedCategory,   // Передаем выбранную категорию
          groupId: widget.groupId, 
        ),
      );

      // 2. Обновляем расходы
      context.read<LedgerManagerBloc>().add(LoadExpenses());

      Navigator.pop(context); 
    } else {
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      final translations = AppStrings.getTranslation(langProvider.currentLang);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translations['validation_error'] ?? 'Ката кетти!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLang;

    final translations = AppStrings.getTranslation(currentLang);

    String appbarTitle = "${translations['add_expense_to']} ${widget.groupName}";
    String cardTitle = translations['new_hub_expense']!;
    String subtitleText = currentLang == 'ky' 
        ? "Топ: ${widget.groupName}" 
        : currentLang == 'ru' 
            ? "Группа: ${widget.groupName}" 
            : "Hub: ${widget.groupName}";
            
    String titleHint = translations['expense_title_hint']!;
    String amountHint = translations['expense_amount_hint']!;

    String actionBtnText = currentLang == 'ky' ? "Кошуу" : currentLang == 'ru' ? "Добавить" : "Add";
    String cancelBtnText = currentLang == 'ky' ? "Жокко чыгаруу" : currentLang == 'ru' ? "Отмена" : "Cancel";

    // Локализация названий полей для выпадающих списков
    String categoryLabel = currentLang == 'ky' ? "Категорияны тандаңыз" : currentLang == 'ru' ? "Выберите категорию" : "Category";

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
          appbarTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView( // Защита от переполнения экрана клавиатурой
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E252B),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Название расхода
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: titleHint,
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF12161A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Строка с вводом суммы и выбором Валюты
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: amountHint,
                            hintStyle: const TextStyle(color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: const Color(0xFF12161A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Выпадающий список Валют
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCurrency, // ОҢДОЛДУ: Свойство value вместо initialValue
                          dropdownColor: const Color(0xFF1E252B),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: const Color(0xFF12161A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: _currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCurrency = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ТЕКСТ-ПОДСКАЗКА ДЛЯ КАТЕГОРИЙ
                  Text(
                    categoryLabel,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  // ДОПИСАНО: Выпадающий список Категорий
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory, // Текущая выбранная категория
                    dropdownColor: const Color(0xFF1E252B),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: const Color(0xFF12161A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // КНОПКИ ДЕЙСТВИЯ (ОТМЕНА И ДОБАВИТЬ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(cancelBtnText,
                        style: const TextStyle(color: Color(0xFF94A3B8)),),),const SizedBox(width: 12),
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),elevation: 0,),
                        onPressed: _submitExpense,child: Text(actionBtnText,style: const TextStyle(color: Color(0xFF12161A), 
                        fontWeight: FontWeight.bold),),),],),],),),),),),);}}
