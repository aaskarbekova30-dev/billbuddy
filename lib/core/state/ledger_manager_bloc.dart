import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ledger_manager_event.dart';
part 'ledger_manager_state.dart';

class LedgerManagerBloc extends Bloc<LedgerManagerEvent, LedgerManagerState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  LedgerManagerBloc() : super(LedgerManagerInitial()) {
    
    // 1. ЧЫГЫМДАРДЫ, КАПЧЫКТАРДЫ ЖАНА АБОНЕМЕНТТЕРДИ БИР УБАКТА ЖҮКТӨӨ
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

        // Таза subscriptions таблицасынан накты жазылууларды кошо жүктөйбүз
        final List<dynamic> realSubscriptions = await _supabase
            .from('subscriptions')
            .select('*')
            .order('date', ascending: true);

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
              'category': (group['category'] ?? 'Other') as String, 
              'limit_amount': (group['limit_amount'] ?? 0.0).toDouble(),  
              'expenses': currentGroupExpenses,
            });
          }
        }
        
        // 🌟 ОҢДОЛДУ: Капчыктарды да, абонементтерди да бир убакта бир стейтке кошуп чыгарабыз!
        emit(LedgerManagerLoaded(combinedHubs, realSubscriptions)); 
      } catch (e) {
        debugPrint('Маалыматтарды жүктөөдө ката: $e');
        emit(LedgerManagerLoaded(const [], const [])); 
      }
    });

    // 2. ЖАҢЫ КАПЧЫК ТҮЗҮҮ ЛОГИКАСЫ
    on<CreateHubEvent>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser == null) {
          emit(LedgerManagerError('Ката: Колдонуучу катталган эмес!'));
          return;
        }

        await _supabase.from('groups').insert({
          'name': event.name,
          'category': event.category,
          'limit_amount': event.limitAmount,
        });
        
        add(LoadExpenses()); // Сакталгандан кийин баарын кайра жаңылоо
      } catch (e) {
        emit(LedgerManagerError('Жаңы капчык түзүүдө ката кетти: $e'));
      }
    });

       // 3. ЧЫГЫМ КОШУУ (БАШКЫ БЕТКЕ ДАРОО ЧЫГА ТУРГАН КЫЛЫП КҮЧӨТҮЛДҮ)
    on<AddExpenseEvent>((event, emit) async {
      try {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser == null) return;

        // "expenses" таблицасына жаңы чыгашаны коопсуз жазабыз
        await _supabase.from('expenses').insert({
          'description': event.title,
          'amount': event.amount,
          'group_id': event.groupId,
          'payer_id': currentUser.id,
        });

        add(LoadExpenses()); 
        
      } catch (e) {
        emit(LedgerManagerError('Чыгым кошууда ката: $e'));
      }
    });

    // 4. КАПЧЫКТЫ ИЧИНДЕГИ ЧЫГЫМДАРЫ МЕНЕН БИРОТОЛО ӨЧҮРҮҮ
    on<SettleUpGroupEvent>((event, emit) async {
      emit(LedgerManagerLoading());
      try {
        await _supabase.from('expenses').delete().eq('group_id', event.groupId);
        await _supabase.from('groups').delete().eq('id', event.groupId);
        
        add(LoadExpenses()); 
      } catch (e) {
        emit(LedgerManagerError('Капчыкты өчүрүүдө ката кетти: $e'));
      }
    });

    // ==========================================================================
    // АБОНЕМЕНТТЕРДИ САКТОО ЖАНА БАШКАРУУ ТУТУМУ (ЖАҢЫ ОҢДОЛГОН)
    // ==========================================================================

    // 5. АБОНЕМЕНТТЕРДИ ЖҮКТӨӨ СУРАМЫ КЕЛГЕНДЕ БАШКЫ ИВЕНТКЕ ЖӨНӨТӨБҮЗ
    on<LoadSubscriptionsEvent>((event, emit) async {
      // 🌟 ОҢДОЛДУ: Микро-перезагрузка циклин жаратпаш үчүн башкы жүктөөнү гана чакырабыз
      add(LoadExpenses());
    });

    // 6. АБОНЕМЕНТТИ БИРОТОЛО ӨЧҮРҮҮ
    on<DeleteSubscriptionEvent>((event, emit) async {
      try {
        await _supabase
            .from('subscriptions')
            .delete()
            .eq('id', event.id);
        
        add(LoadExpenses()); // Өчүрүлгөндөн кийин толук жаңылоо
      } catch (e) {
        emit(LedgerManagerError('Абонементти өчүрүүдө ката кетти: $e'));
      }
    });
  } 
}
