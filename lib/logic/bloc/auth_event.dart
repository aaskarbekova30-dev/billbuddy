part of 'auth_bloc.dart';


abstract class AuthEvent {}

// 1. Тиркеме күйгөндө колдонуучу мурун кирген-кирбегенин текшерүү окуясы
class AppStarted extends AuthEvent {}

// 2. Email жана Пароль аркылуу катталуу окуясы
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested({required this.email, required this.password});
}

// 3. Email жана Пароль аркылуу тиркемеге кирүү окуясы
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

// 4. Тиркемеден биротоло чыгуу (Log out) окуясы
class SignOutRequested extends AuthEvent {}
