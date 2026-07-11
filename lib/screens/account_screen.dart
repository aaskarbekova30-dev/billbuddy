import 'package:billbuddy/screens/login_screen.dart' show LoginScreen;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/bloc/auth_bloc.dart'; // Сиздин AuthBloc импорту
import '../logic/providers/language_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String _boxName = 'billbuddy_box';
  final String _userNameKey = 'user_name_key';
  String _currentUserName = 'Айжамал'; // Баштапкы ат

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Базадан колдонуучунун атын окуу
  void _loadUserName() async {
    var box = await Hive.openBox(_boxName);
    setState(() {
      _currentUserName = box.get(_userNameKey, defaultValue: 'Асан');
    });
  }

  // Жаңы атты базага сактоо
  void _saveUserName(String newName) async {
    var box = Hive.box(_boxName);
    await box.put(_userNameKey, newName);
    setState(() {
      _currentUserName = newName;
    });
  }

  // Атты өзгөртүүчү диалогдук терезени ачуу функциясы
  void _showEditNameDialog(BuildContext context, String currentName, LanguageProvider langProvider) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text(
            // Тилге жараша өзгөрөт: "Измените имя" же "Атыңызды өзгөртүңүз"
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
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _saveUserName(nameController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text(
                // 🔥 УНИВЕРСАЛДУУ ТЕРМИН: "Ырастоо" сөзү "Сактоо" (Сохранить) терминине алмаштырылды
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: Text(
          langProvider.translate('account_title'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
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
              onTap: () => _showEditNameDialog(context, _currentUserName, langProvider),
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
                      _currentUserName,
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

            // --- МЕНЮ ТИЗМЕСИ ---
            _buildMenuItem(
              icon: Icons.settings_suggest_outlined,
              title: langProvider.translate('preferences'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${langProvider.translate('preferences')} жакында ишке кирет!')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: langProvider.translate('feedback'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${langProvider.translate('feedback')} жакында ишке кирет!')),
                );
              },
            ),
            
            // 🔥 ТҮЗӨТҮЛДҮ: "Чыгуу" баскычы реалдуу AuthBloc жана Супабейс менен туташтырылды
            _buildMenuItem(
              icon: Icons.logout_rounded,
              title: langProvider.translate('logout'),
              iconColor: AppColors.alert,
              textColor: AppColors.alert,
              onTap: () {
                // 1. Блокко чыгуу окуясын жөнөтөбүз
                context.read<AuthBloc>().add(SignOutRequested());

                // 2. Логин экранына кайтарабыз жана артка кайтпай турган кылып тазалайбыз
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
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
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: iconColor.withAlpha(128), // Түзөтүлдү: Эски .withValues ордуна туруктуу иштеген .withAlpha коюлду
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
