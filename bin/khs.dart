import 'dart:io';

typedef MataKuliah = ({String nama, int sks, String nilai, int bobot});

// Mengubah nilai huruf menjadi bobot angka.
int bobot(String huruf) {
  const Map<String, int> skala = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'E': 0};

  final hasil = skala[huruf.toUpperCase()];

  if (hasil == null) {
    throw FormatException('Nilai harus A, B, C, D, atau E.');
  }

  return hasil;
}

// Memvalidasi SKS dan nilai, lalu membuat data mata kuliah.
MataKuliah validasi(String nama, String teksSks, String teksNilai) {
  final int? sks = int.tryParse(teksSks.trim());

  if (sks == null || sks < 1 || sks > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$teksSks".');
  }

  final String nilai = teksNilai.trim().toUpperCase();
  final int nilaiBobot = bobot(nilai);

  return (nama: nama.trim(), sks: sks, nilai: nilai, bobot: nilaiBobot);
}

// Menghitung IP dengan higher-order function fold.
double hitungIp(List<MataKuliah> data) {
  if (data.isEmpty) {
    return 0;
  }

  final int totalSks = data.fold<int>(0, (total, mk) => total + mk.sks);

  final int totalBobot = data.fold<int>(
    0,
    (total, mk) => total + (mk.sks * mk.bobot),
  );

  return totalBobot / totalSks;
}

// Menentukan predikat berdasarkan IP.
String predikat(double ip) {
  if (ip >= 3.50) {
    return 'Dengan Pujian';
  } else if (ip >= 3.00) {
    return 'Sangat Memuaskan';
  } else if (ip >= 2.00) {
    return 'Memuaskan';
  } else if (ip > 0) {
    return 'Perlu Peningkatan';
  }

  return 'Belum ada nilai';
}

// Mencetak KHS, opsional diurutkan dari bobot tertinggi.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  final List<MataKuliah> daftarCetak = [...data];

  if (urutkan) {
    daftarCetak.sort((a, b) => b.bobot.compareTo(a.bobot));
  }

  print('\n================ KARTU HASIL STUDI ================');
  print(
    '${'Mata Kuliah'.padRight(28)}'
    '${'SKS'.padLeft(5)}'
    '${'Nilai'.padLeft(8)}',
  );
  print('-' * 41);

  for (final mk in daftarCetak) {
    print(
      '${mk.nama.padRight(28)}'
      '${mk.sks.toString().padLeft(5)}'
      '${mk.nilai.padLeft(8)}',
    );
  }

  print('-' * 41);

  final int totalSks = data.fold<int>(0, (total, mk) => total + mk.sks);

  final double ip = hitungIp(data);

  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)} (${predikat(ip)})');

  // where memilih mata kuliah yang bobotnya kurang dari 2.
  final perluDiperbaiki = data.where((mk) => mk.bobot < 2);

  print('\nPerlu diperbaiki:');

  if (perluDiperbaiki.isEmpty) {
    print('Tidak ada. Pertahankan prestasimu!');
  } else {
    for (final mk in perluDiperbaiki) {
      print('- ${mk.nama}');
    }
  }

  print('====================================================');
}

void main() {
  final List<MataKuliah> data = [];

  print('KALKULATOR IP SEMESTER');
  print('Kosongkan nama mata kuliah untuk selesai.');

  while (true) {
    stdout.write('\nNama MK : ');
    final String nama = stdin.readLineSync() ?? '';

    if (nama.trim().isEmpty) {
      break;
    }

    try {
      stdout.write('SKS     : ');
      final String teksSks = stdin.readLineSync() ?? '';

      stdout.write('Nilai   : ');
      final String teksNilai = stdin.readLineSync() ?? '';

      final MataKuliah mk = validasi(nama, teksSks, teksNilai);

      data.add(mk);
      print('Data mata kuliah berhasil ditambahkan.');
    } on FormatException catch (e) {
      print('Data diabaikan: ${e.message}');
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  if (data.isEmpty) {
    print('\nBelum ada data mata kuliah yang valid.');
    return;
  }

  stdout.write('\nUrutkan dari nilai tertinggi? (y/n): ');
  final String pilihan = (stdin.readLineSync() ?? '').trim().toLowerCase();

  cetakKhs(data, urutkan: pilihan == 'y');
}
