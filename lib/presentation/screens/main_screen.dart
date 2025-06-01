import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<String> _routes = [
    '/dashboard',
    '/expenses',
    '/budget',
    '/profile',
  ];
  
  @override
  void initState() {
    super.initState();
    
    // FAB animasyonu için controller
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Başlangıçta animasyonu çalıştır
    _fabAnimationController.forward();
  }
  
  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Harcamalar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline),
                activeIcon: Icon(Icons.pie_chart),
                label: 'Bütçe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      )
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int index = _routes.indexWhere((route) => location.startsWith(route));
    
    if (index >= 0) {
      // Eğer index değişirse, FAB animasyonunu yeniden başlat
      if (_currentIndex != index && index == 1) {
        _fabAnimationController.reset();
        _fabAnimationController.forward();
      }
      
      setState(() {
        _currentIndex = index;
      });
      return index;
    }
    
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index != _currentIndex) {
      context.go(_routes[index]);
      
      // Eğer harcamalar sekmesine geçilirse, FAB animasyonunu başlat
      if (index == 1) {
        _fabAnimationController.reset();
        _fabAnimationController.forward();
      }
      
      setState(() {
        _currentIndex = index;
      });
    }
  }
}