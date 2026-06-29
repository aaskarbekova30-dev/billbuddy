import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/expense_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _priceController = TextEditingController();
  final _dayController = TextEditingController();
  
  String _selectedApp = 'Netflix 🎬'; // Демейки тандалган тиркеме
  final List<String> _popularApps = ['Netflix 🎬', 'YouTube Premium 📺', 'Spotify 🎵', 'Яндекс Плюс ➕', 'Duolingo 🦉'];

  @override
  void dispose() {
    _priceController.dispose();
    _dayController.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Жазылууну көзөмөлдөө',
                    style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),

              // Тиркемени тандоо (Dropdown)
              const Text('Тиркемени тандаңыз', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: _selectedApp,
                  dropdownColor: AppColors.cardBg,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
                  items: _popularApps.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedApp = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Айлык баасын киргизүү
              const Text('Айлык акысы (\$ менен)', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  hintText: 'мис: 9.99',
                  hintStyle: const TextStyle(color: AppColors.textGray),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Төлөм күнүн киргизүү (МӨӨНӨТҮ)
              const Text('Айдын кайсы күнү төлөнөт? (мөөнөтү)', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  hintText: 'мис: 15 (ар айдын 15-чи күнү)',
                  hintStyle: const TextStyle(color: AppColors.textGray),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const Spacer(),

              // Сактоо баскычы
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final double? price = double.tryParse(_priceController.text);
                    final int? day = int.tryParse(_dayController.text);

                    if (price != null && day != null && day >= 1 && day <= 31) {
                      // Провайдерге жөнөтүп файлга жаздыруу!
                      Provider.of<ExpenseProvider>(context, listen: false)
                          .addSubscription(_selectedApp, price, day);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сураныч, маалыматтарды туура киргизиңиз!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Жазылууну сактоо', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 16)),
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
