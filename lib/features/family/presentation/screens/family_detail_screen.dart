import 'package:flutter/material.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/domain/entities/user_entity.dart';
import 'package:home_management/features/family/domain/entities/family_entity.dart';
import 'package:home_management/features/family/domain/entities/fixed_expense_entity.dart';

class FamilyDetailScreen extends StatefulWidget {
  const FamilyDetailScreen({super.key});

  @override
  State<FamilyDetailScreen> createState() => _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends State<FamilyDetailScreen> {
  bool _isLoading = false;
  late FamilyEntity _family;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    setState(() {
      _isLoading = true;
    });

    // Burada gerçek API çağrısı yapılacak
    // Şimdilik dummy data kullanıyoruz
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _family = FamilyEntity(
        monthlyIncome: 10000,
        id: '1',
        name: 'Eren Ailesi',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
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
        fixedExpenses: [
          FixedExpenseEntity(
            id: '1',
            name: 'Kira',
            amount: 5000,
            paymentDay: DateTime.now().add(const Duration(days: 15)),
            familyId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          FixedExpenseEntity(
            id: '2',
            name: 'İnternet',
            amount: 300,
            paymentDay: DateTime.now().add(const Duration(days: 10)),
            familyId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          FixedExpenseEntity(
            id: '3',
            name: 'Elektrik',
            amount: 400,
            paymentDay: DateTime.now().add(const Duration(days: 20)),
            familyId: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Aile düzenleme ekranına git
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFamilyInfoCard(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildMembersSection(),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildFixedExpensesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFamilyInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.family_restroom, size: 40),
                const SizedBox(width: AppConstants.defaultPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _family.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${_family.members.length} Üye',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Oluşturulma: ${_formatDate(_family.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aile Üyeleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {
                // Üye davet et
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Davet Et'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ..._family.members.map((member) => _buildMemberItem(member)),
      ],
    );
  }

  Widget _buildMemberItem(UserEntity member) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(member.name.substring(0, 1)),
        ),
        title: Text(member.name),
        subtitle: Text(member.email),
        trailing: member.isAdmin
            ? const Chip(
                label: Text('Admin'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildFixedExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sabit Giderler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {
                // Sabit gider ekle
              },
              icon: const Icon(Icons.add),
              label: const Text('Ekle'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ..._family.fixedExpenses
            .map((expense) => _buildFixedExpenseItem(expense)),
      ],
    );
  }

  Widget _buildFixedExpenseItem(FixedExpenseEntity expense) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(expense.name),
        subtitle: Text('Her ayın ${expense.paymentDay.day}. günü'),
        trailing: Text(
          '${expense.amount.toStringAsFixed(2)} ₺',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
