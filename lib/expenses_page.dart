import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 🌟 Сиздин долбоордогу Блок файлы жайгашкан так даректи жазыңыз
import '../logic/bloc/expenses_bloc.dart'; 

class MyExpensesPage extends StatelessWidget {
  const MyExpensesPage({super.key});

  // Чыгымдын аталышына карап автоматтык түрдө туура иконканы тандаган функция
  IconData _getIconForExpense(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('азык') || 
        lowerTitle.contains('түлүк') || 
        lowerTitle.contains('тамак') || 
        lowerTitle.contains('ресторан') || 
        lowerTitle.contains('кафе') || 
        lowerTitle.contains('food')) {
      return Icons.local_dining_rounded;
    } 
    else if (lowerTitle.contains('бензин') || 
             lowerTitle.contains('машина') || 
             lowerTitle.contains('такси') || 
             lowerTitle.contains('жол') || 
             lowerTitle.contains('car')) {
      return Icons.directions_car_rounded;
    } 
    else if (lowerTitle.contains('кийим') || 
             lowerTitle.contains('кийүү') || 
             lowerTitle.contains('одежда') || 
             lowerTitle.contains('clothes')) {
      return Icons.checkroom_rounded;
    }
    
    return Icons.account_balance_wallet_rounded; 
  }

  // 🌟 Базадан бардык жеткиликтүү группаларды жүктөп келүүчү кошумча функция
  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    final data = await Supabase.instance.client.from('groups').select('id, name');
    return List<Map<String, dynamic>>.from(data);
  }

  // 🌟 ЖАҢЫЛАНДЫ: Жаңы чыгым кошуу үчүн кооз терезе (DropdownButton менен)
  void _showAddExpenseDialog(BuildContext context, ExpensesBloc bloc) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    
    // Тандалган группанын ID номерин сактоочу өзгөрмө
    int? selectedGroupId; 

    showDialog(
      context: context,
      builder: (dialogContext) {
        // DropdownButton динамикалык түрдө өзгөрүп турушу үчүн StatefulBuilder колдонобуз
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF162541),
              title: const Text('Жаңы чыгаша кошуу', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Чыгымдын аталышы',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Суммасы',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Топту тандаңыз:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  
                  // 🌟 ДАЯР ГРУППАЛАРДЫН ТИЗМЕСИН КӨРСӨТҮҮЧҮ FUTUREBUILDER
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchGroups(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator(color: Color(0xFF00E676));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Группалар табылган жок', style: TextStyle(color: Colors.redAccent));
                      }

                      final groups = snapshot.data!;
                      
                      // Эгерде али эч бир группа тандала элек болсо, автоматтык түрдө биринчисин тандап коёбуз
                      if (selectedGroupId == null && groups.isNotEmpty) {
                        selectedGroupId = groups[0]['id'];
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1426),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedGroupId,
                            dropdownColor: const Color(0xFF162541),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E676)),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: groups.map((group) {
                              return DropdownMenuItem<int>(
                                value: group['id'],
                                child: Text(group['name'].toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Колдонуучу башка группаны тандаганда терезени кайра жаңылайбыз
                              setDialogState(() {
                                selectedGroupId = value;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Жокко чыгаруу', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text) ?? 0.0;

                    if (title.isNotEmpty && amount > 0 && selectedGroupId != null) {
                      // 🌟 Блокко тандалган группанын ID'си менен окуя жиберебиз
                      bloc.add(AddExpenseEvent(title: title, amount: amount, groupId: selectedGroupId!));
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Кошуу', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpensesBloc()..add(LoadExpenses()),
      child: Builder(
        builder: (context) {
          final bloc = BlocProvider.of<ExpensesBloc>(context);

          return Scaffold(
            backgroundColor: const Color(0xFF0B1426), 
            appBar: AppBar(
              title: const Text(
                'Чыгымдар тарыхы', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF0B1426),
              elevation: 0,
            ),
            body: BlocBuilder<ExpensesBloc, ExpensesState>(
              builder: (context, state) {
                if (state is ExpensesLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
                }

                if (state is ExpensesError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
                }

                if (state is ExpensesLoaded) {
                  final expenses = state.expenses;

                  if (expenses.isEmpty) {
                    return const Center(
                      child: Text('Чыгымдар азырынча жок.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: expenses.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      final id = item['id']; 
                      final title = item['title'] ?? 'Аталышы жок';
                      final amount = item['amount'] ?? 0.0;
                      final groupName = item['groups'] != null ? item['groups']['name'] : 'Группасыз';

                      return Dismissible(
                        key: Key(id.toString()), 
                        direction: DismissDirection.endToStart, 
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,borderRadius: 
                            BorderRadius.circular(16),),child: const Icon(
                              Icons.delete, color: Colors.white, size: 28),),
                              onDismissed: (direction) {bloc.add(
                                DeleteExpenseEvent(id: id));ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('"$title" өчүрүлдү'),
                                  backgroundColor: Colors.redAccent,),);},child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),decoration: 
                                    BoxDecoration(color: const Color(0xFF162541),
                                    borderRadius: BorderRadius.circular(16),),
                                    child: Row(children: [Container(padding: const 
                                    EdgeInsets.all(12),decoration: BoxDecoration(
                                      color: const Color(0xFF0B1426),borderRadius: 
                                      BorderRadius.circular(12),),child: Icon(_getIconForExpense(title),
                                      color: const Color(0xFF00E676),size: 24,),),const SizedBox(
                                        width: 16),Expanded(child: Column(crossAxisAlignment: 
                                        CrossAxisAlignment.start,children: [Text(title,
                                        style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: 
                                        FontWeight.bold,),),const SizedBox(height: 4),
                                        Text('Топ: $groupName',style: const TextStyle(color: Colors.grey,
                                        fontSize: 14,),),],),),
                                        Text('\$$amount',style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: 
                                        FontWeight.bold,),),],),),);},);}
                                        return const SizedBox();},),floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF00E676),
                                        onPressed: () => _showAddExpenseDialog(context, bloc),
                                        child: const Icon(Icons.add, color: Colors.white, 
                                        size: 28),),);}),);}}


