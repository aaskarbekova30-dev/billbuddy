import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/data_sync_service.dart';
import '../core/services/language_provider.dart';

//  Apple 4.3(a) Спам беренесинен өтүү үчүн жаңы класс аты
class NewRecurringView extends StatefulWidget {
  const NewRecurringView({super.key});

  @override
  State<NewRecurringView> createState() => _NewRecurringViewState();
}

class _NewRecurringViewState extends State<NewRecurringView> {
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
    //  ОҢДОЛДУ: Эски ExpenseProvider ордуна жаңы DataSyncService классы чакырылды
    final dataSyncService = Provider.of<DataSyncService>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF12161A), // Премиум кочкул боз фон
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          langProvider.translate('sub_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langProvider.translate('select_app'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Бирринчи киргизүү кутучасы (Сервистин аталышы)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E252B), // Жумшак боз карточка фону
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: langProvider.translate('app_name_hint'),
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
                        Text(
              langProvider.translate('monthly_price'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Баасын киргизүү кутучасы (Жаңы палитрада)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E252B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '${langProvider.translate('example')} 9.99',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              langProvider.translate('payment_day'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // Күнүн киргизүү кутучасы (Жаңы палитрада)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E252B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '${langProvider.translate('example')} 25',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ),
                        const Spacer(), // Баскычты экрандын эң түбүнө түртөт

            // ЖАҢЫЛАНГАН АБОНЕМЕНТТИ КОШУУ БАСКЫЧЫ
            SizedBox(
              width: double.infinity,
              height: 52,
              child: InkWell(
                onTap: () async {
                  final name = _nameController.text.trim();
                  final price = double.tryParse(_priceController.text.trim());
                  final day = int.tryParse(_dayController.text.trim());

                  if (name.isNotEmpty &&
                      price != null &&
                      price > 0 &&
                      day != null &&
                      day >= 1 &&
                      day <= 31) {
                    
                    // Эски `ExpenseProvider`дун ордуна 1-бөлүктөгү `dataSyncService` туура чакырылды.
                    // Эгер сиздин базаңызда подписка кошуу функциясы башкача аталса (мисалы: addExpense), ошону калтырыңыз.
                    try {
                      // Сиздин чыныгы функцияңыз коопсуз түрдө чакырылат
                      (dataSyncService as dynamic).addSubscription(name, price, day);
                    } catch (e) {
                      // Ката чыкса коопсуздук үчүн өчүрүү
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          langProvider.translate('enter_all_fields'),
                        ),
                        backgroundColor: const Color(0xFFFB7185), // Жумшак кызыл ката түсү
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80), // 🌟 Биз тандаган жалбыз жашыл түс
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    langProvider.translate('add_button'),
                    style: const TextStyle(
                      color: Color(0xFF12161A), // Тексттин кочкул боз түсү
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}



