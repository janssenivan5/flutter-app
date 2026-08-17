import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF064E3B), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 80), 
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('ORDER ID: #LX-84920', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      const Icon(Icons.qr_code_2, size: 200, color: Colors.black87),
                      
                      const SizedBox(height: 16),
                      const Text('Surprise Bag - Bintang 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),
                      const Text('Waktu Pengambilan:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Text('Hari ini, 21:00 - 22:00 WIB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Tunjukkan layar ini kepada staf resepsionis\natau petugas prasmanan di lokasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}