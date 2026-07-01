import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';
import '../logic/providers/language_provider.dart'; // 🔥 Тил провайдери кошулду

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _dayController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context); // 🔥 Тилди угуу

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        // 🔥 ОҢДОЛГОН: "Жазылууну көзөмөлдөө" тексти тилге байланды
        title: Text(
          langProvider.translate('sub_title'),
          style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 ОҢДОЛГОН: "Тиркемени тандоо" тексти тилге байланды
            Text(
              langProvider.translate('select_app'),
              style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: langProvider.translate('app_name_hint'),
                hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGray)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),

            // 🔥 ОҢДОЛГОН: "Айлык акысы" тексти тилге байланды
            Text(
              langProvider.translate('monthly_price'),
              style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: '${langProvider.translate('example')} 9.99', // 🔥 "мисалы: 9.99"
                hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGray)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),

            // 🔥 ОҢДОЛГОН: "Айдын кайсы күнү төлөнөт?" тексти тилге байланды
            Text(
              langProvider.translate('payment_day'),
              style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dayController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: '${langProvider.translate('example')} 25', // 🔥 "мисалы: 25"
                hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGray)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            
            const Spacer(),

            // АБОНЕМЕНТТИ КОШУУ БАСКЫЧЫ
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final name = _nameController.text.trim();
                  final price = double.tryParse(_priceController.text.trim());
                  final day = int.tryParse(_dayController.text.trim());

                  if (name.isNotEmpty && price != null && price > 0 && day != null && day >= 1 && day <= 31) {
                    expenseProvider.addSubscription(name, price, day);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(langProvider.translate('enter_all_fields'))),
                    );
                  }
                },
                // 🔥 ОҢДОЛГОН: Баскычтын тексти да тилге байланды
                child: Text(
                  langProvider.translate('add_button'),
                  style: const TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
