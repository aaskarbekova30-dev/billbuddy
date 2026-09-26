import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    
    // 1. Колдонуучунун сессиясын текшерүү логикасы
    on<AppStarted>((event, emit) {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        emit(Authenticated(userId: session.user.id));
      } else {
        emit(Unauthenticated());
      }
    });

    // 2. ЖАҢЫЛАНГАН Катталуу логикасы (Sign Up)
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Катталуу суроосун жөнөтүү
        final response = await _supabase.auth.signUp(
          email: event.email,
          password: event.password,
        );
        
        if (response.user != null && response.session != null) {
          emit(Authenticated(userId: response.user!.id));
        } else if (response.user != null) {
          emit(EmailConfirmationRequired());
        } else {
          emit(AuthError(message: 'Каттоо убагында ката кетти'));
        }
      } catch (e) {
        emit(AuthError(message: 'Ката: ${e.toString()}'));
      }
    });

    // 3. Кирүү логикасы (Sign In)
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          emit(Authenticated(userId: response.user!.id));
        } else {
          emit(AuthError(message: 'Кирүү убагында ката кетти'));
        }
      } catch (e) {
        emit(AuthError(message: 'Ката: ${e.toString()}'));
      }
    });

    // 4. Тиркемеден чыгуу логикасы (Sign Out)
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _supabase.auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(message: 'Чыгуу убагында ката кетти: ${e.toString()}'));
      }
    });
  }
}
