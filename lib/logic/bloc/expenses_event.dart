part of 'expenses_bloc.dart';


abstract class ExpensesEvent {}

// 1. Базадан чыгымдарды тартып келүү окуясы
class LoadExpenses extends ExpensesEvent {}

// 2. Жаңы чыгым кошуу окуясы (аргументтери менен)
class AddExpenseEvent extends ExpensesEvent {
  final String title;
  final double amount;
  final int groupId;

  AddExpenseEvent({
    required this.title,
    required this.amount,
    required this.groupId,
    });
}
// 3. Чыгымды өчүрүү окуясы (ID номери аркылуу)
class DeleteExpenseEvent extends ExpensesEvent {
  final int id;

  DeleteExpenseEvent({required this.id});
}

