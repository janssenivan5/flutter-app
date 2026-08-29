import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart'; 
import 'detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdminMode; // Parameter pembeda mode
  const HomeScreen({super.key, this.isAdminMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _menus = [];
  String _roleUser = 'customer';
  String _namaUser = 'Memuat...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final userData = await supabase.from('users').select().eq('id', userId).single();
      final menuData = await supabase.from('menus').select();

      setState(() {
        _roleUser = userData['role'] ?? 'customer';
        _namaUser = userData['nama_lengkap'] ?? 'Admin';
        _menus = List<Map<String, dynamic>>.from(menuData);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addItem() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(); 
    final imageCtrl = TextEditingController(); 
    bool isUploading = false; 

    final bool? isSubmitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Menu Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, 
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Makanan')),
                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi singkat')),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: priceCtrl, 
                              decoration: const InputDecoration(labelText: 'Harga'), 
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: stockCtrl, 
                              decoration: const InputDecoration(labelText: 'Stok'), 
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageCtrl, 
                        decoration: InputDecoration(
                          labelText: 'URL Gambar',
                          hintText: 'Paste link atau pilih dari perangkat',
                          hintStyle: const TextStyle(fontSize: 12),
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

    const defaultImage = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60';

    final newItemData = {
      'nama_makanan': nameCtrl.text.isEmpty ? 'Menu Tanpa Nama' : nameCtrl.text,
      'deskripsi': descCtrl.text.isEmpty ? 'Tanpa deskripsi' : descCtrl.text,
      'harga': int.tryParse(priceCtrl.text) ?? 0, 
      'stok': int.tryParse(stockCtrl.text) ?? 0, 
      'image_url': imageCtrl.text.isEmpty ? defaultImage : imageCtrl.text, 
    };

    try {
      final savedItem = await supabase.from('menus').insert(newItemData).select().single();

      setState(() {
        _menus.add(savedItem);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah: $e')));
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final itemToDelete = _menus[index];
    final int targetId = itemToDelete['id'];

    setState(() {
      _menus.removeAt(index);
    });

    try {
      await supabase.from('menus').delete().eq('id', targetId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item berhasil dihapus!')));
      }
    } catch (e) {
      setState(() {
        _menus.insert(index, itemToDelete);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  String formatRp(int number) {
    return number.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        // Logika dinamis: Jika admin, tampilkan sapaan. Jika tidak, tampilkan "Daftar Menu"
        title: widget.isAdminMode 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $_namaUser!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('Siap mengelola makanan hari ini?', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            )
          : const Text('Daftar Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        automaticallyImplyLeading: !widget.isAdminMode, // Hilangkan tombol back jika admin
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF064E3B), Color(0xFF1B5E20)],
            ),
          ),
        ),
        actions: widget.isAdminMode
          ? [
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
            ]
          : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tersedia Hari Ini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF064E3B)))
                : _menus.isEmpty 
                  ? const Center(child: Text('Yah, belum ada makanan sisa saat ini.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _menus.length,
                      itemBuilder: (context, index) {
                        final item = _menus[index];
                        return _buildBagCard(item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _roleUser == 'admin' 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFFD4AF37),
            onPressed: _addItem,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildBagCard(Map<String, dynamic> item, int index) {
    final imageUrl = item['image_url'] ?? 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60';
    final int stok = item['stok'] ?? 0; 

    return InkWell(
      onTap: () async {
        final updatedItem = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              menuData: item, 
              role: _roleUser, 
            ),
          ),
        );

        if (updatedItem != null) {
          setState(() {
            _menus[index] = updatedItem;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                if (_roleUser == 'admin') 
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _deleteItem(index), 
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama_makanan'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stok > 0 ? 'Sisa Stok: $stok' : 'Stok Habis', 
                    style: TextStyle(
                      color: stok > 0 ? Colors.orange[800] : Colors.red, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${formatRp(item['harga'] ?? 0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fade(duration: 500.ms, delay: (index * 100).ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut); 
  }
}