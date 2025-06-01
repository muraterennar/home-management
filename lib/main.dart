import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_management/core/di/injection.dart';
import 'package:home_management/core/routes/app_router.dart';
import 'package:home_management/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bağımlılık enjeksiyonunu yapılandır
  await configureDependencies();
  
  // Tarih formatları için Türkçe desteği
  await initializeDateFormatting('tr_TR', null);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Ev Yönetim Uygulaması',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
    );
  }
}
