class HijriDateConverter {
  int iTanggalM = 0;
  int iTanggalH = 0;
  int iBulanM = 0;
  int iBulanH = 0;
  int iTahunM = 0;
  int iTahunH = 0;
  int iTahunJ = 0;
  late String sHariE;
  late String sBulanE;
  late String sBulanH;
  late String sHariJ;
  late String sPasaran;
 

  final namaBulanE = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    final namaBulanH = [
      "Muharram",
      "Safar",
      "Rabi Al-Awwal",
      "Rabi Al-Thani",
      "Jumada Al-Ula",
      "Jumada Al-Thani",
      "Rajab",
      "Shaban",
      "Ramadan",
      "Shawwal",
      "Dhul Qada",
      "Dhul Hijja"
    ];
    final namaHariE = [
      "Kamis",
      "Jumat",
      "Sabtu",
      "Ahad",
      "Senin",
      "Selasa",
      "Rabu"
    ];
    final namaPasaran = [
      "Wage", 
      "Kliwon", 
      "Legi", 
      "Pahing", 
      "Pon"
      ];

  int intPart(double floatNum) {
    return (floatNum < -0.0000001
        ? floatNum.ceil()
        : floatNum.floor());
  }

  void hitungHijriah(int d, int m, int y) {
    final mPart = (m - 13) / 12;
    final jd = intPart((1461 * (y + 4800 + intPart(mPart))) / 4) +
        intPart((367 * (m - 1 - 12 * intPart(mPart))) / 12) -
        intPart((3 * intPart((y + 4900 + intPart(mPart)) / 100)) / 4) +
        d -
        32075;
    var l = jd - 1948440 + 10632;
    final n = intPart((l - 1) / 10631);
    l = l - 10631 * n + 354;
    final j = (intPart((10985 - l) / 5316)) *
            (intPart((50 * l) / 17719)) +
        (intPart(l / 5670)) *
            (intPart((43 * l) / 15238));
    l = l -
        (intPart((30 - j) / 15)) *
            (intPart((17719 * j) / 50)) -
        (intPart(j / 16)) *
            (intPart((15238 * j) / 43)) +
        29;
    iBulanH = intPart((24 * l) / 709);
    iTanggalH = l - intPart((709 * iBulanH) / 24);

    final tambahan = 1; // Adjust date, typically -1, 0, +1

    iTanggalH += tambahan;
    iBulanH -= 1;
    if (iTanggalH > 30) {
      iTanggalH -= 30;
      iBulanH += 1;
    }
    iTahunH = 30 * n + j - 30;
  }

  void hitungTanggal() {
    final now = DateTime.now();
    iTanggalM = now.day;
    iBulanM = now.month - 1; // Dart's month is 1-based
    iTahunM = now.year;

    hitungHijriah(iTanggalM, iBulanM, iTahunM);

    final hr = DateTime.utc(iTahunM, iBulanM + 1, iTanggalM)
            .millisecondsSinceEpoch ~/
        1000 ~/
        60 ~/
        60 ~/
        24;

    iTahunJ = iTahunH + 512;
    sHariE = namaHariE[hr % 7];
    sBulanE = namaBulanE[iBulanM];
    sBulanH = namaBulanH[iBulanH];
    sHariJ = namaPasaran[hr%5];
    sPasaran = "$sHariE $sHariJ";
    /*
    switch (format) {
      case 2:
        return "$sHariE, $iTanggalM $sBulanE $iTahunM";
      case 5:
        return "$sHariE $sHariJ, $iTanggalH $sBulanH $iTahunH H";
      default:
        return "$sHariE, $iTanggalM $sBulanE $iTahunM";
    } */
  }
}