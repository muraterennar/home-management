class AppConstants {
  // App Info
  static const String appName = 'Ev Yönetim Uygulaması';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String userEndpoint = '/api/user';
  static const String familyEndpoint = '/api/family';
  static const String expenseEndpoint = '/api/expenses';
  static const String budgetEndpoint = '/api/budget';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String familyKey = 'family_data';
  static const String themeKey = 'app_theme';
  
  // Error Messages
  static const String networkErrorMessage = 'İnternet bağlantısı bulunamadı';
  static const String serverErrorMessage = 'Sunucu hatası oluştu';
  static const String authErrorMessage = 'Giriş bilgilerinizi kontrol ediniz';
  static const String unknownErrorMessage = 'Bilinmeyen bir hata oluştu';
  
  // Success Messages
  static const String loginSuccessMessage = 'Giriş başarılı';
  static const String registerSuccessMessage = 'Kayıt başarılı';
  static const String expenseAddedMessage = 'Harcama başarıyla eklendi';
  static const String expenseUpdatedMessage = 'Harcama başarıyla güncellendi';
  static const String expenseDeletedMessage = 'Harcama başarıyla silindi';
  static const String familyCreatedMessage = 'Aile başarıyla oluşturuldu';
  static const String familyUpdatedMessage = 'Aile bilgileri güncellendi';
  
  // Validation Messages
  static const String emailRequired = 'E-posta adresi gereklidir';
  static const String invalidEmail = 'Geçerli bir e-posta adresi giriniz';
  static const String passwordRequired = 'Şifre gereklidir';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalıdır';
  static const String nameRequired = 'İsim gereklidir';
  static const String titleRequired = 'Başlık gereklidir';
  static const String amountRequired = 'Tutar gereklidir';
  static const String invalidAmount = 'Geçerli bir tutar giriniz';
  static const String categoryRequired = 'Kategori seçiniz';
  static const String dateRequired = 'Tarih seçiniz';
  
  // Expense Categories
  static const Map<String, String> expenseCategories = {
    'food': 'Gıda',
    'transportation': 'Ulaşım',
    'entertainment': 'Eğlence',
    'health': 'Sağlık',
    'education': 'Eğitim',
    'shopping': 'Alışveriş',
    'bills': 'Faturalar',
    'other': 'Diğer',
  };
  
  // Date Formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
}