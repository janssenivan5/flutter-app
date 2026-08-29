import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_process_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> menuData;
  final int quantity;
  final VoidCallback? onPaymentSuccess; 
  
  const CheckoutScreen({
    super.key, 
    required this.menuData, 
    this.quantity = 1, 
    this.onPaymentSuccess
  });
  
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final supabase = Supabase.instance.client; 
  
  String _selectedPayment = 'QRIS'; 
  String _promoText = 'Makin hemat pakai promo!';
  int _discount = 0;
  final int _serviceFee = 2000;
  final int _platformFee = 1000;

  final int _gopayBalance = 150000;
  final int _ovoBalance = 45000;

  int get _subtotal => (widget.menuData['harga'] ?? 0) * widget.quantity;
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

  void _showInsufficientBalancePopup(String wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Saldo Tidak Cukup'),
          ],
        ),
        content: Text('Saldo $wallet kamu tidak mencukupi untuk transaksi ini. Silakan gunakan metode pembayaran lain.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF064E3B))),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.menuData['image_url'] ?? 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('Rangkuman Pesanan', style: TextStyle(color: Colors.white, fontSize: 22)),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), 
          child: SingleChildScrollView(
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
                          child: Image.network(
                            imageUrl, 
                            width: 70, 
                            height: 70, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 70, height: 70, color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${widget.menuData['nama_makanan'] ?? 'Tanpa Nama'} (x${widget.quantity})', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                              const SizedBox(height: 4),
                              Text(widget.menuData['deskripsi'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                        _buildPaymentOption('GoPay', 'Saldo: Rp ${formatRp(_gopayBalance)}', 'GoPay', Icons.account_balance_wallet, Colors.green),
                        const Divider(height: 1, indent: 50, endIndent: 16),
                        _buildPaymentOption('OVO', 'Saldo: Rp ${formatRp(_ovoBalance)}', 'OVO', Icons.toll, Colors.purple),
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
            if (_selectedPayment == 'GoPay' && _totalPrice > _gopayBalance) {
              _showInsufficientBalancePopup('GoPay');
              return; 
            } else if (_selectedPayment == 'OVO' && _totalPrice > _ovoBalance) {
              _showInsufficientBalancePopup('OVO');
              return; 
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentProcessScreen(
                  paymentMethod: _selectedPayment,
                  totalAmount: _totalPrice,
                  menuName: '${widget.menuData['nama_makanan']} (x${widget.quantity})',
                  menuData: widget.menuData, 
                  quantity: widget.quantity, 
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