import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart';
import '../logic/providers/supabase_provider.dart';

class GroupPaymentScreen extends StatefulWidget {
  final Map group;
  final int groupIndex;

  const GroupPaymentScreen({
    super.key,
    required this.group,
    required this.groupIndex,
  });

  @override
  State<GroupPaymentScreen> createState() => _GroupPaymentScreenState();
}

class _GroupPaymentScreenState extends State<GroupPaymentScreen> {
  IconData _getIconForType(String type) {
    if (type == 'Жильё' || type == 'Үй-жай' || type == 'Housing') {
      return Icons.home_work_rounded;
    }
    if (type == 'Кафе/Праздник' ||
        type == 'Кафе/Майрам' ||
        type == 'Cafe/Party') {
      return Icons.local_pizza_rounded;
    }
    if (type == 'Поездки' || type == 'Сапарлар' || type == 'Travel') {
      return Icons.directions_car_rounded;
    }
    return Icons.more_horiz_rounded;
  }

  // 🚀 ТӨЛӨМ СИСТЕМАСЫ: КАРЫЗДАРДЫ НӨЛДӨӨ (SETTLE UP) ФУНКЦИЯСЫ
  void _settleUpGroup(double totalAmount, String groupName) {
    Provider.of<LanguageProvider>(context, listen: false);

    if (totalAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все долги по этой группе уже закрыты!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text(
          'Рассчитаться',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Text(
          'Вы действительно хотите обнулить все расходы по группе "$groupName" на сумму \$$totalAmount?',
          style: const TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context); // Диалогду жабуу

              // 🌟 1. СЕРВЕРДЕН (SUPABASE) ӨЧҮРҮҮ ЛОГИКАСЫ
              try {
                final supabaseProvider = Provider.of<SupabaseProvider>(
                  context,
                  listen: false,
                );
                supabaseProvider.settleUpGroup(groupName);
              } catch (e) {
                debugPrint('Supabase өчүрүүдө ката: $e');
              }

              // 🌟 2. ТЕЛЕФОНДУН ИЧИНЕН (HIVE) ӨЧҮРҮҮ ЛОГИКАСЫ (try/catch сыртына чыгарылып оңдолду)
              try {
                final mainBox = Hive.box('billbuddy_box');
                final List<dynamic>? savedRaw = mainBox.get(
                  'expenses_list_raw',
                );

                if (savedRaw != null) {
                  List<dynamic> updatedList = List.from(savedRaw);

                  updatedList.removeWhere((item) {
                    final expense = item as Map;
                    final title = (expense['title'] ?? '') as String;
                    return title.contains(groupName);
                  });

                  mainBox.put('expenses_list_raw', updatedList);

                  double currentTotal = mainBox.get(
                    'total_balance',
                    defaultValue: 0.0,
                  );
                  double newTotal = currentTotal - totalAmount;
                  mainBox.put('total_balance', newTotal < 0 ? 0.0 : newTotal);
                }
              } catch (e) {
                debugPrint('Hive өчүрүүдө ката: $e');
              }

              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Все долги по группе "$groupName" успешно закрыты!',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Да, рассчитаться',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final groupName = widget.group['name'] as String;
    final imagePath = widget.group['imagePath'] as String;
    final groupType = widget.group['type'] as String;

    double groupTotalAmount = 0.0;
    try {
      final mainBox = Hive.box('billbuddy_box');
      final List<dynamic>? savedRaw = mainBox.get('expenses_list_raw');
      if (savedRaw != null) {
        for (var item in savedRaw) {
          final expense = item as Map;
          final title = (expense['title'] ?? '') as String;
          final amount = (expense['amount'] ?? 0.0) as double;

          if (title.contains(groupName)) {
            groupTotalAmount += amount;
          }
        }
      }
    } catch (e) {
      groupTotalAmount = 0.0;
    }

    // Тилге жараша Категория сөзүн тууралоо
    String displayType = langProvider.translate('type_other');
    if (groupType == 'Жильё' ||
        groupType == 'Үй-жай' ||
        groupType == 'Housing') {
      displayType = langProvider.translate('type_housing');
    } else if (groupType == 'Кафе/Праздник' ||
        groupType == 'Кафе/Майрам' ||
        groupType == 'Cafe/Party') {
      displayType = langProvider.translate('type_cafe');
    } else if (groupType == 'Поездки' ||
        groupType == 'Сапарлар' ||
        groupType == 'Travel') {
      displayType = langProvider.translate('type_travel');
    }

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
          groupName,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: imagePath.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            _getIconForType(groupType),
                            color: AppColors.primary,
                            size: 36,
                          ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    groupName,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${langProvider.translate('group_direction_label')}: $displayType',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  Text(
                    langProvider.translate('monthly_total_label'),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${groupTotalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: groupTotalAmount > 0
                          ? Colors.redAccent
                          : AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: groupTotalAmount > 0
                      ? AppColors.primary
                      : AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _settleUpGroup(groupTotalAmount, groupName),
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: groupTotalAmount > 0
                      ? AppColors.background
                      : AppColors.textGray,
                ),
                label: Text(
                  'Рассчитаться (Settle Up)',
                  style: TextStyle(
                    color: groupTotalAmount > 0
                        ? AppColors.background
                        : AppColors.textGray,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              langProvider.translate('after_settle_hint'),
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
