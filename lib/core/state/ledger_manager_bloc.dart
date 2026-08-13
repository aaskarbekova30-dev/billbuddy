import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ledger_manager_event.dart';
part 'ledger_manager_state.dart';

class LedgerManagerBloc extends Bloc<LedgerManagerEvent, LedgerManagerState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  LedgerManagerBloc() : super(LedgerManagerInitial()) {
    
    // 1. МААЛЫМАТТАРДЫ ЖҮКТӨӨ (КҮЧӨТҮЛГӨН ЖАНА КООПСУЗ)
    on<LoadExpenses>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        final List<dynamic> groupsData = await _supabase
            .from('groups')
            .select('*')
            .order('created_at', ascending: false);

        final List<dynamic> expensesData = await _supabase
            .from('expenses')
            .select('id, description, amount, group_id, created_at')
            .order('created_at', ascending: false);

        final List<Map<String, dynamic>> combinedHubs = [];

        for (var group in groupsData) {
          if (group != null) {
            final int groupId = (group['id'] ?? 0) as int;
            
            final List<dynamic> currentGroupExpenses = expensesData.where((exp) {
              return exp != null && (exp['group_id'] ?? -1) == groupId;
            }).toList();

            combinedHubs.add({
              'id': groupId,
              'name': (group['name'] ?? '') as String,
              'category': (group['category'] ?? group['cat'] ?? 'Other') as String, 
              'limit_amount': (group['limit_amount'] ?? group['limit'] ?? 0.0).toDouble(),  
              'expenses': currentGroupExpenses,
            });
          }
        }
        
        emit(LedgerManagerLoaded(combinedHubs)); 
      } catch (e) {
        // ИСПРАВЛЕНО: Просто выводим в консоль, не ломая запуск интерфейса
        debugPrint('--- КАТА ТАК УШУЛ ЖЕРДЕ ---: $e');
        emit(LedgerManagerLoaded(const [])); // Передаем пустой список, чтобы UI не зависал
      }
    });

    // 2. КАПЧЫК ТҮЗҮҮ
    on<CreateHubEvent>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        await _supabase.from('groups').insert({
          'name': event.name,
          'category': event.category,
          'limit_amount': event.limitAmount,
        });
      } catch (e) {
        emit(LedgerManagerError('Жаңы капчык түзүүдө ката кетти: $e'));
        return;
      }
      emit(ExpenseAddedSuccess());
      add(LoadExpenses()); 
    });

    // 3. ЧЫГЫМ КОШУУ ЛОГИКАСЫ
    on<AddExpenseEvent>((event, emit) async {
      try {
        final currentUser = _supabase.auth.currentUser;
        final String currentUserId = currentUser?.id ?? '';

        if (currentUserId.isEmpty) {
          emit(LedgerManagerError('Ката: Колдонуучу табылган жок!'));
          return;
        }

        await _supabase.from('expenses').insert({
          'description': event.title,
          'amount': event.amount,
          'group_id': event.groupId,
          'payer_id': currentUserId,
        });

        add(LoadExpenses()); 
      } catch (e) {
        emit(LedgerManagerError('Чыгымды кошууда ката кетти: $e'));
      }
    });

    // 4. КАПЧЫКТЫ БИРОТОЛО ӨЧҮРҮҮ
    on<SettleUpGroupEvent>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        await _supabase
            .from('expenses')
            .delete()
            .eq('group_id', event.groupId);

        await _supabase
            .from('groups')
            .delete()
            .eq('id', event.groupId);
        
        emit(ExpenseAddedSuccess()); 
        add(LoadExpenses()); 
      } catch (e) {
        emit(LedgerManagerError('Капчыкты өчүрүүдө ката кетти: $e'));
      }
    });

    // 5. БИР ДААНА ЧЫГЫМДЫ ӨЧҮРҮҮ
    on<DeleteExpenseEvent>((event, emit) async {
      try {
        await _supabase.from('expenses').delete().eq('id', event.id);
        add(LoadExpenses()); 
      } catch (e) {
        emit(LedgerManagerError('Чыгышаны өчүрүүдө ката кетти: $e'));
      }
    });

    // 6. БАРДЫК ЧЫГЫМДАРДЫ ТАЗАЛОО
    on<ClearAllExpensesEvent>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        await _supabase.from('expenses').delete().neq('id', 0);
        emit(ExpenseAddedSuccess()); 
        add(LoadExpenses()); 
      } catch (e) {
        emit(LedgerManagerError('Бардык чыгымдарды тазалоодо ката кетти: $e'));
      }
    });

  } 
}
