import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_strings.dart';
import '../core/services/language_provider.dart';
import '../core/state/ledger_manager_bloc.dart';
import 'hub_settlement_view.dart';

class HubsView extends StatefulWidget {
  const HubsView({super.key});

  @override
  State<HubsView> createState() => _HubsViewState();
}

class _HubsViewState extends State<HubsView> {
  late TextEditingController _nameController;
  late TextEditingController _limitController;
  String _userCurrency = 'RUB'; // Дефолтная валюта

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _limitController = TextEditingController();
    _loadUserCurrency(); // Загружаем валюту при открытии экрана кошельков
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  // Безопасная загрузка валюты из Supabase профиля пользователя
  Future<void> _loadUserCurrency() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('currency')
          .eq('id', user.id)
          .single();
      if (data['currency'] != null) {
        setState(() {
          _userCurrency = data['currency'].toString().toUpperCase().trim();
        });
      }
    } catch (e) {
      debugPrint('Кошелектордо валютаны жүктөөдө ката: $e');
    }
  }

  // Конвертер кода валюты в красивый визуальный знак
  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'KGS': return 'с';
      case 'EUR': return '€';
      default: return '₽';
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final String activeLang = langProvider.currentLang;
    final translations = AppStrings.getTranslation(activeLang);

    final String hubsTitle = langProvider.translate('hubs_title');
    final String createHubText = langProvider.translate('create_hub');
    final String currentSymbol = _getCurrencySymbol(_userCurrency); // Наш динамический знак валюты

    String actionBtnText = activeLang == 'ky' ? "Кошуу" : activeLang == 'ru' ? "Добавить" : "Add";
    
    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          hubsTitle.isNotEmpty ? hubsTitle : (activeLang == 'ru' ? 'Кошельки' : 'Wallets'),
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // КНОПКА СОЗДАНИЯ НОВОГО КОШЕЛЬКА
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Color(0xFF2ECC71)),
                label: Text(
                  createHubText.isNotEmpty ? createHubText : (activeLang == 'ru' ? 'Создать новый кошелек' : 'Create new wallet'),
                  style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  _nameController.clear();
                  _limitController.clear();
                  String internalSelectedCategory = 'Entertainment';

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF1E252B),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (sheetContext) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                          top: 24, left: 24, right: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translations['create_hub'] ?? 'Жаңы капчык түзүү',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: activeLang == 'ky' ? 'Капчыктын аталышы' : activeLang == 'ru' ? 'Название кошелька' : 'Wallet name',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true, fillColor: const Color(0xFF12161A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _limitController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '${translations['budget_limit'] ?? 'Бюджеттин лимити'} ($currentSymbol)',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                filled: true, fillColor: const Color(0xFF12161A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              activeLang == 'ky' ? 'Категорияны тандаңыз:' : (activeLang == 'ru' ? 'Выберите категорию:' : 'Select category:'), 
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            StatefulBuilder(
                              builder: (sheetContext, setModalState) {
                                final List<Map<String, dynamic>> myCategories = [
                                  {'id': 'Restaurant', 'icon': Icons.restaurant_rounded, 'label': activeLang == 'ru' ? 'Ресторан' : (activeLang == 'ky' ? 'Ресторан' : 'Restaurant')},
                                  {'id': 'Transport', 'icon': Icons.directions_car_rounded, 'label': activeLang == 'ru' ? 'Транспорт' : (activeLang == 'ky' ? 'Транспорт' : 'Transport')},
                                  {'id': 'Entertainment', 'icon': Icons.celebration_rounded, 'label': activeLang == 'ru' ? 'Развлечение' : (activeLang == 'ky' ? 'Оюн-зоок' : 'Entertainment')},
                                  {'id': 'Other', 'icon': Icons.more_horiz_rounded, 'label': activeLang == 'ru' ? 'Другое' : (activeLang == 'ky' ? 'Башка' : 'Other')},
                                ];

                                return Wrap(
                                  spacing: 10, runSpacing: 10,
                                  children: myCategories.map((cat) {
                                    final bool isSelected = internalSelectedCategory == cat['id'];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => setModalState(() => internalSelectedCategory = cat['id']!),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF2ECC71) : const Color(0xFF12161A),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF1E3A2F), width: 1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(cat['icon'], color: isSelected ? const Color(0xFF12161A) : const Color(0xFF4ADE80), size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              cat['label'],
                                              style: TextStyle(color: isSelected ? const Color(0xFF12161A) : Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                            ),
                                            ],),),);}).toList(),);},),
                                            const SizedBox(height: 32),
                                            // КНОПКА ДЛЯ СОХРАНЕНИЯ В БАЗУ ЧЕРЕЗ БЛОК
                                            SizedBox(width: double.infinity,
                                            height: 52,child: ElevatedButton(style: 
                                            ElevatedButton.styleFrom(backgroundColor: const 
                                            Color(0xFF2ECC71),shape: RoundedRectangleBorder(borderRadius: 
                                            BorderRadius.circular(16)),elevation: 0,),
                                                                            onPressed: () {
                                  final double limit = double.tryParse(_limitController.text) ?? 0.0;
                                  
                                  if (_nameController.text.trim().isNotEmpty) {
                                    context.read<LedgerManagerBloc>().add(
                                      CreateHubEvent(
                                        name: _nameController.text.trim(),
                                        category: internalSelectedCategory,
                                        limit: limit,        // Для новой структуры Блока
                                        limitAmount: limit,  // Для старой структуры Блока (на всякий случай)
                                      ),
                                    );
                                    Navigator.pop(sheetContext);
                                  }
                                },
                                child: Text(
                                  actionBtnText,
                                  style: const TextStyle(
                                    color: Color(0xFF12161A), 
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                           ),),],),);},);},),),const 
                                                SizedBox(height: 20),
                                                // ДИНАМИЧЕСКИЙ СПИСОК КОШЕЛЬКОВ ИЗ БАЗЫ ДАННЫХ SUPABASE
                                                Expanded(child: BlocBuilder<LedgerManagerBloc, 
                                                LedgerManagerState>(builder: (context, state) {
                                                  if (state is LedgerManagerLoading) {return const Center(child: 
                                                  CircularProgressIndicator(color: Color(0xFF2ECC71)));} else if 
                                                  (state is LedgerManagerLoaded) {final hubs = state.hubs;if 
                                                  (hubs.isEmpty) {return Center(child: Text(activeLang == 'ru' ? 
                                                  'Кошельки пока отсутствуют' : 'Капчыктар азырынча жок',style: const
                                                   TextStyle(color: Color(0xFF64748B), fontSize: 16),),);}return 
                                                   ListView.separated(physics: const BouncingScrollPhysics(),itemCount: hubs.
                                                   length,separatorBuilder: (context, index) => const SizedBox(height: 12),
                                                   itemBuilder: (context, index) {final hub = hubs[index];final double 
                                                   limitAmount = (hub['limit_amount'] ?? 0.0) as double;
                                                   // Считаем общую сумму расходов внутри данного кошелька
                                                   double totalSpent = 0.0;if (hub['expenses'] != null) {
                                                    for (var exp in hub['expenses']) {totalSpent += 
                                                    (exp['amount'] ?? 0.0) as double;}}
                                                                                    // Рассчитываем процент заполнения для красивой полосы прогресса
                                double progressFactor = 0.0;
                                if (limitAmount > 0) {
                                  progressFactor = (totalSpent / limitAmount).clamp(0.0, 1.0);
                                }

                                return InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  // ИСПРАВЛЕННЫЙ БЛОК НА СТРОКЕ 238
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HubSettlementView(
        group: hub,        // Передаем весь объект кошелька
        groupIndex: index, // Передаем текущий индекс из ListView
      ),
    ),
  );
},

                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E252B),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hub['name'] ?? '',
                                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${totalSpent.toStringAsFixed(0)} / ${limitAmount.toStringAsFixed(0)} $currentSymbol',
                                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        // Линейный индикатор заполнения лимита бюджета
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: progressFactor,
                                            minHeight: 8,
                                            backgroundColor: const Color(0xFF12161A),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              progressFactor >= 1.0 ? const Color(0xFFEF4444) : const Color(0xFF2ECC71),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (state is LedgerManagerError) {
                            return Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFEF4444))));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

                                                    