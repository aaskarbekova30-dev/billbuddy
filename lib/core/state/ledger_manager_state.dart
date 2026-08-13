part of 'ledger_manager_bloc.dart';

abstract class LedgerManagerState {}

class LedgerManagerInitial extends LedgerManagerState {}

class LedgerManagerLoading extends LedgerManagerState {}

// ИНТЕРФЕЙС ТААНЫШЫ ҮЧҮН: Бул жерге 'hubs' өзгөрмөсүн так жаздык
class LedgerManagerLoaded extends LedgerManagerState {
  final List<dynamic> hubs; 
  LedgerManagerLoaded(this.hubs);
}

class ExpenseAddedSuccess extends LedgerManagerState {}

class LedgerManagerError extends LedgerManagerState {
  final String message;
  LedgerManagerError(this.message);
}
