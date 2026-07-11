part of 'expenses_bloc.dart';


abstract class ExpensesState {}

// 1. Алгачкы абал (Жүктөлүү башталганга чейин)
class ExpensesInitial extends ExpensesState {}

// 2. Маалымат базадан жүктөлүп жаткан учур
class ExpensesLoading extends ExpensesState {}

// 3. Маалымат ийгиликтүү келгендеги абал
class ExpensesLoaded extends ExpensesState {
  final List<dynamic> expenses;
  ExpensesLoaded(this.expenses);
}

// 4. Жаңы чыгым ийгиликтүү кошулгандагы абал
class ExpenseAddedSuccess extends ExpensesState {}

// 5. Кандайдыр бир ката кеткендеги абал
class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}
