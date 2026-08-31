part of 'auth_bloc.dart';


abstract class AuthState {}

// 1. Баштапкы абал (Текшерүү жүрүп жаткан учур)
class AuthInitial extends AuthState {}

// 2. Жүктөлүү абалы (Каттоо же кирүү баскычы басылгандагы процесс)
class AuthLoading extends AuthState {}

// 3. Ийгиликтүү кирген абал (Колдонуучу катталган же кирген)
class Authenticated extends AuthState {
  final String userId;
  Authenticated({required this.userId});
}

// 4. Кирбей калган абал (Колдонуучу каттала элек же тиркемеден чыккан)
class Unauthenticated extends AuthState {}

// 5. Ката кеткендеги абал (Мисалы: пароль туура эмес же мындай email бар)
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
