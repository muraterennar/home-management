import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/core/constants/app_constants.dart';
import 'package:home_management/features/auth/data/datasources/auth_service.dart';
import 'package:home_management/features/core/data/datasource/data_service.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _dataService = DataService();
  final _authService = AuthService();
  bool _isLoading = false;
  
  // Animasyon kontrolcüsü
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animasyon kontrolcüsünü başlat
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _monthlyIncomeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _createFamily() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Burada normalde family provider'a create isteği gönderilecek
        await Future.delayed(const Duration(seconds: 2)); // Simüle edilmiş işlem

        // Aile oluşturma işlemi
        final familyName = _familyNameController.text;
        final monthlyIncome = int.parse(_monthlyIncomeController.text);
        final currentUser = await _authService.getCurrentUser();
        final familyCode = _dataService.generateUniqueCode();

        if (currentUser == null) {
          throw Exception('Kullanıcı bulunamadı');
        }
        final familyData = {
          'name': familyName,
          'monthlyIncome': monthlyIncome,
          'code': familyCode,
          'members': [
            {
              'userId': currentUser.uid,
              'name': currentUser.displayName,
              'email': currentUser.email,
            },
          ],
        };

        await _dataService.addData('families', familyData);

        // Kullanıcıya familyId ekleyerek güncelle
        Map<String, dynamic> updatedUser = {
          'id': currentUser.uid,
          'familyId': familyCode,
        };

        await _authService.updateUser(updatedUser);
        
        if (!mounted) return;
        
        // Başarılı aile oluşturma sonrası ana ekrana yönlendirme
        context.go('/dashboard');
      } catch (e) {
        // Hata durumunda snackbar göster
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Oluştur'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Başlık
                        Text(
                          'Ailenizi Oluşturun',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Finansal yönetim için ailenizi tanımlayın',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: AppConstants.largePadding),
                        
                        // Aile adı alanı
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              controller: _familyNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Aile Adı',
                                hintText: 'Ailenizin adını girin',
                                prefixIcon: Icon(
                                  Icons.family_restroom,
                                  color: theme.colorScheme.primary,
                                ),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Aile adı gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        
                        // Aylık gelir alanı
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: AppConstants.largePadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextFormField(
                              controller: _monthlyIncomeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Aylık Gelir',
                                hintText: 'Ailenizin aylık gelirini girin',
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixText: '₺',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Aylık gelir gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        
                        // Aile Oluştur butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createFamily,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Aile Oluştur',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Aileye Katıl seçeneği
                        OutlinedButton(
                          onPressed: () {
                            // Aileye katılma ekranına yönlendirme
                            context.push('/join-family');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Mevcut Bir Aileye Katıl',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}