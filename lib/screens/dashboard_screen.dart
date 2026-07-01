import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🔥 Hive кошулду
import 'package:provider/provider.dart';
import '../constants/app_colors.dart'; 
import 'add_expense_screen.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart'; 
import 'add_subscription_screen.dart';
import 'calendar_screen.dart'; 
import 'account_screen.dart'; // Профиль экранынын импорту

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String _boxName = 'billbuddy_box';
  final String _userNameKey = 'user_name_key';
  String _userName = 'Асан';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Башкы бет ачылганда телефондун эс тутумунан колдонуучунун атын окуу
  void _loadUserName() async {
    var box = await Hive.openBox(_boxName);
    setState(() {
      _userName = box.get(_userNameKey, defaultValue: 'Асан');
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

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
                  // Аватар басылганда Профиль барагына өтөт
                  GestureDetector(
                    onTap: () async {
                      // Профилден кайтып келгенде ат жаңыланганын текшерүү үчүн 'await' колдонобуз
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountScreen()),
                      );
                      _loadUserName(); // Кайтып келгенде жаңы атты кайра окуп экранды жаңылайт
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.textWhite,
                      child: Icon(Icons.person, color: AppColors.background),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 🔥 ТҮЗӨТҮЛДҮ: Эми бул жерде тандалган тилге жараша Салам/Привет/Hello деп чыгат жана артынан сакталган жаңы ат кошулат!
                  Text(
                    '${langProvider.translate('hello').split(',')[0]}, $_userName!',
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
                    icon: const Icon(Icons.language, color: AppColors.primary, size: 18),
                    underline: const SizedBox(), 
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
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
                    icon: const Icon(Icons.calendar_month, color: AppColors.textWhite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarScreen()),
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

              // --- АТ АЛЫШ ЖАНА ЖАЗЫЛУУ БАСКЫЧЫ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langProvider.translate('my_expenses'),
                    style: const TextStyle(
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
                    label: Text(
                      langProvider.translate('add_subscription'),
                      style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- ЧЫГАШАЛАРДЫН ЖАНДУУ ТИЗМЕСИ ---
              Expanded(
                child: expenseProvider.expenses.isEmpty
                    ? Center(
                        child: Text(
                          langProvider.translate('no_expenses'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textGray, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenseProvider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenseProvider.expenses[index];

                          return Dismissible(
                            key: Key(expense.date.millisecondsSinceEpoch.toString()), 
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
                                  content: Text('"${expense.title}" ${langProvider.translate('deleted')}'),
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
                                          style: const TextStyle(color: AppColors.textWhite,
                                          fontSize: 16,fontWeight: FontWeight.w500,),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('${expense.date.day}.${expense.date.month}.${expense.date.year}',
                                          style: const TextStyle(
                                            color: AppColors.textGray,
                                            fontSize: 12,),),],),
                                            const Spacer(),Text('+\$${expense.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(color: AppColors.primary,
                                            fontSize: 16,fontWeight: FontWeight.bold,),
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
                                            ),floatingActionButton: 
                                            FloatingActionButton(onPressed: () async { //Чыгаша кошуп келгенден кийин да башкы бетти жаңылоо коопсуздугу үчүн 
                                            await Navigator.push(context,MaterialPageRoute(
                                              builder: (context) => const AddExpenseScreen()),
                                              );_loadUserName();},backgroundColor: AppColors.primary,
                                              shape: const CircleBorder(),child: 
                                              const Icon(Icons.add,color: AppColors.background,size: 30,),
                                              ),floatingActionButtonLocation: 
                                              FloatingActionButtonLocation.centerFloat,);}}