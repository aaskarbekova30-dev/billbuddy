import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';
import 'new_recurring_view.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final DateTime _now = DateTime.now();
  late int _selectedDay;
  List<DateTime> _daysInMonth = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _now.day;
    _getDaysInMonth();
    
    // Экран ачылганда негизги жүктөөнү чакырабыз
    context.read<LedgerManagerBloc>().add(LoadExpenses());
  }

  void _getDaysInMonth() {
    final lastDay = DateTime(_now.year, _now.month + 1, 0).day;
    _daysInMonth = List.generate(lastDay, (index) => DateTime(_now.year, _now.month, index + 1));
  }

  // 🌟 ОПТИМИЗАЦИЯ: Безопасный асинхронный/динамический перевод дней недели
  String _getWeekdayName(int weekday, LanguageProvider langProvider) {
    switch (weekday) {
      case DateTime.monday:
        return langProvider.translate('mon').isEmpty ? "Пн" : langProvider.translate('mon');
      case DateTime.tuesday:
        return langProvider.translate('tue').isEmpty ? "Вт" : langProvider.translate('tue');
      case DateTime.wednesday:
        return langProvider.translate('wed').isEmpty ? "Ср" : langProvider.translate('wed');
      case DateTime.thursday:
        return langProvider.translate('thu').isEmpty ? "Чт" : langProvider.translate('thu');
      case DateTime.friday:
        return langProvider.translate('fri').isEmpty ? "Пт" : langProvider.translate('fri');
      case DateTime.saturday:
        return langProvider.translate('sat').isEmpty ? "Сб" : langProvider.translate('sat');
      case DateTime.sunday:
        return langProvider.translate('sun').isEmpty ? "Вс" : langProvider.translate('sun');
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем провайдер языка. При его изменении build вызовется автоматически
    final langProvider = Provider.of<LanguageProvider>(context);

    final String calendarTitle = langProvider.translate('calendar_title').isEmpty ? 'Хроника платежей' : langProvider.translate('calendar_title');
    final String calendarSubtitle = langProvider.translate('calendar_subtitle').isEmpty ? 'График предстоящих событий' : langProvider.translate('calendar_subtitle');
    final String monthAugust = langProvider.translate('august').isEmpty ? 'Август' : langProvider.translate('august');
    final String eventsToday = langProvider.translate('events_today_title').isEmpty ? 'События на сегодня' : langProvider.translate('events_today_title');
    final String noSubscriptions = langProvider.translate('no_subscriptions').isEmpty ? 'Подписок пока нет' : langProvider.translate('no_subscriptions');

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), 
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4ADE80), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final currentContext = context;
          await Navigator.push(currentContext, MaterialPageRoute(builder: (context) => NewRecurringView(initialDay: _selectedDay)));
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          currentContext.read<LedgerManagerBloc>().add(LoadExpenses());
        },
        child: const Icon(Icons.add, color: Color(0xFF12161A), size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(calendarTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)), 
                        const SizedBox(height: 4), 
                        Text(calendarSubtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
                      ]
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                    decoration: BoxDecoration(color: const Color(0xFF1E252B), borderRadius: BorderRadius.circular(10)), 
                    child: Text(monthAugust, style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 13))
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Горизонтальный календарь
              SizedBox(
                height: 85,
                child: ListView.builder(
                  key: const PageStorageKey('calendar_h_scroll'), 
                  scrollDirection: Axis.horizontal, 
                  physics: const BouncingScrollPhysics(), 
                  itemCount: _daysInMonth.length,
                  itemBuilder: (context, index) {
                    final DateTime date = _daysInMonth[index];
                    // Переводим название дня "на лету" асинхронно-безопасным методом
                    final String dayName = _getWeekdayName(date.weekday, langProvider);

                    return GestureDetector(
                      key: ValueKey('btn_${date.day}'),
                      onTap: () => setState(() { _selectedDay = date.day; }),
                      child: _buildCalendarDay(
                        dayName, 
                        date.day.toString(), 
                        _selectedDay == date.day, 
                        key: ValueKey(date.toIso8601String())
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(eventsToday, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E252B), borderRadius: BorderRadius.circular(24)),
                  child: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
                    builder: (context, state) {
                      if (state is LedgerManagerLoading) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
                      }

                      List<dynamic> subsList = [];
                      
                      if (state is LedgerManagerLoaded) {
                        subsList = state.subscriptions; 
                      }

                      if (subsList.isEmpty) {
                        return Center(child: Text(noSubscriptions, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8), 
                        physics: const BouncingScrollPhysics(), 
                        itemCount: subsList.length,
                        separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Color(0xFF12161A), height: 1)),
                        itemBuilder: (context, index) {
                          final item = subsList[index];
                          
                          final String id = item['id'].toString();
                          final String title = item['name'] ?? 'Подписка';
                          final double amount = (item['amount'] ?? 0.0).toDouble();
                          
                          if (item['date'] != null) {
                            try {
                            } catch (_) {}
                          }

                          return Dismissible(
                            key: Key(id), 
                            direction: DismissDirection.endToStart,
                            background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28)),
                            onDismissed: (direction) {
                              context.read<LedgerManagerBloc>().add(DeleteSubscriptionEvent(id: int.parse(id)));
                            },
                            child: ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title, 
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
           Builder(
        builder: (context) {
          // 1. Тил провайдерин чакырабыз
          final langProvider = Provider.of<LanguageProvider>(context);

          // Базадан келген датаны текстке айландыруу
          final rawDate = (item['day'] ?? item['date'] ?? '').toString();
          String displayDay = rawDate;

          // Датадан жыл менен айды алып салып, күндү гана калтыруу
          if (rawDate.contains('-')) {
            try {
              final parsedDate = DateTime.parse(rawDate);
              displayDay = parsedDate.day.toString();
            } catch (_) {
              displayDay = rawDate.split('-').last;
            }
          }

          // 2. Локализация файлынан ('every_month_day') ачкычын окуйбуз
          // Эгер котормо табылбаса, дефолт катары кыргызча форматты коёбуз
          String localizedTemplate = langProvider.translate('every_month_day').isEmpty
              ? 'Ар бир айдын {day}-сы'
              : langProvider.translate('every_month_day');

          // 3. Шаблондун ичиндеги {day} деген жазууну чыныгы күн (мис: 15 же 16) менен алмаштырабыз
          String finalDisplayText = localizedTemplate.replaceAll('{day}', displayDay);

          return Text(
            finalDisplayText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          );
        },
      ),

    ],
  ),
  trailing: Text(
    '$amount', 
    style: const TextStyle(
      color: Color(0xFF4ADE80),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
),

                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный виджет для отрисовки элемента дня (добавьте ваш существующий или этот)
  Widget _buildCalendarDay(String dayName, String dayNumber, bool isSelected, {Key? key}) {
    return Container(
      key: key,
      width: 60,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4ADE80) : const Color(0xFF1E252B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Text(dayName, style: TextStyle(color: isSelected ? const Color(0xFF12161A) : const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),const SizedBox(height: 6),Text(dayNumber, style: TextStyle(color: isSelected ? const Color(0xFF12161A) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),],),);}}
