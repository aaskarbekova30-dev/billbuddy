import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _MainGroupType {
  final String title;
  final IconData icon;
  _MainGroupType(this.title, this.icon);
}

class _GroupsScreenState extends State<GroupsScreen> {
  int _selectedTypeIndex = 3;
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();
  
  // Сумма жана Топтун аты үчүн контроллерлор
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<_MainGroupType> _groupTypes = [
    _MainGroupType('Жильё', Icons.home_work_rounded),       
    _MainGroupType('Кафе/Праздник', Icons.local_pizza_rounded), 
    _MainGroupType('Поездки', Icons.directions_car_rounded),  
    _MainGroupType('Другое', Icons.more_horiz_rounded),       
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGroup() {
    final groupName = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите название группы!'),
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
      'type': _groupTypes[_selectedTypeIndex].title,
      'imagePath': _imageFile?.path ?? '', 
      'createdAt': DateTime.now().toString(),
    };

    groupsBox.add(newGroup);

    // Сумманы дароо 'billbuddy_box' базасына кошуу логикасы
    try {
      final mainBox = Hive.box('billbuddy_box');
      List<dynamic> savedRaw = mainBox.get('expenses_list_raw', defaultValue: []);
      
      final newExpenseFromGroup = {
        'title': 'Начальный расход ($groupName)', 
        'amount': enteredAmount,
        'date': DateTime.now(),
      };
      
      List<dynamic> updatedList = List.from(savedRaw);
      updatedList.insert(0, newExpenseFromGroup);
      mainBox.put('expenses_list_raw', updatedList);
      
      double currentTotal = mainBox.get('total_balance', defaultValue: 0.0);
      mainBox.put('total_balance', currentTotal + enteredAmount);
    } catch (e) {
      // База ката бербейт
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Группа "$groupName" на сумму \$$enteredAmount успешно создана!'),
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
          title: const Text('Error'),
          content: const Text('Camera not available.'),
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Выбрать аватар группы',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Сделать фото', style: TextStyle(color: AppColors.textWhite)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_rounded, color: AppColors.primary),
                title: const Text('Выбрать из галереи', style: TextStyle(color: AppColors.textWhite)),
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
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Создать группу',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название группы талаасы
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
                        border: Border.all(color: AppColors.primary, width: 1.5), 
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.add_a_photo_outlined, color: AppColors.textGray),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _nameController, 
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 18),
                      decoration: const InputDecoration(
                        border: InputBorder.none, 
                        hintText: 'Название (аппартаменты, ужин...)',
                        hintStyle: TextStyle(color: AppColors.textGray, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 🌟 МЫНА УШУЛ ЖЕРГЕ СУММА КИРГИЗҮҮ ФУНКЦИЯСЫ ТҮЗ ЭЛЕ КОШУЛДУ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBg, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textWhite, fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.attach_money_rounded, color: AppColors.primary),
                  hintText: 'Сумма расхода (необязательно)',
                  hintStyle: TextStyle(color: AppColors.textGray, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Тип группы',
              style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_groupTypes.length, (index) {
                final isSelected = _selectedTypeIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTypeIndex = index;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.22, 
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.textGray.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _groupTypes[index].icon,
                          color: isSelected ? AppColors.primary : AppColors.textWhite,
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _groupTypes[index].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? AppColors.textWhite : AppColors.textGray,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _saveGroup,
                child: const Text(
                  'Создать группу',
                  style: TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

