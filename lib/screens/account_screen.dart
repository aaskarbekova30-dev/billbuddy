import 'package:billbuddy/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart';
import '../logic/providers/supabase_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // Экран ачылганда Супабейстен акыркы профиль маалыматын жаңылайбыз
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupabaseProvider>().fetchProfile();
    });
  }

  // Атты өзгөртүүчү диалогдук терезени ачуу функциясы
  void _showEditNameDialog(
    BuildContext context, 
    String currentName, 
    LanguageProvider langProvider,
    SupabaseProvider supabaseProvider,
  ) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text(
            langProvider.translate('edit_name_title'),
            style: const TextStyle(color: AppColors.textWhite),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textGray),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                langProvider.translate('cancel'),
                style: const TextStyle(color: AppColors.textGray),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  // Түз эле Супабейс серверине сактайбыз
                  await supabaseProvider.updateProfile(nameController.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(
                langProvider.translate('save'),
                style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final supabaseProvider = Provider.of<SupabaseProvider>(context); 
    final currentUserName = supabaseProvider.userName;

    return Scaffold(
      backgroundColor: AppColors.background,
     appBar: AppBar(
  backgroundColor: AppColors.background,
  elevation: 0,
  iconTheme: const IconThemeData(color: AppColors.textWhite),
  title: Text(
    // 🛠️ ОҢДОЛДУ: Тил орусча болгондо сөз автоматтык түрдө "Аккаунт" деп чыгат
    langProvider.currentLang == 'ru' 
        ? 'Аккаунт' 
        : (langProvider.currentLang == 'en' ? 'Account' : 'Аккаунт'),
    style: const TextStyle(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
),

      body: supabaseProvider.isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // --- КОЛДОНУУЧУНУН АВАТАРЫ ЖАНА АТЫ ---
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.textWhite,
                    child: Icon(Icons.person, size: 50, color: AppColors.background),
                  ),
                  const SizedBox(height: 15),

                  InkWell(
                    onTap: () => _showEditNameDialog(context, currentUserName, langProvider, supabaseProvider),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentUserName,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: langProvider.translate('logout'),
                    iconColor: AppColors.alert,
                    textColor: AppColors.alert,
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const AuthGate()),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const Spacer(),

                  Text(
                    '${langProvider.translate('app_version')}: 1.0.0',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // Сиз жөнөткөн, withValues(alpha: 0.5) касиети бар виджет
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.textWhite,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: iconColor.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
