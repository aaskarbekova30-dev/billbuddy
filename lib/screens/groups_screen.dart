import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../logic/providers/language_provider.dart';
import '../logic/providers/supabase_provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  IconData _getIconForType(String type) {
    if (type == 'Жильё' || type == 'Үй-жай' || type == 'Housing') {
      return Icons.home_work_rounded;
    }
    if (type == 'Кафе/Праздник' ||
        type == 'Кафе/Майрам' ||
        type == 'Cafe/Party') {
      return Icons.local_pizza_rounded;
    }
    if (type == 'Поездки' || type == 'Сапарлар' || type == 'Travel') {
      return Icons.directions_car_rounded;
    }
    return Icons.more_horiz_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          langProvider.translate('my_groups_title'),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupFormScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.background,
                ),
                label: Text(
                  langProvider.translate('create_new_group'),
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              langProvider.translate('active_groups_list'),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('groups_box').listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return Center(
                      child: Text(
                        langProvider.translate('no_groups_yet'),
                        style: const TextStyle(color: AppColors.textGray),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final group = box.getAt(box.length - 1 - index) as Map;
                      final imagePath = group['imagePath'] as String;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    _getIconForType(group['type']),
                                    color: AppColors.primary,
                                  ),
                          ),
                          title: Text(
                            group['name'],
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${langProvider.translate('group_direction_label')}: ${group['type']}',
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontSize: 13,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textGray,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateGroupFormScreen extends StatefulWidget {
  const CreateGroupFormScreen({super.key});

  @override
  State<CreateGroupFormScreen> createState() => _CreateGroupFormScreenState();
}

class _MainGroupType {
  final String title;
  final IconData icon;
  _MainGroupType(this.title, this.icon);
}

class _CreateGroupFormScreenState extends State<CreateGroupFormScreen> {
  int _selectedTypeIndex = 3;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGroup() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final groupName = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    String selectedTypeKey = 'type_other';
    if (_selectedTypeIndex == 0) selectedTypeKey = 'type_housing';
    if (_selectedTypeIndex == 1) selectedTypeKey = 'type_cafe';
    if (_selectedTypeIndex == 2) selectedTypeKey = 'type_travel';
    final translatedType = langProvider.translate(selectedTypeKey);

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('alert_enter_group_name')),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    double enteredAmount = 0.0;
    if (amountText.isNotEmpty) {
      enteredAmount = double.tryParse(amountText) ?? 0.0;
    }

    final groupsBox = Hive.box('groups_box');
    final newGroup = {
      'name': groupName,
      'type': translatedType,
      'imagePath': _imageFile?.path ?? '',
      'createdAt': DateTime.now().toString(),
    };

    groupsBox.add(newGroup);
        // Жаңы топту дароо Супабейс серверине (булутка) жөнөтөбүз!
    try {
      final supabaseProvider = Provider.of<SupabaseProvider>(context, listen: false);
      supabaseProvider.addGroup(
        name: groupName,
        type: translatedType,
        imagePath: _imageFile?.path ?? '',
      );
      
      // Эгер колдонуучу сумма киргизген болсо, аны да өзүнчө 'expenses' таблицасына кошо жөнөтөбүз
      if (enteredAmount > 0) {
        supabaseProvider.addExpense(
          title: '${langProvider.translate('initial_expense_prefix')} ($groupName)',
          amount: enteredAmount,
          groupName: groupName,
        );
      }
    } catch (e) {
      debugPrint('Серверге жүктөөдө ката: $e');
    }


    try {
      final mainBox = Hive.box('billbuddy_box');
      List<dynamic> savedRaw = mainBox.get(
        'expenses_list_raw',
        defaultValue: [],
      );

      final newExpenseFromGroup = {
        'title':
            '${langProvider.translate('initial_expense_prefix')} ($groupName)',
        'amount': enteredAmount,
        'date': DateTime.now(),
      };

      List<dynamic> updatedList = List.from(savedRaw);
      updatedList.insert(0, newExpenseFromGroup);
      mainBox.put('expenses_list_raw', updatedList);

      double currentTotal = mainBox.get('total_balance', defaultValue: 0.0);
      mainBox.put('total_balance', currentTotal + enteredAmount);
    } catch (e) {
      // Base ката бербейт
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"$groupName" ${langProvider.translate('group_created_success')} (\$$enteredAmount)',
        ),
        backgroundColor: AppColors.primary,
      ),
    );

    _nameController.clear();
    _amountController.clear();
    setState(() {
      _imageFile = null;
      _selectedTypeIndex = 3;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(langProvider.translate('error_title')),
          content: Text(langProvider.translate('camera_not_available')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showAvatarPicker() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  langProvider.translate('choose_group_avatar'),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  langProvider.translate('take_photo'),
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.image_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  langProvider.translate('choose_from_gallery'),
                  style: const TextStyle(color: AppColors.textWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final List<_MainGroupType> groupTypes = [
      _MainGroupType(
        langProvider.translate('type_housing'),
        Icons.home_work_rounded,
      ),
      _MainGroupType(
        langProvider.translate('type_cafe'),
        Icons.local_pizza_rounded,
      ),
      _MainGroupType(
        langProvider.translate('type_travel'),
        Icons.directions_car_rounded,
      ),
      _MainGroupType(
        langProvider.translate('type_other'),
        Icons.more_horiz_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          langProvider.translate('create_group_title'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.textGray,
                            ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: langProvider.translate('hint_group_name'),
                        hintStyle: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.attach_money_rounded,
                    color: AppColors.primary,
                  ),
                  hintText: langProvider.translate('hint_expense_amount'),
                  hintStyle: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              langProvider.translate('group_direction_title'),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(groupTypes.length, (index) {
                final isSelected = _selectedTypeIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTypeIndex = index;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    height: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textGray.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          groupTypes[index].icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textWhite,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          groupTypes[index].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textWhite
                                : AppColors.textGray,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveGroup,
                child: Text(
                  langProvider.translate('btn_create_group'),
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
