import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class HotelSelectionScreen extends StatefulWidget {
  const HotelSelectionScreen({super.key});

  @override
  State<HotelSelectionScreen> createState() => _HotelSelectionScreenState();
}

class _HotelSelectionScreenState extends State<HotelSelectionScreen> {
  final supabase = Supabase.instance.client;
  String _namaUser = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final userData = await supabase.from('users').select('nama_lengkap').eq('id', userId).single();
      if (mounted) {
        setState(() {
          _namaUser = userData['nama_lengkap'] ?? 'User';
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF064E3B), Color(0xFF1B5E20)],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, $_namaUser!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Pilih lokasi untuk menyelamatkan makanan', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFFD4AF37)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mitra Restoran Terdekat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHotelCard(
            context, 
            'Grand Aston Hotel', 
            'Tersedia makanan sisa berkualitas hari ini', 
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=60'
          ),
          _buildHotelCard(
            context, 
            'LuxeBite Central', 
            'Tersedia makanan sisa berkualitas hari ini', 
            'https://images.unsplash.com/photo-1551882547-ff40c0d589fc?w=500&auto=format&fit=crop&q=60'
          ),
          _buildHotelCard(
            context, 
            'Marriott Tangerang', 
            'Habis terjual', 
            'https://images.unsplash.com/photo-1542314831-c6a4d74d9d41?w=500&auto=format&fit=crop&q=60', 
            isAvailable: false
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, String title, String subtitle, String imageUrl, {bool isAvailable = true}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAvailable ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } : null,
        child: Stack(
          children: [
            Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: isAvailable ? Colors.greenAccent : Colors.redAccent, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}