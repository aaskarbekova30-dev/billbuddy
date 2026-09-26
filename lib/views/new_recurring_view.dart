import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/language_provider.dart'; // Тил провайдеринин дареги
import '../core/state/ledger_manager_bloc.dart';

class NewRecurringView extends StatefulWidget {
  final int? initialDay;

  const NewRecurringView({super.key, this.initialDay});

  @override
  State<NewRecurringView> createState() => _NewRecurringViewState();
}

class _NewRecurringViewState extends State<NewRecurringView> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDay != null) {
      _dayController.text = widget.initialDay.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Тандалган тилди жүктөө
    final langProvider = Provider.of<LanguageProvider>(context);

    // Снапбарлар үчүн котормолор (эгер тил файлында жок болсо, демейки кыргызчасы иштейт)
    final String msgSuccess = langProvider.translate('subscription_saved').isEmpty 
        ? 'Абонемент ийгиликтүү сакталды!' 
        : langProvider.translate('subscription_saved');
        
    final String msgFillFields = langProvider.translate('fill_all_fields').isEmpty 
        ? 'Сураныч, бардык талааларды толтуруңуз!' 
        : langProvider.translate('fill_all_fields');
        
    final String msgInvalid = langProvider.translate('invalid_input').isEmpty 
        ? 'Баасын же күндү туура эмес киргиздиңиз!' 
        : langProvider.translate('invalid_input');

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langProvider.translate('new_subscription_title').isEmpty ? 'Жаңы абонемент' : langProvider.translate('new_subscription_title'), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langProvider.translate('add_subscription_header').isEmpty ? "Жазылууну кошуу" : langProvider.translate('add_subscription_header'), 
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(langProvider.translate('hint_title').isEmpty ? "Аталышы (мисалы: YouTube Premium)" : langProvider.translate('hint_title')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(langProvider.translate('hint_amount').isEmpty ? "Баасы (мисалы: 199.00)" : langProvider.translate('hint_amount')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dayController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(langProvider.translate('hint_day').isEmpty ? "Төлөнүүчү күнү (1-31)" : langProvider.translate('hint_day')),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : () async {
                  final String title = _titleController.text.trim();
                  final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  final int? day = int.tryParse(_dayController.text.trim());

                  if (title.isNotEmpty && amount > 0 && day != null && day >= 1 && day <= 31) {
                    setState(() => _isLoading = true);

                    final DateTime now = DateTime.now();
                    final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

                    try {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) {
                        throw Exception('Колдонуучу катталган эмес');
                      }

                      await Supabase.instance.client.from('subscriptions').insert({
                        'user_id': user.id,
                        'name': title,
                        'amount': amount,
                        'date': formattedDate,
                      });

                      if (context.mounted) {
                        // Календарды базадан кайра жаңылап жүктөйбүз
                        context.read<LedgerManagerBloc>().add(LoadSubscriptionsEvent());
                        
                        // Ийгиликтүү сакталгандыгы тууралуу тандалган тилдеги билдирүү
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msgSuccess), backgroundColor: Colors.green),
                        );
                        
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ката кетти: $e'), backgroundColor: Colors.redAccent));
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(title.isEmpty ? msgFillFields : msgInvalid), backgroundColor: Colors.orange),
                    );
                  }
                },
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Color(0xFF12161A))
                    : Text(
                        langProvider.translate('save_button').isEmpty ? "Сактоо" : langProvider.translate('save_button'), 
                        style: const TextStyle(color: Color(0xFF12161A), fontSize: 16, fontWeight: FontWeight.bold)
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      filled: true, fillColor: const Color(0xFF1E252B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}
