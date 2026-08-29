import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; 
import 'checkout_screen.dart';

// PENERAPAN OOP: Class Model untuk Menu 
class Menu {
  int id;
  String namaMakanan;
  String deskripsi;
  int harga;
  int stok; 
  String imageUrl;

  Menu({
    required this.id,
    required this.namaMakanan,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.imageUrl,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      namaMakanan: json['nama_makanan'] ?? 'Tanpa Nama',
      deskripsi: json['deskripsi'] ?? '-',
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0, 
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'nama_makanan': namaMakanan,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok, 
      'image_url': imageUrl,
    };
  }
}

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> menuData;
  final String role;

  const DetailScreen({super.key, required this.menuData, required this.role});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final supabase = Supabase.instance.client;
  late Menu _menu; 
  late TextEditingController _quickStockCtrl; 
  int _quantity = 1; // KUNCI UTAMA: Menyimpan jumlah pesanan

  @override
  void initState() {
    super.initState();
    _menu = Menu.fromJson(widget.menuData); 
    _quickStockCtrl = TextEditingController(text: _menu.stok.toString());
  }

  @override
  void dispose() {
    _quickStockCtrl.dispose();
    super.dispose();
  }

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  Future<void> _editItem() async {
    final nameCtrl = TextEditingController(text: _menu.namaMakanan);
    final descCtrl = TextEditingController(text: _menu.deskripsi);
    final priceCtrl = TextEditingController(text: _menu.harga.toString());
    final imageCtrl = TextEditingController(text: _menu.imageUrl);
    bool isUploading = false; 

    final bool? isSubmitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Makanan')),
                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
                      TextField(
                        controller: priceCtrl, 
                        decoration: const InputDecoration(labelText: 'Harga'), 
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: imageCtrl, 
                        decoration: InputDecoration(
                          labelText: 'URL Gambar',
                          suffixIcon: isUploading 
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16, height: 16, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF064E3B)),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.upload_file, color: Color(0xFF064E3B)),
                                tooltip: 'Upload dari perangkat',
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                  
                                  if (image != null) {
                                    setStateDialog(() => isUploading = true);
                                    try {
                                      final bytes = await image.readAsBytes();
                                      final fileExt = image.name.split('.').last;
                                      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                                      
                                      await supabase.storage.from('menus').uploadBinary(
                                        fileName, 
                                        bytes,
                                        fileOptions: const FileOptions(upsert: true),
                                      );
                                      
                                      final String publicUrl = supabase.storage.from('menus').getPublicUrl(fileName);
                                      
                                      setStateDialog(() {
                                        imageCtrl.text = publicUrl;
                                        isUploading = false;
                                      });
                                    } catch (e) {
                                      setStateDialog(() => isUploading = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
                                      }
                                    }
                                  }
                                },
                              ),
                        ), 
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), 
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
                  onPressed: isUploading ? null : () => Navigator.pop(context, true), 
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );

    if (isSubmitted != true) return; 

    setState(() {
      _menu.namaMakanan = nameCtrl.text;
      _menu.deskripsi = descCtrl.text;
      _menu.harga = int.tryParse(priceCtrl.text) ?? 0;
      _menu.imageUrl = imageCtrl.text;
    });

    try {
      await supabase.from('menus').update(_menu.toJson()).eq('id', _menu.id);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Berhasil'),
              ],
            ),
            content: const Text('Data menu berhasil diperbarui!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color(0xFF064E3B))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  Future<void> _updateStockOnly() async {
    final int newStock = int.tryParse(_quickStockCtrl.text) ?? 0;
    
    try {
      await supabase.from('menus').update({'stok': newStock}).eq('id', _menu.id);
      setState(() {
        _menu.stok = newStock;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui stok: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan _quantity tidak melebihi stok jika stok tiba-tiba berubah
    if (_quantity > _menu.stok && _menu.stok > 0) {
      _quantity = _menu.stok;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(color: Colors.white)),
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
        actions: [
          if (widget.role == 'admin')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editItem,
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, {'id': _menu.id, ..._menu.toJson()});
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), 
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, 
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Image.network(
                      _menu.imageUrl,
                      width: double.infinity,
                      height: 280, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 280,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _menu.namaMakanan,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _menu.stok > 0 ? 'Sisa Stok: ${_menu.stok}' : 'Stok Habis',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _menu.stok > 0 ? Colors.orange[800] : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Rp ${formatRp(_menu.harga)}',
                            style: const TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF064E3B)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _menu.deskripsi,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                    ),
                    
                    const SizedBox(height: 8), 
                    
                    // TAMPILAN KHUSUS CUSTOMER (Pemilihan Jumlah & Tombol Beli)
                    if (widget.role != 'admin')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          children: [
                            // === TOMBOL PLUS MINUS JUMLAH PESANAN ===
                            if (_menu.stok > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Jumlah Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                          child: IconButton(
                                            icon: const Icon(Icons.remove, color: Color(0xFF064E3B)),
                                            onPressed: _quantity > 1 
                                              ? () => setState(() => _quantity--) 
                                              : null,
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                          child: IconButton(
                                            icon: const Icon(Icons.add, color: Color(0xFF064E3B)),
                                            onPressed: _quantity < _menu.stok 
                                              ? () => setState(() => _quantity++) 
                                              : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            
                            // === TOMBOL LANJUT PEMBAYARAN ===
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _menu.stok > 0 ? const Color(0xFFD4AF37) : Colors.grey,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _menu.stok > 0 
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckoutScreen(
                                            menuData: _menu.toJson(),
                                            quantity: _quantity, // MENGIRIM JUMLAH KE CHECKOUT
                                            onPaymentSuccess: () {
                                              if (mounted) {
                                                setState(() {
                                                  if (_menu.stok >= _quantity) {
                                                    _menu.stok -= _quantity; // Potong sesuai kuantitas
                                                    _quantity = 1; // Reset jumlah ke 1 kembali
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  : null, 
                                child: Text(
                                  _menu.stok > 0 ? 'Lanjut ke Pembayaran' : 'Stok Habis',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // TAMPILAN KHUSUS ADMIN (Stepper Update Stok Cepat)
                    if (widget.role == 'admin')
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Text('Atur Stok Tersedia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                  child: IconButton(
                                    icon: const Icon(Icons.remove, color: Color(0xFF064E3B)),
                                    onPressed: () {
                                      int current = int.tryParse(_quickStockCtrl.text) ?? 0;
                                      if (current > 0) {
                                        _quickStockCtrl.text = (current - 1).toString();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: _quickStockCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF064E3B)),
                                    onPressed: () {
                                      int current = int.tryParse(_quickStockCtrl.text) ?? 0;
                                      _quickStockCtrl.text = (current + 1).toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF064E3B),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _updateStockOnly,
                                child: const Text('Simpan Stok', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
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
      ),
    );
  }
}