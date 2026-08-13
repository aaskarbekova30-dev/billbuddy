import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart'; //  Туураланган дарек боюнча импорт
import '../core/services/language_provider.dart';


class DeleteAccountDialog extends StatelessWidget {
  final LanguageProvider langProvider;

  const DeleteAccountDialog({super.key, required this.langProvider});

  @override
  Widget build(BuildContext context) {
    // Дефолт катары кыргыз тилиндеги тексттер сакталды
    String titleText = 'Аккаунтту өчүрүү';
    String contentText = 'Аккаунтуңузду биротоло өчүргүңүз келгенине ишенесизби? Сиздин бардык маалыматтарыңыз базадан толугу менен өчүрүлөт.';
    String cancelText = 'Жок';
    String deleteText = 'Биротоло өчүрүү';

    // Эгер орус же англис тили тандалса, тексттер автоматтык түрдө алмашат
    if (langProvider.currentLang == 'ru') {
      titleText = 'Удаление аккаунта';
      contentText = 'Вы уверены, что хотите безвозвратно удалить свой аккаунт? Все ваши данные будут полностью стерты из базы.';
      cancelText = 'Отмена';
      deleteText = 'Удалить';
    } else if (langProvider.currentLang == 'en') {
      titleText = 'Account Deletion';
      contentText = 'Are you sure you want to permanently delete your account? All your data will be completely erased.';
      cancelText = 'Cancel';
      deleteText = 'Delete Permanently';
    }
        return AlertDialog(
      backgroundColor: const Color(0xFF1E252B), //  Жумшак боз карточка фону
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), //  Жумшак тегерек бурчтар
      title: Text(
        titleText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.5, fontSize: 18),
      ),
      content: Text(
        contentText,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      actions: [
        // ЖОККО ЧЫГАРУУ БАСКЫЧЫ
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          ),
        ),
        
        // БИРОТОЛО ӨЧҮРҮҮ БАСКЫЧЫ (Жумшак кызыл түстө)
        InkWell(
          onTap: () async {
            Navigator.pop(context); 
            
            final navigator = Navigator.of(context);

            try {
              // Колдонуучуну заматта коопсуз Логин бетке багыттайбыз
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthGate()),
                (route) => false,
              );

              // Базадан биротоло өчүрүү
              await Supabase.instance.client.rpc('delete_user_account');
              
              // Локалдык сессияны тазалоо
              await Supabase.instance.client.auth.signOut();

            } catch (e) {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFB7185), //  Жумшак кызыл түс
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deleteText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

