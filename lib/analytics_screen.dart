import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Провайдер үчүн кошулду
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart'; // Тил провайдери

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  IconData _getIconForType(String type) {
    // Тилге жараша иконкаларды таануу коопсуздугу оңдолду
    if (type == 'Жильё' || type == 'Үй-жай' || type == 'Housing') return Icons.home_work_rounded;
    if (type == 'Кафе/Праздник' || type == 'Кафе/Майрам' || type == 'Cafe/Party') return Icons.local_pizza_rounded;
    if (type == 'Поездки' || type == 'Сапарлар' || type == 'Travel') return Icons.directions_car_rounded;
    return Icons.more_horiz_rounded;
  }

  Color _getColorForType(String type) {
    if (type == 'Жильё' || type == 'Үй-жай' || type == 'Housing') return const Color(0xFF29B6F6); 
    if (type == 'Кафе/Праздник' || type == 'Кафе/Майрам' || type == 'Cafe/Party') return const Color(0xFFFFCA28); 
    if (type == 'Поездки' || type == 'Сапарлар' || type == 'Travel') return const Color(0xFFAB47BC); 
    return AppColors.textGray;
  }

  @override
  Widget build(BuildContext context) {
    // Тил тутумун чакырабыз
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          langProvider.translate('analytics_title'), // 🌟 ОҢДОЛДУ: Локализацияга байланды
          style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('groups_box').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                langProvider.translate('analytics_empty_hint'), // 🌟 ОҢДОЛДУ: Локализацияга байланды
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
            );
          }

          double totalAllExpenses = 0.0;
          
          // Категориялардын аттары тилге жараша динамикалык түзүлөт
          String tHousing = langProvider.translate('type_housing');
          String tCafe = langProvider.translate('type_cafe');
          String tTravel = langProvider.translate('type_travel');
          String tOther = langProvider.translate('type_other');

          Map<String, double> categorySums = {
            tHousing: 0.0,
            tCafe: 0.0,
            tTravel: 0.0,
            tOther: 0.0,
          };

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

                                String detectedType = tOther;
                for (var g in box.values) {
                  final groupMap = g as Map;
                  final gName = groupMap['name'] as String;
                  if (title.contains(gName)) {
                    final gType = groupMap['type'] as String;
                    // Сакталган типти азыркы тилге шайкеш келтиребиз
                    if (gType == 'Жильё' || gType == 'Үй-жай' || gType == 'Housing') {
                      detectedType = tHousing;
                    } else if (gType == 'Кафе/Праздник' || gType == 'Кафе/Майрам' || gType == 'Cafe/Party') {
                      detectedType = tCafe;
                    } else if (gType == 'Поездки' || gType == 'Сапарлар' || gType == 'Travel') {
                      detectedType = tTravel;
                    }
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
                      Text(
                        langProvider.translate('monthly_total_label'), // 🌟 ОҢДОЛДУ: Локализацияга байланды
                        style: const TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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

                Text(
                  langProvider.translate('category_analytics_title'), // 🌟 ОҢДОЛДУ: Локализацияга байланды
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

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


