import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // Категориянын текстине карап туура иконка таап берүүчү жардамчы функция
  IconData _getIconForType(String type) {
    switch (type) {
      case 'Жильё': return Icons.home_work_rounded;
      case 'Кафе/Праздник': return Icons.local_pizza_rounded;
      case 'Поездки': return Icons.directions_car_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  // Ар бир категорияга кооз өзгөчө түс берүү
  Color _getColorForType(String type) {
    switch (type) {
      case 'Жильё': return const Color(0xFF29B6F6); // Көк
      case 'Кафе/Праздник': return const Color(0xFFFFCA28); // Сары
      case 'Поездки': return const Color(0xFFAB47BC); // Кызгылт көк
      default: return AppColors.textGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Статистика расходов',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('groups_box').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Создайте группы и добавьте расходы,\nчтобы увидеть статистику',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
            );
          }

          double totalAllExpenses = 0.0;
          Map<String, double> categorySums = {
            'Жильё': 0.0,
            'Кафе/Праздник': 0.0,
            'Поездки': 0.0,
            'Другое': 0.0,
          };

          // 🌟 ИШЕНҮҮЛҮҮ ЖОЛУ: Кутуча ачыла элек болсо тиркеме сынбайт
          Box? mainBox;
          try {
            mainBox = Hive.box('billbuddy_box');
          } catch (e) {
            mainBox = null; 
          }
          
          if (mainBox != null) {
            final List<dynamic>? savedRaw = mainBox.get('expenses_list_raw');
            if (savedRaw != null) {
              for (var item in savedRaw) {
                final expense = item as Map;
                final amount = (expense['amount'] ?? 0.0) as double;
                final title = (expense['title'] ?? '') as String;
                
                totalAllExpenses += amount;

                String detectedType = 'Другое';
                for (var g in box.values) {
                  final groupMap = g as Map;
                  final gName = groupMap['name'] as String;
                  if (title.contains(gName)) {
                    detectedType = groupMap['type'] as String;
                    break;
                  }
                }
                categorySums[detectedType] = (categorySums[detectedType] ?? 0.0) + amount;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💳 ЖАЛПЫ АЙЛЫК ЧЫГАША КАРТАСЫ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ОБЩИЕ РАСХОДЫ ЗА МЕСЯЦ',
                        style: TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${totalAllExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                const Text(
                  'Аналитика по категориям',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                                // 📈 КАТЕГОРИЯЛАРДЫН КООЗ ПРОГРЕСС ТИЛМЕЛЕРИ
                Column(
                  children: categorySums.keys.map((category) {
                    final amount = categorySums[category] ?? 0.0;
                    final percentage = totalAllExpenses > 0 ? (amount / totalAllExpenses) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(_getIconForType(category), color: _getColorForType(category), size: 24),
                              const SizedBox(width: 12),
                              Text(
                                category,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                '\$${amount.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage, 
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getColorForType(category),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(percentage * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

