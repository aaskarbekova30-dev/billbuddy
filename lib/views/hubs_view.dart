import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../core/services/language_provider.dart'; 
import '../core/state/ledger_manager_bloc.dart';
import 'hub_details_view.dart';

class HubsView extends StatefulWidget {
  const HubsView({super.key});

  @override
  State<HubsView> createState() => _HubsViewState();
}

class _HubsViewState extends State<HubsView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Другое';

  @override
  void initState() {
    super.initState();
    context.read<LedgerManagerBloc>().add(LoadExpenses());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Категориялардын базалык атын котормо ачкычына айландыруучу функция

  void _showCreateHubBottomSheet(BuildContext parentContext) {
    // Тил провайдерин негизги контексттен ишенимдүү алабыз
    final langProvider = Provider.of<LanguageProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E252B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langProvider.translate('create_wallet_title').isEmpty ? "Создать новый кошелек" : langProvider.translate('create_wallet_title'), 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController, 
                style: const TextStyle(color: Colors.white), 
                decoration: _inputDecoration(langProvider.translate('hint_wallet_name').isEmpty ? "Название" : langProvider.translate('hint_wallet_name')),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController, 
                keyboardType: TextInputType.number, 
                style: const TextStyle(color: Colors.white), 
                decoration: _inputDecoration(langProvider.translate('hint_wallet_limit').isEmpty ? "Лимит / Сумма" : langProvider.translate('hint_wallet_limit')),
              ),
              const SizedBox(height: 20),
              Text(
                langProvider.translate('select_category_lbl').isEmpty ? "Выберите категорию:" : langProvider.translate('select_category_lbl'), 
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)
              ),
              const SizedBox(height: 10),
              
              // Категориялардын аттары эми тилге карап автоматтык түрдө которулат!
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Wrap(
                    spacing: 10,
                    children: ['Ресторан', 'Транспорт', 'Развлечение', 'Другое'].map((cat) {
                      final bool isSelected = _selectedCategory == cat;
                      
                      // Ар бир категориянын тилдеги котормосун аныктоо
                      String displayCatName = cat;
                      if (cat == 'Ресторан') displayCatName = langProvider.translate('cat_restaurant').isEmpty ? 'Ресторан' : langProvider.translate('cat_restaurant');
                      if (cat == 'Транспорт') displayCatName = langProvider.translate('cat_transport').isEmpty ? 'Транспорт' : langProvider.translate('cat_transport');
                      if (cat == 'Развлечение') displayCatName = langProvider.translate('cat_entertainment').isEmpty ? 'Развлечение' : langProvider.translate('cat_entertainment');
                      if (cat == 'Другое') displayCatName = langProvider.translate('cat_other').isEmpty ? 'Другое' : langProvider.translate('cat_other');

                      return ChoiceChip(
                        label: Text(displayCatName, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF4ADE80),
                        backgroundColor: const Color(0xFF12161A),
                        onSelected: (bool selected) {
                          setModalState(() { _selectedCategory = cat; });
                          setState(() {}); // Негизги экранды дагы жаңыртуу
                        },
                      );
                    }).toList(),
                  );
                }
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    final String name = _nameController.text.trim();
                    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                    if (name.isNotEmpty && amount > 0) {
                      parentContext.read<LedgerManagerBloc>().add(CreateHubEvent(name: name, category: _selectedCategory, limitAmount: amount, limit: amount));
                      _nameController.clear();
                      _amountController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    langProvider.translate('btn_add').isEmpty ? "Добавить" : langProvider.translate('btn_add'), 
                    style: const TextStyle(color: Color(0xFF12161A), fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF12161A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Text(
                langProvider.translate('nav_groups').isEmpty ? "Кошельки" : langProvider.translate('nav_groups'), 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InkWell(
                onTap: () => _showCreateHubBottomSheet(context), // Түз негизги контекстти өткөрүп беребиз
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1E252B), width: 1.5), borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(
                      langProvider.translate('create_wallet_title').isEmpty ? "+ Создать новый кошелек" : "+ ${langProvider.translate('create_wallet_title')}", 
                      style: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)
                    )
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<LedgerManagerBloc, LedgerManagerState>(
                builder: (context, state) {
                  if (state is LedgerManagerLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
                  }
                  List<dynamic> hubsList = [];
                  if (state is LedgerManagerLoaded) {
                    hubsList = state.hubs;
                  }
                  if (hubsList.isEmpty) {
                    return Center(
                      child: Text(
                        langProvider.translate('no_wallets').isEmpty 
                            ? "Капчыктар азырынча жок" 
                            : langProvider.translate('no_wallets'), 
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.2),
                    itemCount: hubsList.length,
                    itemBuilder: (context, index) {
                      final hub = hubsList[index];
                      final String rawCat = hub['category'] ?? 'Другое';
                      
                      // Карттардын ичиндеги категория аттарын да тилге жараша которуу
                      String displayHubCat = rawCat;
                      if (rawCat == 'Ресторан') displayHubCat = langProvider.translate('cat_restaurant').isEmpty ? 'Ресторан' : langProvider.translate('cat_restaurant');
                      if (rawCat == 'Транспорт') displayHubCat = langProvider.translate('cat_transport').isEmpty ? 'Транспорт' : langProvider.translate('cat_transport');if (rawCat == 'Развлечение') displayHubCat = langProvider.translate('cat_entertainment').isEmpty ? 'Развлечение' : langProvider.translate('cat_entertainment');if (rawCat == 'Другое') displayHubCat = langProvider.translate('cat_other').isEmpty ? 'Другое' : langProvider.translate('cat_other');return GestureDetector(onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => HubDetailsView(hub: hub)),);},child: Container(padding: const EdgeInsets.all(16),decoration: BoxDecoration(color: const Color(0xFF1E252B), borderRadius: BorderRadius.circular(20)),child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(displayHubCat, style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12, fontWeight: FontWeight.bold)),const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF64748B), size: 18),],),Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(hub['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),const SizedBox(height: 4),Text("${hub['limit_amount'] ?? 0.0} RUB", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),],),],),),);},);},),),],),),);}InputDecoration _inputDecoration(String hint) {return InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF64748B)), fillColor: const Color(0xFF12161A), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none));}}
