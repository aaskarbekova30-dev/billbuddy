part of 'ledger_manager_bloc.dart';

abstract class LedgerManagerState {}

class LedgerManagerInitial extends LedgerManagerState {}

class LedgerManagerLoading extends LedgerManagerState {}

// 🌟 ОҢДОЛДУ: Эски класс өчүрүлүп, бир гана ушул туура класс калды!
// Бул стейт эми капчыктарды да, абонементтерди да бир убакта коопсуз ташыйт.
class LedgerManagerLoaded extends LedgerManagerState {
  final List<dynamic> hubs; 
  final List<dynamic> subscriptions; // Абонементтерди кошо ташуу үчүн

  LedgerManagerLoaded(this.hubs, this.subscriptions);
}

class ExpenseAddedSuccess extends LedgerManagerState {}

class LedgerManagerError extends LedgerManagerState {
  final String message;
  LedgerManagerError(this.message);
}

// Муну дагы коопсуздук үчүн калтырып коёбуз, эгер башка файлдар издеп калса ката бербейт
class SubscriptionsLoadedState extends LedgerManagerState {
  final List<dynamic> subscriptions;
  SubscriptionsLoadedState(this.subscriptions);
}
