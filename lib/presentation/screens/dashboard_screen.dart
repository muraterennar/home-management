import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/domain/entities/user_entity.dart';
import 'package:home_management/features/budget/domain/entities/budget_summary_entity.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';
import 'package:home_management/features/family/domain/entities/family_entity.dart';
import 'package:home_management/features/family/domain/entities/fixed_expense_entity.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
  
  @override
  Widget build(BuildContext context) {
    // Bu kısımda normalde provider'dan veri çekilecek
    // Şimdilik dummy data kullanıyoruz
    final budgetSummary = _getDummyBudgetSummary();
    final recentExpenses = _getDummyExpenses().take(5).toList();
    final family = _getDummyFamily();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
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
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.push('/settings'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            // Verileri yenileme işlemi
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aile bilgisi
                    _buildFamilyCard(context, family),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Bütçe özeti
                    _buildBudgetSummaryCard(context, budgetSummary),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Son harcamalar
                    _buildRecentExpensesCard(context, recentExpenses),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyCard(BuildContext context, FamilyEntity family) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  family.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/family'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '${family.members.length} Üye',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Divider(),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Aylık Gelir',
                  '${family.monthlyIncome.toStringAsFixed(2)} ₺',
                ),
                _buildInfoColumn(
                  context,
                  'Sabit Giderler',
                  '${family.totalFixedExpenses.toStringAsFixed(2)} ₺',
                ),
                _buildInfoColumn(
                  context,
                  'Kalan Bütçe',
                  '${(family.monthlyIncome - family.totalFixedExpenses).toStringAsFixed(2)} ₺',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard(BuildContext context, BudgetSummaryEntity budgetSummary) {
    final currentMonth = DateFormat(AppConstants.monthYearFormat).format(
      DateTime(budgetSummary.year, budgetSummary.month),
    );

    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentMonth Bütçe Özeti',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/budget'),
                  child: const Text('Detaylar'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            LinearProgressIndicator(
              value: budgetSummary.totalExpenses / budgetSummary.totalIncome,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                budgetSummary.totalExpenses > budgetSummary.totalIncome
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budgetSummary.totalExpenses.toStringAsFixed(2)} ₺',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${budgetSummary.totalIncome.toStringAsFixed(2)} ₺',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Toplam Gelir',
                  '${budgetSummary.totalIncome.toStringAsFixed(2)} ₺',
                ),
                _buildInfoColumn(
                  context,
                  'Toplam Gider',
                  '${budgetSummary.totalExpenses.toStringAsFixed(2)} ₺',
                ),
                _buildInfoColumn(
                  context,
                  'Kalan',
                  '${budgetSummary.remainingBudget.toStringAsFixed(2)} ₺',
                  textColor: budgetSummary.remainingBudget < 0
                      ? Colors.red
                      : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpensesCard(BuildContext context, List<ExpenseEntity> expenses) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Harcamalar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/expenses'),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(expense.category),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(expense.category).withOpacity(0.3),
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
                    DateFormat(AppConstants.dateFormat).format(expense.date),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  onTap: () => context.push('/expenses/${expense.id}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String title, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.bills:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
      case ExpenseCategory.groceries:
        return Colors.green;
      case ExpenseCategory.utilities:
        return Colors.cyan;
      case ExpenseCategory.rent:
        return Colors.brown;
      case ExpenseCategory.healthcare:
        return Colors.redAccent;
      case ExpenseCategory.clothing:
        return Colors.deepPurple;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
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
      case ExpenseCategory.groceries:
        return Icons.local_grocery_store;
      case ExpenseCategory.utilities:
        return Icons.power;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.healthcare:
        return Icons.local_hospital;
      case ExpenseCategory.clothing:
        return Icons.checkroom;
    }
  }

  // Dummy data methods
  BudgetSummaryEntity _getDummyBudgetSummary() {
    final now = DateTime.now();
    return BudgetSummaryEntity(
      id: '1',
      familyId: '1',
      month: now.month,
      year: now.year,
      totalIncome: 15000,
      totalExpenses: 9500,
      fixedExpenses: 5000,
      remainingBudget: 5500,
      expensesByCategory: const {
        ExpenseCategory.food: 2000,
        ExpenseCategory.transportation: 1000,
        ExpenseCategory.entertainment: 500,
        ExpenseCategory.health: 300,
        ExpenseCategory.education: 200,
        ExpenseCategory.shopping: 1000,
        ExpenseCategory.bills: 4000,
        ExpenseCategory.other: 500,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<ExpenseEntity> _getDummyExpenses() {
    return [
      ExpenseEntity(
        id: '1',
        title: 'Market Alışverişi',
        amount: 450.75,
        category: ExpenseCategory.food,
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdByUserId: '1',
        familyId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ExpenseEntity(
        id: '2',
        title: 'Benzin',
        amount: 350.00,
        category: ExpenseCategory.transportation,
        date: DateTime.now().subtract(const Duration(days: 2)),
        createdByUserId: '1',
        familyId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ExpenseEntity(
        id: '3',
        title: 'Sinema',
        amount: 150.00,
        category: ExpenseCategory.entertainment,
        date: DateTime.now().subtract(const Duration(days: 3)),
        createdByUserId: '2',
        familyId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ExpenseEntity(
        id: '4',
        title: 'Elektrik Faturası',
        amount: 320.50,
        category: ExpenseCategory.bills,
        date: DateTime.now().subtract(const Duration(days: 4)),
        createdByUserId: '1',
        familyId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ExpenseEntity(
        id: '5',
        title: 'İlaç',
        amount: 120.25,
        category: ExpenseCategory.health,
        date: DateTime.now().subtract(const Duration(days: 5)),
        createdByUserId: '2',
        familyId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  FamilyEntity _getDummyFamily() {
    return FamilyEntity(
      id: '1',
      name: 'Eren Ailesi',
      monthlyIncome: 20000,
      fixedExpenses: [
        FixedExpenseEntity(
          id: '1',
          name: 'Kira',
          amount: 5000,
          familyId: '1',
          paymentDay: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FixedExpenseEntity(
          id: '2',
          name: 'Faturalar',
          amount: 1500,
          familyId: '1',
          paymentDay: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      members: [
        UserEntity(
          id: '1',
          name: 'Murat Eren',
          email: 'murat@example.com',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ),
        UserEntity(
          id: '2',
          name: 'Ayşe Eren',
          email: 'ayse@example.com',
          role: UserRole.user,
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}