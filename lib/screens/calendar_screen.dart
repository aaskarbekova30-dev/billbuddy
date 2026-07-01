import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart';
import '../models/expense_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Тандалган күндөгү чыгашаларды чыпкалап алуучу функция
  List<ExpenseModel> _getExpensesForDay(DateTime day, List<ExpenseModel> allExpenses) {
    return allExpenses.where((expense) {
      return expense.date.year == day.year &&
          expense.date.month == day.month &&
          expense.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context); // 🔥 Тилди угуу
    final selectedDayExpenses = _getExpensesForDay(_selectedDay!, expenseProvider.expenses);

    return Scaffold(
      appBar: AppBar(
        // 🔥 ТИЛГЕ СЕЗИМТАЛ ТЕКСТ:
        title: Text(langProvider.translate('calendar_title')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Календардын тилин локалдык өзгөрмөгө байлап коюу (мис: 'ru', 'en')
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            // Календардын ичинде чыгашасы бар күндөргө кичинекей чекит (маркер) коюу
            eventLoader: (day) {
              return _getExpensesForDay(day, expenseProvider.expenses);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red, // Чыгаша бар күндөр кызыл чекит менен белгиленет
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          
          // --- ТАНДАЛГАН КҮНДҮН ЧЫГАШАЛАРЫНЫН ТИЗМЕСИ ---
          Expanded(
            child: selectedDayExpenses.isEmpty
                ?  Center(
                    child: Text(
                      langProvider.translate('no_expenses_day🌿'),
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedDayExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = selectedDayExpenses[index];
                      return ListTile(
                        leading: const Icon(Icons.monetization_on, color: Colors.redAccent),
                        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          '-\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
