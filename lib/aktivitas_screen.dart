import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _riwayat = [];
  bool _isLoading = true;
  String _roleUser = 'customer';

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      
      final userData = await supabase.from('users').select('role').eq('id', userId).single();
      _roleUser = userData['role'] ?? 'customer';

      List<dynamic> data;

      if (_roleUser == 'admin') {
        data = await supabase
            .from('riwayat_pesanan')
            .select()
            .order('created_at', ascending: false);
      } else {
        data = await supabase
            .from('riwayat_pesanan')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      }

      setState(() {
        _riwayat = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Error fetch riwayat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  String formatTanggal(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_roleUser == 'admin' ? 'Semua Pesanan Masuk' : 'Riwayat Pesanan', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF064E3B)))
          : _riwayat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        _roleUser == 'admin' ? 'Belum ada pesanan masuk' : 'Belum ada aktivitas',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _roleUser == 'admin' ? 'Transaksi dari pelanggan akan muncul di sini.' : 'Pesanan yang kamu selesaikan akan muncul di sini.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _riwayat.length,
                  itemBuilder: (context, index) {
                    final item = _riwayat[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      shadowColor: Colors.black.withOpacity(0.1),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.fastfood, color: Color(0xFF064E3B), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_makanan'] ?? 'Pesanan',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Metode: ${item['metode_pembayaran']}',
                                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item['created_at'] != null)
                                    Text(
                                      formatTanggal(item['created_at']),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${formatRp(item['total_harga'] ?? 0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF064E3B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}