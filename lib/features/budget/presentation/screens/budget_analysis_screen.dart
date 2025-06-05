import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/budget/domain/entities/budget_summary_entity.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';
import 'package:intl/intl.dart';

class BudgetAnalysisScreen extends StatefulWidget {
  const BudgetAnalysisScreen({super.key});

  @override
  State<BudgetAnalysisScreen> createState() => _BudgetAnalysisScreenState();
}

class _BudgetAnalysisScreenState extends State<BudgetAnalysisScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Dummy data
  late BudgetSummaryEntity _budgetSummary;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
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

    _loadBudgetData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Burada normalde budget provider'dan veri çekilecek
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem

      // Dummy data oluştur
      _createDummyData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Bütçe verileri yüklenirken hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  void _createDummyData() {
    // Dummy bütçe özeti oluştur
    final Map<ExpenseCategory, double> expensesByCategory = {
      ExpenseCategory.groceries: 1200.0,
      ExpenseCategory.utilities: 650.0,
      ExpenseCategory.transportation: 500.0,
      ExpenseCategory.entertainment: 350.0,
      ExpenseCategory.healthcare: 200.0,
      ExpenseCategory.other: 300.0,
    };

    _budgetSummary = BudgetSummaryEntity(
      id: '1',
      familyId: 'family1',
      month: _selectedMonth,
      year: _selectedYear,
      totalIncome: 8000.0,
      totalExpenses: 3200.0,
      fixedExpenses: 2000.0,
      remainingBudget: 2800.0,
      expensesByCategory: expensesByCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _changeMonth(int month, int year) async {
    setState(() {
      _selectedMonth = month;
      _selectedYear = year;
    });
    await _loadBudgetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Bütçe Analizi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              _showMonthPicker(context);
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
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadBudgetData,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelector(),
                          const SizedBox(height: AppConstants.defaultPadding),
                          _buildBudgetSummaryCard(),
                          const SizedBox(height: AppConstants.defaultPadding),
                          _buildPieChartSection(),
                          const SizedBox(height: AppConstants.defaultPadding),
                          _buildBarChartSection(),
                          const SizedBox(height: AppConstants.defaultPadding),
                          _buildCategoryBreakdown(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthName = DateFormat('MMMM yyyy', 'tr_TR')
        .format(DateTime(_selectedYear, _selectedMonth));

    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                // Önceki ay
                final previousMonth = _selectedMonth == 1
                    ? DateTime(_selectedYear - 1, 12)
                    : DateTime(_selectedYear, _selectedMonth - 1);
                _changeMonth(previousMonth.month, previousMonth.year);
              },
            ),
            Text(
              monthName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // Sonraki ay (şu anki aydan ileri gidemez)
                final now = DateTime.now();
                final currentYearMonth = now.year * 12 + now.month;
                final selectedYearMonth = _selectedYear * 12 + _selectedMonth;

                if (selectedYearMonth < currentYearMonth) {
                  final nextMonth = _selectedMonth == 12
                      ? DateTime(_selectedYear + 1, 1)
                      : DateTime(_selectedYear, _selectedMonth + 1);
                  _changeMonth(nextMonth.month, nextMonth.year);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard() {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bütçe Özeti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBudgetRow(
                'Toplam Gelir', _budgetSummary.totalIncome, Colors.green),
            const Divider(),
            _buildBudgetRow(
                'Sabit Giderler', _budgetSummary.fixedExpenses, Colors.orange),
            const Divider(),
            _buildBudgetRow('Değişken Giderler',
                _budgetSummary.totalVariableExpenses, Colors.red),
            const Divider(),
            _buildBudgetRow(
                'Kalan Bütçe',
                _budgetSummary.remainingBudget,
                _budgetSummary.remainingBudget >= 0
                    ? Colors.green
                    : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(String title, double amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '${amount.toStringAsFixed(2)} ₺',
            style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harcama Dağılımı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _buildLegendItems(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    final totalExpenses = _budgetSummary.totalExpenses;

    if (totalExpenses == 0) {
      // Harcama yoksa boş bir dilim göster
      sections.add(PieChartSectionData(
        color: Colors.grey.shade300,
        value: 1,
        title: 'Harcama Yok',
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ));
      return sections;
    }

    // Sabit giderler
    if (_budgetSummary.fixedExpenses > 0) {
      final percentage = (_budgetSummary.fixedExpenses / totalExpenses) * 100;
      sections.add(PieChartSectionData(
        color: Colors.orange,
        value: _budgetSummary.fixedExpenses,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ));
    }

    // Kategori bazlı harcamalar
    _budgetSummary.expensesByCategory.forEach((category, amount) {
      if (amount > 0) {
        final percentage = (amount / totalExpenses) * 100;
        sections.add(PieChartSectionData(
          color: _getCategoryColor(category),
          value: amount,
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: 80,
          titleStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
      }
    });

    return sections;
  }

  List<Widget> _buildLegendItems() {
    final List<Widget> items = [];

    // Sabit giderler
    items.add(_buildLegendItem('Sabit Giderler', Colors.orange));

    // Kategori bazlı harcamalar
    _budgetSummary.expensesByCategory.forEach((category, amount) {
      if (amount > 0) {
        items.add(_buildLegendItem(
            _getCategoryName(category), _getCategoryColor(category)));
      }
    });

    return items;
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBarChartSection() {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelir ve Gider Karşılaştırması',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: _budgetSummary.totalIncome * 1.2,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: _budgetSummary.totalIncome,
                          color: Colors.green,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: _budgetSummary.fixedExpenses,
                          color: Colors.orange,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: _budgetSummary.totalVariableExpenses,
                          color: Colors.red,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0:
                              text = 'Gelir';
                              break;
                            case 1:
                              text = 'Sabit';
                              break;
                            case 2:
                              text = 'Değişken';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text,
                                style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Bazlı Harcamalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ..._budgetSummary.expensesByCategory.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = _budgetSummary.getCategoryPercentage(category);

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getCategoryIcon(category),
                            color: _getCategoryColor(category)),
                      ),
                      const SizedBox(width: 8),
                      Text(_getCategoryName(category)),
                      const Spacer(),
                      Text(
                        '${amount.toStringAsFixed(2)} ₺',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text('(${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getCategoryColor(category)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    // Daha hafif ve performanslı bir ay/yıl seçici
    final currentYear = DateTime.now().year;
    final yearList = List.generate(5, (index) => currentYear - 2 + index);
    
    // Ay isimleri listesi - önceden oluşturulmuş
    final monthNames = List.generate(12, (index) {
      return DateFormat('MMMM', 'tr_TR').format(DateTime(2023, index + 1));
    });
    
    int tempSelectedMonth = _selectedMonth;
    int tempSelectedYear = _selectedYear;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Tarih Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Yıl seçici dropdown
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Yıl',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: tempSelectedYear,
                      items: yearList.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempSelectedYear = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ay seçici dropdown
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Ay',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: tempSelectedMonth,
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(monthNames[index]),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempSelectedMonth = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeMonth(DateTime.now().month, DateTime.now().year);
                  },
                  child: const Text('Bu Ay'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _changeMonth(tempSelectedMonth, tempSelectedYear);
                  },
                  child: const Text('Uygula'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.groceries:
        return Colors.green;
      case ExpenseCategory.utilities:
        return Colors.blue;
      case ExpenseCategory.rent:
        return Colors.purple;
      case ExpenseCategory.transportation:
        return Colors.orange.shade700;
      case ExpenseCategory.entertainment:
        return Colors.pink;
      case ExpenseCategory.healthcare:
        return Colors.red;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.clothing:
        return Colors.teal;
      case ExpenseCategory.shopping:
        return Colors.amber;
      case ExpenseCategory.other:
        return Colors.grey;
      case ExpenseCategory.bills:
        return Colors.greenAccent;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.bills:
        return Icons.receipt;
      case ExpenseCategory.health:
        return Icons.local_hospital;
      case ExpenseCategory.shopping:
        return Icons.shopping_basket;
      case ExpenseCategory.groceries:
        return Icons.shopping_cart;
      case ExpenseCategory.utilities:
        return Icons.lightbulb;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.healthcare:
        return Icons.medical_services;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.clothing:
        return Icons.shopping_bag;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'Yemek';
      case ExpenseCategory.bills:
        return 'Faturalar';
      case ExpenseCategory.health:
        return 'Sağlık';
      case ExpenseCategory.shopping:
        return 'Alışveriş';
      case ExpenseCategory.groceries:
        return 'Market';
      case ExpenseCategory.utilities:
        return 'Faturalar';
      case ExpenseCategory.rent:
        return 'Kira';
      case ExpenseCategory.transportation:
        return 'Ulaşım';
      case ExpenseCategory.entertainment:
        return 'Eğlence';
      case ExpenseCategory.healthcare:
        return 'Sağlık';
      case ExpenseCategory.education:
        return 'Eğitim';
      case ExpenseCategory.clothing:
        return 'Giyim';
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }
}
