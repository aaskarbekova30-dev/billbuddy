import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart'; // Провайдер файлыңыздын туура жолу

class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    // ЖАҢЫ АСИНХРОНДУУ ЛОКАЛИЗАЦИЯ ИНТЕГРАЦИЯСЫ:
    final langProvider = Provider.of<LanguageProvider>(context);

    final String calendarTitle = langProvider.translate('calendar_title');
    final String calendarSubtitle = langProvider.translate('calendar_subtitle');
    final String monthAugust = langProvider.translate('august');
    final String eventsToday = langProvider.translate('events_today_title');
    final String spotifyTitle = langProvider.translate('spotify_title');
    final String spotifyRemind = langProvider.translate('spotify_remind');
    final String internetTitle = langProvider.translate('internet_title');
    final String internetRemind = langProvider.translate('internet_remind');

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), // Биздин негизги терең фон
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ЖОГОРКУ ПАНЕЛЬ: Аталышы жана айды көрсөтүү баскычы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calendarTitle, 
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calendarSubtitle, 
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Учурдагы айды көрсөткөн заманбап элемент
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E252B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      monthAugust, 
                      style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. ЖАҢЫ ЭЛЕМЕНТ: Горизонталдык апталык календарь
              SizedBox(
                height: 85,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCalendarDay("Пн", "10", false),
                    _buildCalendarDay("Вт", "11", false),
                    _buildCalendarDay("Ср", "12", true), // Учурда активдүү тандалган күн
                    _buildCalendarDay("Чт", "13", false),
                    _buildCalendarDay("Пт", "14", false),
                    _buildCalendarDay("Сб", "15", false),
                    _buildCalendarDay("Вс", "16", false),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                eventsToday, 
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

              // 3. ПЛАНДАЛГАН ТӨЛӨМДӨРДҮН ТИЗМЕСИ
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E252B),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildScheduleRow(
                        title: spotifyTitle, 
                        time: spotifyRemind, 
                        amount: "-4.99 \$",
                        iconData: Icons.notifications_active_rounded,
                        isUrgent: true, // Өзгөчө маанилүү белгиси
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: Color(0xFF12161A), height: 1),
                      ),
                      _buildScheduleRow(
                        title: internetTitle, 
                        time: internetRemind, 
                        amount: "-15.00 \$",
                        iconData: Icons.language_rounded,
                        isUrgent: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Горизонталдык календардын күн компоненти
  Widget _buildCalendarDay(String dayName, String dayNumber, bool isActive) {
    return Container(
      width: 55,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4ADE80) : const Color(0xFF1E252B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              color: isActive ? const Color(0xFF12161A) : const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayNumber,
            style: TextStyle(
              color: isActive ? const Color(0xFF12161A) : const Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Төлөмдөрдүн сап компоненти
  Widget _buildScheduleRow({
    required String title,
    required String time,
    required String amount,
    required IconData iconData,
    required bool isUrgent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF12161A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconData, 
              color: isUrgent ? const Color(0xFFFB7185) : const Color(0xFF4ADE80), 
              size: 20
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
