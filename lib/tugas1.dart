void main() {
  List<String> daftarGame = ["Valorant", "Mobile Legends", "Genshin Impact", "Dota 2"];
  List<int> hargaTopUp = [50000, 100000, 150000, 200000];

  print("DAFTAR GAME FAVORIT");
  print("Game paling sering dimainkan: ${daftarGame[0]}");
  print("Menampilkan seluruh isi list game:");
  print(daftarGame);

  print("\nINFORMASI TOP UP");
  print("Paket harga ke-2: Rp${hargaTopUp[1]}");
  print("Game ${daftarGame[1]} butuh biaya minimal Rp${hargaTopUp[0]}");
}