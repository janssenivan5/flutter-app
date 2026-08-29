import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; 
import 'aktivitas_screen.dart'; 
import 'pembayaran_screen.dart'; 

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  String _roleUser = 'customer';
  
  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final userData = await supabase.from('users').select('role').eq('id', userId).single();
      
      if (mounted) {
        setState(() {
          _roleUser = userData['role'] ?? 'customer';
          _setupNavigation();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _setupNavigation(); // Default ke customer jika error
          _isLoading = false;
        });
      }
    }
  }

  void _setupNavigation() {
    if (_roleUser == 'admin') {
      // Tampilan khusus Admin (Bayar dihilangkan)
      _pages = [
        const HomeScreen(), 
        const AktivitasScreen(), 
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Telusuri'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Aktivitas'),
      ];
    } else {
      // Tampilan Customer (Lengkap)
      _pages = [
        const HomeScreen(), 
        const AktivitasScreen(), 
        const PembayaranScreen(), 
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Telusuri'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Aktivitas'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Bayar'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF064E3B))),
      );
    }

    // Mencegah error jika state index lebih besar dari jumlah tab (kasus langka saat switch akun)
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF064E3B), 
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; 
            });
          },
          items: _navItems,
        ),
      ),
    );
  }
}