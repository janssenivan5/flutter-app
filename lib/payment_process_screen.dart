import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ticket_screen.dart';

class PaymentProcessScreen extends StatefulWidget {
  final String paymentMethod;
  final int totalAmount;
  final String menuName; 
  final Map<String, dynamic> menuData; // Tambahan untuk menarik ID makanan
  final int quantity; // Tambahan untuk tahu jumlah yang dibeli

  const PaymentProcessScreen({
    super.key,
    required this.paymentMethod,
    required this.totalAmount,
    required this.menuName, 
    required this.menuData,
    this.quantity = 1,
  });

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  final supabase = Supabase.instance.client;
  bool _isProcessing = false;

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pembayaran ${widget.paymentMethod}', style: const TextStyle(color: Colors.white)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF064E3B), Color(0xFF1B5E20)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: widget.paymentMethod == 'QRIS' ? _buildQrisView() : _buildEwalletView(),
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF064E3B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isProcessing 
            ? null 
            : () async {
                setState(() => _isProcessing = true);

                try {
                  final int menuId = widget.menuData['id'];

                  // 1. Cek stok terakhir
                  final cekData = await supabase.from('menus').select('stok').eq('id', menuId).single();
                  final int stokRealTime = cekData['stok'] ?? 0;

                  if (stokRealTime >= widget.quantity) {
                    // 2. Potong stok HANYA saat tombol ini ditekan
                    await supabase
                        .from('menus')
                        .update({'stok': stokRealTime - widget.quantity})
                        .eq('id', menuId);

                    // 3. Catat riwayat pesanan HANYA saat tombol ini ditekan
                    final userId = supabase.auth.currentUser!.id;
                    await supabase.from('riwayat_pesanan').insert({
                      'user_id': userId,
                      'nama_makanan': widget.menuName,
                      'total_harga': widget.totalAmount,
                      'metode_pembayaran': widget.paymentMethod,
                    });

                    // 4. Lanjut ke layar tiket
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TicketScreen(menuName: widget.menuName)),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Maaf, stok sudah tidak mencukupi!'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memproses: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                  }
                }
              },
          child: _isProcessing 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Simulasikan Pembayaran Berhasil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildQrisView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Scan QR Code berikut', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Total: Rp ${formatRp(widget.totalAmount)}', style: const TextStyle(fontSize: 18, color: Color(0xFF064E3B), fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.qr_code_2, size: 220, color: Colors.black87), 
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(color: Color(0xFF064E3B)),
        const SizedBox(height: 16),
        const Text('Menunggu konfirmasi pembayaran...', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildEwalletView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF064E3B)),
        const SizedBox(height: 32),
        Text('Membuka aplikasi ${widget.paymentMethod}...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Silakan selesaikan pembayaran di dalam aplikasi e-wallet Anda.', 
          textAlign: TextAlign.center, 
          style: TextStyle(color: Colors.grey, height: 1.5)
        ),
      ],
    );
  }
}