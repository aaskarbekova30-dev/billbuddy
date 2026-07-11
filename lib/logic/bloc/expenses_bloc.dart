import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  ExpensesBloc() : super(ExpensesInitial()) {
    
    // 1. Маалыматтарды жүктөө логикасы
    on<LoadExpenses>((event, emit) async {
      emit(ExpensesLoading());
      try {
        final data = await _supabase
            .from('expenses')
            .select('id, title, amount, groups(name)')
            .order('created_at', ascending: false);
        
        emit(ExpensesLoaded(data));
      } catch (e) {
        emit(ExpensesError('Маалыматты жүктөөдө ката кетти: $e'));
      }
    });

    // 2. Жаңы чыгым кошуу логикасы
    on<AddExpenseEvent>((event, emit) async {
      emit(ExpensesLoading());
      try {
        await _supabase.from('expenses').insert({
          'title': event.title,
          'amount': event.amount,
          'group_id': event.groupId,
        });

            // 3. Чыгымды өчүрүү логикасы
    on<DeleteExpenseEvent>((event, emit) async {
      try {
        // Базадан дал ушул ID'ге тең келген чыгымды өчүрөбүз
        await _supabase
            .from('expenses')
            .delete()
            .eq('id', event.id);
        
        // Өчүрүлгөндөн кийин тизмени автоматтык түрдө кайра жаңылайбыз
        add(LoadExpenses());
      } catch (e) {
        emit(ExpensesError('Чыгымды өчүрүүдө ката кетти: $e'));
      }
    });

        
        emit(ExpenseAddedSuccess());
        // Чыгым кошулгандан кийин тизмени автоматтык түрдө кайра жаңылайбыз
        add(LoadExpenses()); 
      } catch (e) {
        emit(ExpensesError('Чыгымды кошууда ката кетти: $e'));
      }
    });
  }
}
