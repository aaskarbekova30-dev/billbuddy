import 'package:flutter/material.dart';
import '../core/services/language_provider.dart';
import '../core/services/supabase_provider.dart';


class EditNameDialog extends StatefulWidget {
  final String currentName;
  final LanguageProvider langProvider;
  final SupabaseProvider supabaseProvider;

  const EditNameDialog({
    super.key,
    required this.currentName,
    required this.langProvider,
    required this.supabaseProvider,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E252B), //  Жумшак боз карточка фону
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), //  Жумшак тегерек бурчтар
      title: Text(
        widget.langProvider.translate('edit_name_title'),
        style: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.w800, 
          letterSpacing: -0.5,
          fontSize: 18,
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF12161A), // Ички терең боз фон
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none, // Эски сызыктар толук алынды
          ),
        ),
      ),
      actions: [
        // ЖОККО ЧЫГАРУУ БАСКЫЧЫ
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            widget.langProvider.translate('cancel'),
            style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          ),
        ),
        
        // САКТОО БАСКЫЧЫ
        InkWell(
          onTap: () async {
            if (_nameController.text.trim().isNotEmpty) {
              await widget.supabaseProvider.updateProfile(_nameController.text.trim());
              if (context.mounted) Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80), // Биз тандаган жалбыз жашыл түс
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.langProvider.translate('save'),
              style: const TextStyle(
                color: Color(0xFF12161A), // Тексттин кочкул боз түсү
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

