import 'package:billbuddy/logic/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';


class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Бул сап базадагы жаңы кошулган чыгашаларды жандуу байкап турат
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
              
              // --- ҮСТҮНКҮ БӨЛҮК ---
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Жалпы чыгашалар 📊',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- КАТЫШУУЧУЛАРДЫН АВАТАРЛАРЫ ---
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Row(
                  children: [
                    _buildUserAvatar('А'),
                    const SizedBox(width: 4),
                    _buildUserAvatar('Б'),
                    const SizedBox(width: 4),
                    _buildUserAvatar('В'),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: AppColors.primary, size: 16),
                      label: const Text(
                        'Чакыруу',
                        style: TextStyle(color: AppColors.primary, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // --- Бул жерге достордун учурдагы карыздарын жандуу көрсөтүүчү бөлүмдү кошобуз ---
const Text(
  'Учурдагы карыздар',
  style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
),
const SizedBox(height: 10),

// Бакыттын карызы
Container(
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.only(bottom: 8),
  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
  child: Row(
    children: [
      const Text('Бакыт 👦', style: TextStyle(color: AppColors.textWhite)),
      const Spacer(),
      Text(
        expenseProvider.bakytBalance >= 0 
          ? 'сизге бересе: \$${expenseProvider.bakytBalance.toStringAsFixed(2)}'
          : 'сиз карызсыз: \$${expenseProvider.bakytBalance.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: expenseProvider.bakytBalance >= 0 ? AppColors.primary : AppColors.alert,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

// Айбектин карызы
Container(
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.only(bottom: 20),
  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
  child: Row(
    children: [
      const Text('Айбек 👨', style: TextStyle(color: AppColors.textWhite)),
      const Spacer(),
      Text(
        expenseProvider.aibekBalance >= 0 
          ? 'сизге бересе: \$${expenseProvider.aibekBalance.toStringAsFixed(2)}'
          : 'сиз карызсыз: \$${expenseProvider.aibekBalance.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: expenseProvider.aibekBalance >= 0 ? AppColors.primary : AppColors.alert,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),


              // --- ТӨЛӨМДӨРДҮН ТАРЫХЫ ---
              const Text(
                'Акыркы төлөмдөр',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Тизме эми базадан жандуу түрдө түзүлөт!

              Expanded(
                child: expenseProvider.expenses.isEmpty
                ? const Center(
                  child: Text(
                    'Азырынча чыгашалар жок.\nЖаны чыгаша кошуңуз!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGray, fontSize: 14),
                  ),
                )
                : ListView.builder(
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildExpenseItem(
                        expense.title,
                        '+\$${expense.amount.toStringAsFixed(2)}',
                        AppColors.primary,
                      ),
                    );
                  },
                ),
         ),

              // --- ТӨМӨНКҮ БАШКЫ БАСКЫЧТАР ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.textWhite),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Баланс', style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Эсептешүү',
                        style: TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String letter) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.cardBg,
      child: Text(
        letter,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExpenseItem(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
