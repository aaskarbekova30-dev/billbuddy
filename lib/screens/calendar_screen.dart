import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../models/subscription_model.dart';
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

  // Тандалган күнү кандай төлөмдөр (жазылуулар же чыгашалар) бар экенин аныктоочу жардамчы функция
  List<dynamic> _getEventsForDay(DateTime day, List<SubscriptionModel> subs, List<ExpenseModel> expenses) {
    List<dynamic> events = [];

    // 1. Абонементтердин күнүн текшерүү (Ай сайын кайталанат)
    for (var sub in subs) {
      if (sub.paymentDay == day.day) {
        events.add(sub);
      }
    }

    // 2. Күнүмдүк чыгашалардын күнүн текшерүү
    for (var exp in expenses) {
      if (exp.date.year == day.year && exp.date.month == day.month && exp.date.day == day.day) {
        events.add(exp);
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final subs = expenseProvider.subscriptions;
    final expenses = expenseProvider.expenses;

    // Тандалган күндөгү ивенттердин тизмеси
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay, subs, expenses);

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
          'Календарь платежей',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 📅 СТИЛДҮҮ КАРА-КӨК КАЛЕНДАРЬ ВИДЖЕТИ
          Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TableCalendar(
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
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
                            // Календардын сырткы көрүнүшүн кооздоо (Сиздин кара-көк стилиңизде)
                            // 🌟 КАТАСЫЗ ЖАНА ТУУРА ЖОЛУ:
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: AppColors.textWhite),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary, // Тандалган күн сиздин жашыл түстө болот
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Color(0xFFFFCA28), // Чыгашалар үчүн сары чекит
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                formatButtonTextStyle: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textWhite),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textWhite),
              ),
              // Күндөрдүн астына кооз чекиттерди (маркерлерди) коюу логикасы
              eventLoader: (day) {
                return _getEventsForDay(day, subs, expenses);
              },
            ),
          ),
          
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  'События дня: ${_selectedDay?.day}.${_selectedDay?.month}.${_selectedDay?.year}',
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 📜 ТАНДАЛГАН КҮНДҮН ТӨЛӨМДӨР ТИЗМЕСИ
                    // 📜 ТАНДАЛГАН КҮНДҮН ТӨЛӨМДӨР ТИЗМЕСИ
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(
                    // 🌟 ОҢДОЛДУ: Сүйлөм толугу менен экрандын так ортосуна кооз болуп жайгашат
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined, 
                          color: AppColors.textGray, 
                          size: 40,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'В этот день нет запланированных\nплатежей или расходов',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray, 
                            fontSize: 14,
                            height: 1.4, // Саптардын ортосундагы кооз боштук
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(

                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final item = selectedEvents[index];
                      
                      // Эгер бул Абонемент (Subscription) болсо:
                      if (item is SubscriptionModel) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1), // Жашыл сызык
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.primary, size: 28),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('Ежемесячный абонемент', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }
                      
                      // Эгер бул кадимки Чыгаша (Expense) болсо:
                      if (item is ExpenseModel) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded, color: Colors.orangeAccent, size: 24),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  const Text('Расход', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

