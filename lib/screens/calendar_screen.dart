import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; // Календарь пакети кошулду
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart';
import '../models/subscription_model.dart';
import '../models/expense_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Календардын форматы үчүн өзгөрмө калыбына келтирилди
  CalendarFormat _calendarFormat = CalendarFormat.month; 
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<dynamic> _getEventsForDay(
    DateTime day,
    List<SubscriptionModel> subs,
    List<ExpenseModel> expenses,
  ) {
    List<dynamic> events = [];
    for (var sub in subs) {
      if (sub.paymentDay == day.day) {
        events.add(sub);
      }
    }
    for (var exp in expenses) {
      if (exp.date.year == day.year &&
          exp.date.month == day.month &&
          exp.date.day == day.day) {
        events.add(exp);
      }
    }
    return events;
  }
    @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // Тилди аныктоочу тутум
    final currentLang = langProvider.currentLang;

    final subs = expenseProvider.subscriptions;
    final expenses = expenseProvider.expenses;
    final selectedEvents = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      subs,
      expenses,
    );

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
          langProvider.translate('calendar_payments_title'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Скриншоттогудай жасалгаланган Календарь
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TableCalendar(
              // Тил асинхрондуу өзгөрүшү үчүн маанилүү ачкыч (key)
              key: ValueKey(currentLang),
              locale: currentLang == 'ky'
                  ? 'ky_KG'
                  : (currentLang == 'ru' ? 'ru_RU' : 'en_US'),
              
              // Жогорку панелдеги баскычты локализациялоо ("неделя" / "жума" маселесин чечет)
              availableCalendarFormats: {
                CalendarFormat.month: langProvider.translate('calendar_format_month'),
                CalendarFormat.twoWeeks: langProvider.translate('calendar_format_2_weeks'),
                CalendarFormat.week: langProvider.translate('calendar_format_week'),
              },
              
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

              // Апта күндөрүнүн стили (скриншоттогудай боз жана кызыл)
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Color(0xFF5F6E86), fontSize: 13),
                weekendStyle: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              
              // Күндөрдүн жасалгасы (Жашыл тегерек жана астындагы сары чекиттер)
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: AppColors.textWhite),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
                outsideDaysVisible: false,
                
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: AppColors.textWhite),

                // Скриншоттогудай ачык жашыл тандалган күн (мисалы: 24)
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF00E676), 
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: Color(0xFF0F1B2B), 
                  fontWeight: FontWeight.bold,
                ),

                markersAlignment: Alignment.bottomCenter,
                markerSize: 6,
                markerDecoration: BoxDecoration(
                  color: Color(0xFFFFCA28), // Астындагы сары чекиттер
                  shape: BoxShape.circle,
                ),
              ),

              // Жогорку панелдин дизайны (Жашыл формат баскычы)
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Color(0xFF0F1B2B), 
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                formatButtonDecoration: const BoxDecoration(
                  color: Color(0xFF00E676), // Жашыл баскыч
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                formatButtonPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textWhite),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textWhite),
              ),
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
                  '${langProvider.translate('day_events_label')}: ${_selectedDay?.day}.${_selectedDay?.month}.${_selectedDay?.year}',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Төмөнкү тизме (Жазылуулар жана чыгашалар)
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: AppColors.primary,
                          size: 44,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          langProvider.translate('no_events_empty_hint'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                            height: 1.4,
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

                      if (item is SubscriptionModel) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      langProvider.translate('monthly_sub_label'),
                                      style: const TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

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
                              const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.orangeAccent,
                                size: 24,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      langProvider.translate('expense_label'),
                                      style: const TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '\$${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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


