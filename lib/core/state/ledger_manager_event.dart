part of 'ledger_manager_bloc.dart';

abstract class LedgerManagerEvent {}

// БЛОК ТААНЫШЫ ҮЧҮН: Окуянын атын 'LoadExpenses' деп калтырдык
class LoadExpenses extends LedgerManagerEvent {}

// Бардык таблицалардагы чыгашаларды биротоло тазалоо окуясы
class ClearAllExpensesEvent extends LedgerManagerEvent {}


class CreateHubEvent extends LedgerManagerEvent {
  final String name;
  final double limitAmount;
  final String category;

  CreateHubEvent({
    required this.name,
    required this.limitAmount,
    required this.category, required double limit,
  });
}


class AddExpenseEvent extends LedgerManagerEvent {
  final String title;
  final double amount;
  final int groupId;

  AddExpenseEvent({required this.title, required this.amount, required this.groupId, required String currency, required String category});
}

class DeleteExpenseEvent extends LedgerManagerEvent {
  final int id;
  DeleteExpenseEvent({required this.id}); // ТУУРАЛАНДЫ: ашыкча 'e' тамгасы өчүрүлдү
}


// Топтун ичиндеги бардык чыгымдарды нөлдөө окуясы
class SettleUpGroupEvent extends LedgerManagerEvent {
  final int groupId;
  SettleUpGroupEvent({required this.groupId});
}

// 1. Календарь экраны үчүн абонементтерди жүктөө окуясы
class LoadSubscriptionsEvent extends LedgerManagerEvent {}

// 2. Абонементти календарь экранынан сүрүп өчүрүү окуясы
class DeleteSubscriptionEvent extends LedgerManagerEvent {
  final int id;
  DeleteSubscriptionEvent({required this.id});
}
