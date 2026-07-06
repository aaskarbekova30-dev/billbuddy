import 'package:billbuddy/screens/groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart';
import 'calendar_screen.dart';
import 'account_screen.dart';
import 'dart:io';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String _boxName = 'billbuddy_box';
  final String _userNameKey = 'user_name_key';
  String _userName = 'Диана';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    var box = await Hive.openBox(_boxName);
    setState(() {
      _userName = box.get(_userNameKey, defaultValue: 'Диана');
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    String helloText = langProvider.translate('hello');
    if (helloText.contains(',')) {
      helloText = helloText.split(',')[0];
    }
    helloText = helloText.replaceAll('[', '').replaceAll(']', '').trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- HEADER (Үстүнкү бөлүк) ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountScreen(),
                        ),
                      );
                      _loadUserName();
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.textWhite,
                      child: Icon(Icons.person, color: AppColors.background),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$helloText, $_userName!',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),

                  DropdownButton<String>(
                    value: langProvider.currentLang,
                    dropdownColor: AppColors.cardBg,
                    icon: const Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    underline: const SizedBox(),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                    ),
                    onChanged: (String? newLang) {
                      if (newLang != null) {
                        langProvider.changeLanguage(newLang);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'ky', child: Text(' KG ')),
                      DropdownMenuItem(value: 'ru', child: Text(' RU ')),
                      DropdownMenuItem(value: 'en', child: Text(' EN ')),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: AppColors.textWhite,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- TOTAL BALANCE CARD (Жалпы баланс) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langProvider.translate('total_balance'),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+\$${expenseProvider.totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- АКТИВДҮҮ ТОПТОРДУН БАСКЫЧЫ ЖАНА ТЕКСТИ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Чыгашалар',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGroupFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: const Text(
                      'Добавить группу',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // --- ЧЫГАШАЛАРДЫН ЖАНДУУ ТИЗМЕСИ (HIVE БАЗАСЫ МЕНЕН) ---
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box('groups_box').listenable(),
                  builder: (context, Box box, _) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          'У вас пока нет созданных групп.\nНажмите на кнопку "Добавить группу" выше!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final actualIndex = box.length - 1 - index;
                        final group = box.getAt(actualIndex) as Map;
                        final imagePath = group['imagePath'] as String;
                        final groupName = group['name'] as String;

                        IconData groupIcon = Icons.more_horiz_rounded;
                        if (group['type'] == 'Жильё') {
                          groupIcon = Icons.home_work_rounded;
                        }
                        if (group['type'] == 'Кафе/Праздник') {
                          groupIcon = Icons.local_pizza_rounded;
                        }
                        if (group['type'] == 'Поездки') {
                          groupIcon = Icons.directions_car_rounded;
                        }

                        double groupTotalAmount = 0.0;
                        try {
                          final mainBox = Hive.box('billbuddy_box');
                          final List<dynamic>? savedRaw = mainBox.get(
                            'expenses_list_raw',
                          );
                          if (savedRaw != null) {
                            for (var item in savedRaw) {
                              final expense = item as Map;
                              final title = (expense['title'] ?? '') as String;
                              final amount =
                                  (expense['amount'] ?? 0.0) as double;

                              if (title.contains(groupName)) {
                                groupTotalAmount += amount;
                              }
                            }
                          }
                        } catch (e) {
                          groupTotalAmount = 0.0;
                        }

                        return Dismissible(
                          key: Key(
                            group['createdAt'] ?? actualIndex.toString(),
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.alert,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            box.deleteAt(actualIndex);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Группа "$groupName" удалена'),
                                backgroundColor: AppColors.alert,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: imagePath.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.file(
                                              File(imagePath),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            groupIcon,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        groupName,
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Тип: ${group['type']}',
                                        style: const TextStyle(
                                          color: AppColors.textGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${groupTotalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
