import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), 
    _buildDummyPage('Aktivitas', 'Pantau status penjemputan & riwayat pesanan'), 
    _buildDummyPage('Pembayaran', 'Kelola E-Wallet & riwayat transaksi'), 
    _buildDummyPage('Profil', 'Pengaturan akun & preferensi'), 
  ];
  @override
  Widget build(BuildContext context) {
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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Telusuri'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Aktivitas'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Bayar'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
  static Widget _buildDummyPage(String title, String description) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF064E3B),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Halaman $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}