import 'package:flutter/material.dart';
import 'ticket_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat muda agar card menonjol
      appBar: AppBar(
        title: const Text('Rangkuman Pesanan', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF064E3B), // Hijau Emerald LuxeBite
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KARTU 1: Detail Pesanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/surprise_bag.jpg', width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Surprise Bag - Bintang 5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Pastry & Bakery Assortment', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Text('Rp 35.000', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KARTU 2: Informasi Pengambilan (Kunci UX Utama)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Hijau muda sebagai highlight
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF064E3B).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_filled, color: Color(0xFF064E3B)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ambil Sendiri (Self-Pickup)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                          SizedBox(height: 4),
                          Text('Wajib diambil di lobi hotel antara pukul 21:00 - 22:00 WIB hari ini.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KARTU 3: Rincian Biaya (Ala Grab)
              const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Subtotal', style: TextStyle(color: Colors.grey)), Text('Rp 35.000')],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Biaya Platform', style: TextStyle(color: Colors.grey)), Text('Rp 2.000')],
                    ),
                    Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Rp 37.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF064E3B))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // BOTTOM NAVIGATION: Tombol Sticky di Bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF064E3B), // Hijau Emerald
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicketScreen()),
            );
          },
          child: const Text('Bayar Rp 37.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}