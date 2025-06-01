import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _image;
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Optimize image quality
      );

      if (pickedFile != null) {
        // Create a unique filename using timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'expense_receipt_$timestamp.jpg';

        // Get the temporary file
        final imageFile = File(pickedFile.path);

        // TODO: Upload image to storage service
        // Example using Firebase Storage:
        // final storageRef = FirebaseStorage.instance.ref().child('receipts/$fileName');
        // final uploadTask = await storageRef.putFile(imageFile);
        // final downloadUrl = await uploadTask.ref.getDownloadURL();

        setState(() {
          _image = imageFile;
          // Store the download URL in your expense entity
          // _imageUrl = downloadUrl;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera iptal edildi')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Fotoğraf yüklenirken hata oluştu: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Burada normalde expense provider'a add isteği gönderilecek
        await Future.delayed(
            const Duration(seconds: 2)); // Simüle edilmiş işlem

        if (!mounted) return;

        // Başarılı harcama ekleme sonrası harcama listesine dön
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harcama başarıyla eklendi')),
        );
        context.pop();
      } catch (e) {
        // Hata durumunda snackbar göster
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Ekle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık alanı
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Harcama başlığını girin',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gereklidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Tutar alanı
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tutar',
                    hintText: 'Harcama tutarını girin',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: '₺',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tutar gereklidir';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir tutar girin';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Tutar sıfırdan büyük olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Kategori seçimi
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ExpenseCategory.values.map((category) {
                    return DropdownMenuItem<ExpenseCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category), size: 20),
                          const SizedBox(width: 8),
                          Text(_getCategoryName(category)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Tarih seçimi
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Açıklama alanı
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (İsteğe bağlı)',
                    hintText: 'Harcama hakkında detay ekleyin',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),

                Center(
                    child: _image != null
                        ? Column(
                            children: [
                              Image.file(_image!), // Fotoğrafı gösteriyoruz
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Fatura: ${DateFormat('dd-MM-yyyy_HH-mm').format(_selectedDate)}', // Show date and time with filename
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 22),
                              child: Text(
                                'Fatura Eklenmedi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ])),

                // Fotoğraf ekleme butonu (opsiyonel özellik)
                OutlinedButton.icon(
                  onPressed: () {
                    _openCamera();
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Fatura Fotoğrafı Ekle'),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Kaydet butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Harcamayı Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.groceries:
        return Icons.shopping_cart;
      case ExpenseCategory.other:
        return Icons.category;
      case ExpenseCategory.clothing:
        return Icons.checkroom;
      case ExpenseCategory.healthcare:
        return Icons.local_hospital;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.utilities:
        return Icons.power;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.clothing:
        return 'Giyim';
      case ExpenseCategory.healthcare:
        return 'Sağlık Hizmetleri';
      case ExpenseCategory.rent:
        return 'Kira';
      case ExpenseCategory.utilities:
        return 'Kamu Hizmetleri';
      case ExpenseCategory.food:
        return 'Yemek';
      case ExpenseCategory.bills:
        return 'Faturalar';
      case ExpenseCategory.transportation:
        return 'Ulaşım';
      case ExpenseCategory.entertainment:
        return 'Eğlence';
      case ExpenseCategory.health:
        return 'Sağlık';
      case ExpenseCategory.education:
        return 'Eğitim';
      case ExpenseCategory.shopping:
        return 'Alışveriş';
      case ExpenseCategory.groceries:
        return 'Market';
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }
}
