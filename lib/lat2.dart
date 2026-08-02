class Mobil {
  String merk = "toyota";
  int kecepatan = 80;
  String jenis = "sedan";

  void jalan() {
    print("jalan maksimal kecepatan $kecepatan");
  }

  void identitas() {
    print("identitas $merk");
  }
}

void main() {
  final car = Mobil();
  car.jalan();
}