import 'package:flutter/material.dart';
import 'ticket_screen.dart';

class PaymentProcessScreen extends StatelessWidget {
  final String paymentMethod;
  final int totalAmount;

  const PaymentProcessScreen({
    super.key,
    required this.paymentMethod,
    required this.totalAmount,
  });

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pembayaran $paymentMethod', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF064E3B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: paymentMethod == 'QRIS' ? _buildQrisView() : _buildEwalletView(),
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TicketScreen()),
            );
          },
          child: const Text('Simulasikan Pembayaran Berhasil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        Text('Total: Rp ${formatRp(totalAmount)}', style: const TextStyle(fontSize: 18, color: Color(0xFF064E3B), fontWeight: FontWeight.bold)),
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
        Text('Membuka aplikasi $paymentMethod...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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