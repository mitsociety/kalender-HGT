import "package:intl/intl.dart";
import "package:khgt/utils/khgt/hijriconverter.dart";
import "package:khgt/utils/khgt/khgt_dat.dart";

class MuhDateTime {
  int hijriYear;
  int iMonth;
  int iDay;
  int hour;
  int minute;
  int second;

  late String monthName;
  late String startingDay;
  late DateTime startingDate;
  late int daysInMonth;
  late String pasar;

  MuhDateTime({
    required this.hijriYear,
    required this.iMonth,
    required this.iDay,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  }) {
    initializeHijriDate(hijriYear,iMonth,iDay);
  }

  // Convert date string to DateTime
  DateTime convDate(String tanggal) {
    try {
      DateFormat dateFormat = DateFormat("dd-MMM-yy");
      return dateFormat.parse(tanggal);
    } catch (e) {
      throw FormatException("Invalid date format: $tanggal");
    }
  }

  // Initialize Hijri date properties
  void initializeHijriDate(int yh, int mh,int dh) {
    //debugPrint(mh.toString());
    if (data.containsKey(yh)) {
      // Access the months of the year
      int mm = mh;
      List<List<dynamic>> months = data[yh]!;
      List<dynamic> monthData = months[mm];

      monthName = monthData[0];
      startingDay = monthData[1];
      startingDate = convDate(monthData[2]);
      daysInMonth = monthData[3];
    } else {
      throw ArgumentError("Year $yh not found in data.");
    }
    pasar = getPasaran(startingDate.year,startingDate.month, startingDate.day);
  }

  String getPasaran(int yy, int mm,int dd){
    HijriDateConverter myconverter = HijriDateConverter.fromMasehi(dd, mm, yy);

    //myconverter.hitungHijriah(dd, mm, yy);
    return  myconverter.sHariJ;
  }
  // Add days to the current date
  void addDays(int days) {
    DateTime current = startingDate.add(Duration(days: days));
    updateHijriFromDateTime(current);
  }

  // Subtract days from the current date
  void subtractDays(int days) {
    DateTime current = startingDate.subtract(Duration(days: days));
    updateHijriFromDateTime(current);
  }

  // Update Hijri properties from a DateTime object
  void updateHijriFromDateTime(DateTime date) {
    // Update the date details based on the input date
    iDay = date.day;
    iMonth = date.month;
    hijriYear = date.year;

    // Re-initialize month data
    initializeHijriDate(hijriYear, iMonth,iDay);
  }

}
