import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Текст киргизүүчү контроллерлор
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Достордун тизмеси (Бакыт жана Айбек үчүн тандалуу абалы)
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Асан (Сиз)', 'selected': true, 'enabled': false}, // Сиз дайыма тандалгансыз, аны өчүрүүгө болбойт
    {'name': 'Бакыт', 'selected': true, 'enabled': true},
    {'name': 'Айбек', 'selected': true, 'enabled': true},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // --- ҮСТҮНКҮ БӨЛҮК (Жабуу баскычы жана Аталышы) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                    onPressed: () {
                      Navigator.pop(context); // Баракчаны жабуу
                    },
                  ),
                  const Text(
                    'Чыгаша кошуу',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Тең салмактуулук үчүн боштук
                ],
              ),
              const SizedBox(height: 30),

              // --- ЧЫГАШАНЫН АТЫН КИРГИЗҮҮ ---
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Эмне үчүн төлөндү? (мис: Пицца)',
                  hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 16),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.cardBg, width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- СУММАНЫ КИРГИЗҮҮ (Чоң арип менен) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '\$',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppColors.cardBg),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- БӨЛҮШТҮРҮҮ БӨЛҮГҮ (Кимдердин ортосунда бөлүнөт?) ---
              const Text(
                'Кимдердин ортосунда бөлүнөт?',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Достордун тизмеси (Checkbox менен)
              Expanded(
                child: ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          _friends[index]['name'],
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
                        ),
                        value: _friends[index]['selected'],
                        activeColor: AppColors.primary,
                        checkColor: AppColors.background,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // Эгер Асан (Сиз) болсо басылбайт, Бакыт же Айбек болсо басылат
                        onChanged: _friends[index]['enabled'] == false 
                          ? null 
                          : (bool? value) {
                              setState(() {
                                _friends[index]['selected'] = value!;
                              });
                            },
                      ),
                    );
                  },
                ),
              ),

              // --- ЧЫГАШАНЫ САКТОО БАСКЫЧЫ (ЖАНЫ ПРОВАЙДЕРГЕ ТОЛУК ТУТАШТЫ) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final String title = _titleController.text.trim();
                    final double? amount = double.tryParse(_amountController.text);

                    if (title.isNotEmpty && amount != null && amount > 0) {
                      // ЖАНЫЛАНДЫ: Тизмеден Бакыт (индекс 1) жана Айбек (индекс 2) тандалганбы же жокпу аныктайбыз
                      bool splitWithBakyt = _friends[1]['selected'] == true;
                      bool splitWithAibek = _friends[2]['selected'] == true;

                      // Биздин жаңы акылдуу Провайдердин функциясына бардык маалыматтарды өткөрүп беребиз!
                     Provider.of<ExpenseProvider>(context, listen: false)
    .addExpense(title, amount, splitWithBakyt, splitWithAibek);


                      // Сакталгандан кийин экранды жабуу
                      Navigator.pop(context);
                    } else {
                      // Эгер толтурулбай калса эскертүү чыгаруу
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сураныч, атын жана суммасын туура киргизиңиз!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Чыгашаны сактоо',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
