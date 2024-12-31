class HijriDateConverter {
  int iTanggalM = 0;
  int iTanggalH = 0;
  int iBulanM = 0;
  int iBulanH = 0;
  int iTahunM = 0;
  int iTahunH = 0;
  int iTahunJ = 0;

  String sHariE = '';
  String sBulanE = '';
  String sBulanH = '';
  String sHariJ = '';
  String sPasaran = '';

  static const List<String> namaBulanE = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  static const List<String> namaBulanH = [
    "Muharram", "Safar", "Rabiulawal", "Rabiulakhir",
    "Jumadiawal", "Jumadilakhir", "Rajab", "Syakban",
    "Ramadan", "Syawwal", "Zulkaidah", "Zulhijah"
  ];

  static const List<String> namaHariE = ["Kamis", "Jumat", "Sabtu", "Ahad", "Senin", "Selasa", "Rabu"];
  static const List<String> namaPasaran = ["Wage", "Kliwon", "Legi", "Pahing", "Pon"];

  // Constructor to initialize and calculate the current Hijri date
  HijriDateConverter() {
    final now = DateTime.now();
    iTanggalM = now.day;
    iBulanM = now.month - 1; // Adjust for zero-based month index
    iTahunM = now.year;

    hitungHijriah(iTanggalM, iBulanM, iTahunM);
    _calculateField();
    
  }

  HijriDateConverter.fromMasehi(int dd,int mm, int yy){
    iTanggalM = dd;
    iBulanM = mm - 1; // Adjust for zero-based month index
    iTahunM = yy;

    hitungHijriah(iTanggalM, iBulanM, iTahunM);
    _calculateField();
  }

  void _calculateField(){
    final hr = DateTime.utc(iTahunM, iBulanM + 1 , iTanggalM)
            .millisecondsSinceEpoch ~/
        1000 ~/
        60 ~/
        60 ~/
        24;

    iTahunJ = iTahunH + 512;
    sHariE = namaHariE[hr % 7];
    sBulanE = namaBulanE[iBulanM];
    sBulanH = namaBulanH[iBulanH % 12];
    sHariJ = namaPasaran[hr % 5];
    sPasaran = "$sHariE $sHariJ";
  }

  // Helper method to calculate Hijri date based on Gregorian date
  int intPart(double num) => num < -0.0000001 ? num.ceil() : num.floor();

  void hitungHijriah(int d, int m, int y) {
    final mPart = (m - 13) / 12;
    final jd = intPart((1461 * (y + 4800 + intPart(mPart))) / 4) +
        intPart((367 * (m - 1 - 12 * intPart(mPart))) / 12) - 
        intPart((3 * intPart((y + 4900 + intPart(mPart)) / 100)) / 4) +
        d - 32075;

    var l = jd - 1948440 + 10632;
    final n = intPart((l - 1) / 10631);
    l = l - 10631 * n + 354;

    final j = (intPart((10985 - l) / 5316)) * (intPart((50 * l) / 17719)) +
        (intPart(l / 5670)) * (intPart((43 * l) / 15238));

    l = l - intPart((30 - j) / 15) * intPart((17719 * j) / 50) -
        intPart(j / 16) * intPart((15238 * j) / 43) + 29;

    iBulanH = intPart((24 * l) / 709);
    iTanggalH = l - intPart((709 * iBulanH) / 24);
    
    final tambahan = 1; // Adjust date, typically -1, 0, +1

    iTanggalH += tambahan;
    iBulanH -= 1;
    // Adjustments
    
    if (iTanggalH > 30) {
      iTanggalH -= 30;
      iBulanH += 1;
    }
    iTahunH = 30 * n + j - 30;
  }

  // Method to return today's date as Hijri
  static HijriDateConverter now() {
    return HijriDateConverter();
  }

  
  // Override toString() to provide a custom string format
  @override
  String toString() {
    return '$sPasaran, $iTanggalH $sBulanH $iTahunH / $iTanggalM ${namaBulanE[iBulanM]} $iTahunM ';
  }


}
/*
void main() {
  // Get the current Hijri date by calling the now() method
  final converter = HijriDateConverter.now();

  // Print the current date in both Gregorian and Hijri formats
  print(converter.toString());
}
*/