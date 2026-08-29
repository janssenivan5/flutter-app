# LuxeBite 🍔♻️

LuxeBite adalah aplikasi *mobile* berbasis Flutter yang bertujuan untuk mengurangi *food waste* dengan menghubungkan jaringan restoran/hotel dengan pelanggan. Pengguna dapat "menyelamatkan" makanan sisa berkualitas tinggi di penghujung hari dengan harga diskon, sementara pihak restoran dapat meminimalisir kerugian dan dampak lingkungan.

Proyek ini dibangun sebagai Final Project untuk **Bootcamp Calon Praetorian 2026**.

## 🌟 Fitur Utama

Aplikasi ini menggunakan pendekatan *Role-Based Access Control* (RBAC) dengan dua entitas utama:

### 👤 Customer (Pelanggan)
* **Autentikasi & Validasi:** Mendaftar dan masuk menggunakan Supabase Auth dengan validasi input (minimal karakter, format email, dan kecocokan *password*).
* **Hotel Selection:** Sistem *routing* yang mengarahkan pengguna baru ke daftar mitra hotel terdekat sebelum melihat menu.
* **Katalog Makanan (Read):** Menelusuri daftar makanan yang tersedia secara *real-time* dari *database*.
* **Sistem Checkout Terintegrasi:** 
  * Perhitungan subtotal, biaya layanan, biaya platform, dan diskon promo.
  * Simulasi pembayaran via QRIS, GoPay, dan OVO lengkap dengan sistem validasi batas saldo dompet digital.
* **Riwayat Pesanan:** Memantau seluruh aktivitas transaksi pribadi.
* **Manajemen Profil (Update):** Memperbarui data diri (nama, kontak) secara langsung ke *database*.

### 👨‍🍳 Admin (Pengelola Restoran)
* **Registrasi Jalur Khusus:** Penggunaan kode rahasia (`LUXE2026`) saat *sign-up* untuk otomatis menetapkan peran sebagai admin.
* **Manajemen Inventaris (Create, Update, Delete):** 
  * Menambah makanan baru beserta detail harga dan stok.
  * Mengunggah gambar menu secara dinamis menggunakan **Supabase Storage**.
  * Menghapus atau memperbarui stok item yang sudah kedaluwarsa.
* **Global Activity Dashboard:** Memantau seluruh pesanan masuk dari berbagai pelanggan secara *real-time*, lengkap dengan identitas pembeli dan detail transaksi.

## 🛠️ Teknologi yang Digunakan

* **Frontend:** Flutter & Dart
* **Backend & Database:** Supabase (PostgreSQL - Network Database)
* **Autentikasi:** Supabase Auth
* **Penyimpanan Berkas:** Supabase Storage
* **State Management:** Native Flutter State (`setState`)
* **UI/UX & Animasi:** `flutter_animate` untuk transisi halaman dan elemen visual.

## 🚀 Panduan Instalasi & Menjalankan Proyek

1. **Clone repository ini:**
   ```bash
   git clone [https://github.com/janssenivan5/flutter-app.git](https://github.com/janssenivan5/flutter-app.git)