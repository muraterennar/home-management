import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Filtreleme için state değişkenleri
  final Set<ExpenseCategory> _selectedCategories = {};
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<ExpenseEntity> _expenses = [
    // Dummy data
    ExpenseEntity(
      id: '1',
      title: 'Market Alışverişi',
      amount: 450.0,
      category: ExpenseCategory.food,
      date: DateTime.now().subtract(const Duration(days: 1)),
      createdByUserId: 'user1',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ExpenseEntity(
      id: '2',
      title: 'Elektrik Faturası',
      amount: 320.0,
      category: ExpenseCategory.bills,
      date: DateTime.now().subtract(const Duration(days: 3)),
      createdByUserId: 'user2',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ExpenseEntity(
      id: '3',
      title: 'Sinema Bileti',
      amount: 150.0,
      category: ExpenseCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 5)),
      createdByUserId: 'user1',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ExpenseEntity(
      id: '4',
      title: 'Benzin',
      amount: 500.0,
      category: ExpenseCategory.transportation,
      date: DateTime.now().subtract(const Duration(days: 7)),
      createdByUserId: 'user2',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  Future<void> _refreshExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Burada normalde expense provider'dan veri çekilecek
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem

      // Dummy data zaten yüklü olduğu için bir şey yapmıyoruz
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harcamalar yüklenirken hata: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshExpenses();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Excel dosyası oluşturma ve kaydetme fonksiyonu
  Future<void> _exportToExcel() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Excel dosyası oluştur
      final excel = Excel.createExcel(); // varsayılan olarak 'Sheet1' gelir
      final customSheetName = excel.getDefaultSheet() ?? 'Sheet1';
      // Sayfa referansını al
      final Sheet sheet = excel.sheets[customSheetName]!;

      // Başlık satırı ekle
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'Başlık';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Kategori';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Tutar';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Tarih';

      // Başlık satırı için stil oluştur
      final CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#DDDDDD",
        horizontalAlign: HorizontalAlign.Center,
      );

      // Başlık satırına stil uygula
      for (int i = 0; i < 4; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = headerStyle;
      }

      // Verileri ekle
      for (int i = 0; i < _expenses.length; i++) {
        final expense = _expenses[i];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = expense.title;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = _getCategoryName(expense.category);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = expense.amount;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = DateFormat('dd.MM.yyyy', 'tr_TR').format(expense.date);
      }

      // Sütun genişliklerini ayarla
      sheet.setColWidth(0, 30);
      sheet.setColWidth(1, 20);
      sheet.setColWidth(2, 15);
      sheet.setColWidth(3, 15);

      // Dosyayı kaydet
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName =
            'Harcamalar_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        final String filePath = '${directory.path}/$fileName';

        final List<int>? fileBytes = excel.save();
        if (fileBytes != null) {
          final File file = File(filePath);
          await file.writeAsBytes(fileBytes);

          // Dosyayı açmak için open_file paketini kullanın
          try {
            // Excel dosyasını otomatik olarak aç
            final result = await OpenFile.open(filePath);
            
            if (result.type != ResultType.done) {
              // Dosya açılamazsa kullanıcıya bildir
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Excel dosyası kaydedildi: $filePath'),
                  action: SnackBarAction(
                    label: 'Tekrar Aç',
                    onPressed: () {
                      OpenFile.open(filePath);
                    },
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dosya açılırken hata oluştu: ${e.toString()}')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya kaydetme izni verilmedi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Excel dosyası oluşturulurken hata: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Harcamalar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _exportToExcel,
            tooltip: 'Excel\'e Aktar',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              // Filtreleme modalı göster
              _showFilterModal(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshExpenses,
                child: _filteredExpenses.isEmpty
                    ? _buildEmptyState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildExpenseList(),
                        ),
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/expenses/add');
        },
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Henüz harcama bulunmuyor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yeni bir harcama eklemek için + butonuna tıklayın',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/expenses/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Harcama Ekle'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return Card(
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _getCategoryColor(expense.category).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(expense.title),
              subtitle: Text(
                DateFormat('dd MMMM yyyy', 'tr_TR').format(expense.date),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${expense.amount.toStringAsFixed(2)} ₺',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              onTap: () {
                // Harcama detayına git
                context.push('/main/expenses/detail/${expense.id}');
              },
            ),
          ),
        );
      },
    );
  }

  // Filtrelenmiş harcamaları döndüren getter
  List<ExpenseEntity> get _filteredExpenses {
    return _expenses.where((expense) {
      // Kategori filtresi
      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(expense.category)) {
        return false;
      }
      
      // Başlangıç tarihi filtresi
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      
      // Bitiş tarihi filtresi
      if (_endDate != null) {
        // Bitiş tarihini günün sonuna ayarla (23:59:59)
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (expense.date.isAfter(endOfDay)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _showFilterModal(BuildContext context) {
    // Geçici değişkenler oluştur (mevcut filtreleri kopyala)
    final tempSelectedCategories = Set<ExpenseCategory>.from(_selectedCategories);
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Harcamaları Filtrele',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Kategori filtreleme
                  const Text('Kategori',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ExpenseCategory.values.map((category) {
                      return FilterChip(
                        label: Text(_getCategoryName(category)),
                        selected: tempSelectedCategories.contains(category),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempSelectedCategories.add(category);
                            } else {
                              tempSelectedCategories.remove(category);
                            }
                          });
                        },
                        avatar: Icon(_getCategoryIcon(category)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Tarih aralığı
                  const Text('Tarih Aralığı',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempStartDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(tempStartDate == null
                              ? 'Başlangıç'
                              : DateFormat('dd.MM.yyyy', 'tr_TR').format(tempStartDate!)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempEndDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(tempEndDate == null
                              ? 'Bitiş'
                              : DateFormat('dd.MM.yyyy', 'tr_TR').format(tempEndDate!)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // Filtreleri uygula
                      setState(() {
                        _selectedCategories.clear();
                        _selectedCategories.addAll(tempSelectedCategories);
                        _startDate = tempStartDate;
                        _endDate = tempEndDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Filtreleri Uygula'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      // Filtreleri sıfırla
                      setState(() {
                        _selectedCategories.clear();
                        _startDate = null;
                        _endDate = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Filtreleri Sıfırla'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.utilities:
        return Colors.purple;
      case ExpenseCategory.rent:
        return Colors.brown;
      case ExpenseCategory.healthcare:
        return Colors.redAccent;
      case ExpenseCategory.clothing:
        return Colors.deepPurple;
      case ExpenseCategory.groceries:
        return Colors.lightGreen;
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.bills:
        return Colors.blue;
      case ExpenseCategory.transportation:
        return Colors.orange;
      case ExpenseCategory.entertainment:
        return Colors.pink;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.shopping:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.clothing:
        return Icons.checkroom;
      case ExpenseCategory.healthcare:
        return Icons.local_hospital;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.utilities:
        return Icons.power;
      case ExpenseCategory.groceries:
        return Icons.local_grocery_store;
      case ExpenseCategory.food:
        return Icons.restaurant;
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
      case ExpenseCategory.bills:
        return Icons.receipt;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return 'Kira';
      case ExpenseCategory.clothing:
        return 'Giyim';
      case ExpenseCategory.healthcare:
        return 'Sağlık';
      case ExpenseCategory.utilities:
        return 'Faturalar';
      case ExpenseCategory.groceries:
        return 'Market';
      case ExpenseCategory.food:
        return 'Yemek';
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
      case ExpenseCategory.bills:
        return 'Faturalar';
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }
}
