import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart'; // Эскертүү: Эгер сиздин файлыңыз 'colors.dart' болсо, colors.dart деп калтырыңыз
import 'add_expense_screen.dart';
import '../logic/providers/expense_provider.dart';
import 'add_subscription_screen.dart';



class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Базадагы жаңы маалыматтарды жандуу угуп туруучу курал
        final expenseProvider = Provider.of<ExpenseProvider>(context);

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
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.textWhite,
                    child: Icon(Icons.person, color: AppColors.background),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Салам, Асан!',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                 
                ], // Row ичиндеги элементтердин жабылышы
              ), // Row виджетинин жабылышы


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
                    const Text(
                      'ЖАЛПЫ БАЛАНС',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+\$${expenseProvider.totalBalance.toStringAsFixed(2)}', // Жандуу сан
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

              // --- АТ АЛЫШ ЖАНА ЖАЗЫЛУУ БАСКЫЧЫ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Менин чыгашаларым 📝',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
                      );
                    },
                    icon: const Icon(Icons.calendar_month, color: AppColors.primary, size: 16),
                    label: const Text(
                      '+ Жазылуу',
                      style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- ЧЫГАШАЛАРДЫН ЖАНДУУ ТИЗМЕСИ ---
              Expanded(
                child: expenseProvider.expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'Азырынча эч кандай чыгаша жок.\nПлюс баскычын басып кошуңуз!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textGray, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenseProvider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenseProvider.expenses[index];

                          return Dismissible(
                            key: Key(expense.date.millisecondsSinceEpoch.toString()), // Коопсуз уникалдуу ачкыч
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.alert,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              expenseProvider.deleteExpense(index);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${expense.title}" өчүрүлдү'),
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${expense.date.day}.${expense.date.month}.${expense.date.year}',
                                          style: const TextStyle(
                                            color: AppColors.textGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      '+\$${expense.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // --- FLOATING ACTION BUTTON (Чоң Плюс баскычы) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: AppColors.background,
          size: 30,),),floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,);}}
         


