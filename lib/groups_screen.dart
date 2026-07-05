import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Жильё': return Icons.home_work_rounded;
      case 'Кафе/Праздник': return Icons.local_pizza_rounded;
      case 'Поездки': return Icons.directions_car_rounded;
      default: return Icons.more_horiz_rounded;
    }
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
          'Мои группы',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateGroupFormScreen()),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.background),
                label: const Text(
                  'Создать новую группу',
                  style: TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Список активных групп',
              style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('groups_box').listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('У вас пока нет созданных групп', style: TextStyle(color: AppColors.textGray)),
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
                                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                                  )
                                : Icon(_getIconForType(group['type']), color: AppColors.primary),
                          ),
                          title: Text(
                            group['name'],
                            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Категория: ${group['type']}',
                            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGray, size: 16),
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

  final List<_MainGroupType> _groupTypes = [
    _MainGroupType('Жильё', Icons.home_work_rounded),       
    _MainGroupType('Кафе/Праздник', Icons.local_pizza_rounded), 
    _MainGroupType('Поездки', Icons.directions_car_rounded),  
    _MainGroupType('Другое', Icons.more_horiz_rounded),       
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveGroup() {
    final groupName = _nameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите название группы!'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final groupsBox = Hive.box('groups_box');
    final newGroup = {
      'name': groupName,
      'type': _groupTypes[_selectedTypeIndex].title,
      'imagePath': _imageFile?.path ?? '', 
      'createdAt': DateTime.now().toString(),
    };

    groupsBox.add(newGroup);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Группа "$groupName" успешно создана!'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Создать группу',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 25),
            const Text(
              'Тип группы',
              style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
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
                          size: 28,
                        ),
                        const SizedBox(height: 8),
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
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

