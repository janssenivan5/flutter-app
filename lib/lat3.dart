class Rekening {
  String nama;
  int saldo = 0;
  String bank = "bca";

  Rekening(this.nama);

  void namaBank() {
    print(bank);
  }

  void tambahSaldo(int saldoTambahan) {
    saldo += saldoTambahan;
    print(saldo);
  }
}

void main() {
  final rekeningSaya = Rekening("Janssen");
  rekeningSaya.tambahSaldo(10000);
}