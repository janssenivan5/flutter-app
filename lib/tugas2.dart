abstract class Manusia {
  String _nama;
  Manusia(this._nama);
  String get nama => _nama;
  void kegiatan();
}

class Mahasiswa extends Manusia {
  Mahasiswa(String nama) : super(nama);
  @override
  void kegiatan() {
    print("Halo, nama saya $nama. Saya sedang belajar koding.");
  }
}

class Dosen extends Manusia {
  Dosen(String nama) : super(nama);
  @override
  void kegiatan() {
    print("Halo, saya $nama. Saya sedang mengajar kelas.");
  }
}

void main() {
  Mahasiswa mhs = Mahasiswa("Janssen Ivan");
  Dosen dsn = Dosen("Pak Budi");

  mhs.kegiatan();
  dsn.kegiatan();
}