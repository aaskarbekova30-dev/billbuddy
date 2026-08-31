import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency_service.dart';

// --- ЕВЕНТТЕР (EVENTS) ---
abstract class CurrencyEvent {}
class InitCurrencyEvent extends CurrencyEvent {}
class ChangeCurrencyEvent extends CurrencyEvent {
  final String newCurrency;
  ChangeCurrencyEvent(this.newCurrency);
}

// --- СТАТЕ (STATES) ---
class CurrencyState {
  final String selectedCurrency;
  final CurrencyService service;

  CurrencyState({required this.selectedCurrency, required this.service});

  // Экрандагы доллар суммасын керектүү валютага көбөйтүүчү башкы функция
  double convertFromUsd(double amountInUsd) {
    final double currentRate = service.rates[selectedCurrency] ?? 1.0;
    return amountInUsd * currentRate;
  }
}

// --- БЛОК (BLOC) ---
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService = CurrencyService();

  CurrencyBloc() : super(CurrencyState(selectedCurrency: 'USD', service: CurrencyService())) {
    
    // Тиркеме ачылгандагы инициялизация
    on<InitCurrencyEvent>((event, emit) async {
      await _currencyService.fetchRates();
      final prefs = await SharedPreferences.getInstance();
      final savedCurrency = prefs.getString('user_currency') ?? 'USD';
      
      emit(CurrencyState(selectedCurrency: savedCurrency, service: _currencyService));
    });

    // Колдонуучу валютаны алмаштырганда
    on<ChangeCurrencyEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_currency', event.newCurrency);
      
      emit(CurrencyState(selectedCurrency: event.newCurrency, service: _currencyService));
    });
  }
}
