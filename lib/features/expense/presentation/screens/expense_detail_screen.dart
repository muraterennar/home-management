import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';
import 'package:intl/intl.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool _isLoading = true;
  ExpenseEntity? _expense;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    // Gerçek uygulamada burada API'den veya veritabanından harcama detayları yüklenecek
    // Şimdilik dummy data kullanıyoruz
    await Future.delayed(
        const Duration(milliseconds: 500)); // API çağrısı simülasyonu

    setState(() {
      _expense = ExpenseEntity(
        id: widget.expenseId,
        title: 'Market Alışverişi',
        amount: 450.0,
        category: ExpenseCategory.food,
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdByUserId: 'user1',
        familyId: 'family1',
        description:
            'Haftalık market alışverişi. Meyve, sebze ve temel gıda maddeleri alındı.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Düzenleme ekranına yönlendirme yapılabilir
              // context.push('/expenses/edit/${widget.expenseId}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expense == null
              ? const Center(child: Text('Harcama bulunamadı'))
              : _buildExpenseDetails(),
    );
  }

  Widget _buildExpenseDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Tutar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _expense!.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${_expense!.amount.toStringAsFixed(2)} ₺',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Kategori ve Tarih
          Row(
            children: [
              Chip(
                avatar: Icon(_getCategoryIcon(_expense!.category), size: 18),
                label: Text(_getCategoryName(_expense!.category)),
                backgroundColor:
                    _getCategoryColor(_expense!.category).withOpacity(0.2),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Chip(
                avatar: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                    DateFormat('dd MMMM yyyy', 'tr_TR').format(_expense!.date)),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Açıklama
          if (_expense!.description != null &&
              _expense!.description!.isNotEmpty) ...[
            const Text(
              'Açıklama',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_expense!.description!),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Oluşturulma ve Güncellenme Bilgileri
          const Text(
            'Diğer Bilgiler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildInfoRow(
              'Oluşturulma Tarihi',
              DateFormat('dd MMMM yyyy HH:mm', 'tr_TR')
                  .format(_expense!.createdAt)),
          _buildInfoRow(
              'Son Güncelleme',
              DateFormat('dd MMMM yyyy HH:mm', 'tr_TR')
                  .format(_expense!.updatedAt)),
          _buildInfoRow(
              'Harcama Yapan', 'Kullanıcı ID: ${_expense!.createdByUserId}'),
          _buildInfoRow('Aile ID', _expense!.familyId),

          // Fatura Fotoğrafı (Opsiyonel özellik)
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Fatura fotoğrafını görüntüleme işlemi
              },
              icon: const Icon(Icons.photo),
              label: const Text('Fatura Fotoğrafını Görüntüle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harcamayı Sil'),
        content: const Text('Bu harcamayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExpense();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense() async {
    setState(() {
      _isLoading = true;
    });

    // Gerçek uygulamada burada API'ye silme isteği gönderilecek
    await Future.delayed(const Duration(seconds: 1)); // API çağrısı simülasyonu

    // Başarılı silme işlemi sonrası ana sayfaya dön
    if (mounted) {
      context.pop(); // Önceki sayfaya dön
      // Opsiyonel: Silme başarılı mesajı gösterilebilir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harcama başarıyla silindi')),
      );
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.utilities:
        return Icons.power;
      case ExpenseCategory.groceries:
        return Icons.local_grocery_store;
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
      case ExpenseCategory.healthcare:
        return Icons.medical_services;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.other:
        return Icons.category;
      default:
        return Icons.category; // Default icon for any new categories
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
        return 'Fatura';
      case ExpenseCategory.groceries:
        return 'Market';
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
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.bills:
        return Colors.blue; 
      case ExpenseCategory.transportation:
        return Colors.orange;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.other:
        return Colors.grey;
      case ExpenseCategory.groceries:
        return Colors.lightGreen;
      case ExpenseCategory.utilities:
        return Colors.lightBlue;
      case ExpenseCategory.rent:
        return Colors.brown;
      case ExpenseCategory.healthcare:
        return Colors.redAccent;
      case ExpenseCategory.clothing:
        return Colors.deepPurple;
    }
  }
}
