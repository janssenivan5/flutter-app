import 'package:flutter/material.dart';
import 'payment_process_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'QRIS'; 
  String _promoText = 'Makin hemat pakai promo!';
  int _discount = 0;
  final int _subtotal = 35000;
  final int _serviceFee = 2000;
  final int _platformFee = 1000;

  int get _totalPrice => (_subtotal + _serviceFee + _platformFee) - _discount;

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  void _showPromoModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Promo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.local_offer, color: Color(0xFFD4AF37)),
                title: const Text('Diskon Mahasiswa Akhir Bulan'),
                subtitle: const Text('Potongan Rp 10.000'),
                onTap: () {
                  setState(() {
                    _promoText = 'Diskon Mahasiswa (-Rp 10.000)';
                    _discount = 10000;
                  });
                  Navigator.pop(context); 
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_offer, color: Color(0xFFD4AF37)),
                title: const Text('Promo Pengguna Baru'),
                subtitle: const Text('Potongan Rp 5.000'),
                onTap: () {
                  setState(() {
                    _promoText = 'Pengguna Baru (-Rp 5.000)';
                    _discount = 5000;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('Rangkuman Pesanan', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF064E3B), 
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Text('Rp ${formatRp(_subtotal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: _showPromoModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _discount > 0 ? const Color(0xFFFFF8E1) : Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _promoText, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: _discount > 0 ? const Color(0xFF064E3B) : Colors.black87
                          )
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildPaymentOption('QRIS', 'Scan barcode dari bank apa saja', 'QRIS', Icons.qr_code_scanner, Colors.blue),
                    const Divider(height: 1, indent: 50, endIndent: 16),
                    _buildPaymentOption('GoPay', 'Saldo: Rp 150.000', 'GoPay', Icons.account_balance_wallet, Colors.green),
                    const Divider(height: 1, indent: 50, endIndent: 16),
                    _buildPaymentOption('OVO', 'Saldo: Rp 45.000', 'OVO', Icons.toll, Colors.purple),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Subtotal', style: TextStyle(color: Colors.grey)), Text('Rp ${formatRp(_subtotal)}')],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Biaya Layanan', style: TextStyle(color: Colors.grey)), Text('Rp ${formatRp(_serviceFee)}')],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Biaya Platform', style: TextStyle(color: Colors.grey)), Text('Rp ${formatRp(_platformFee)}')],
                    ),
                    
                    if (_discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diskon Promo', style: TextStyle(color: Colors.green)), 
                          Text('-Rp ${formatRp(_discount)}', style: const TextStyle(color: Colors.green))
                        ],
                      ),
                    ],

                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Rp ${formatRp(_totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF064E3B))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF064E3B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentProcessScreen(
                  paymentMethod: _selectedPayment,
                  totalAmount: _totalPrice,
                ),
              ),
            );
          },
          child: Text('Bayar Rp ${formatRp(_totalPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, String value, IconData icon, Color iconColor) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = value; 
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            Icon(
              _selectedPayment == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _selectedPayment == value ? const Color(0xFF064E3B) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}