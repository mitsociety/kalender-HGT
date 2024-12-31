import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Imsakiyah extends StatefulWidget {
  const Imsakiyah({super.key});

  @override
  State<Imsakiyah> createState() => _ImsakiyahState();
}

class _ImsakiyahState extends State<Imsakiyah> {
  late PrayerTimes prayerTimes;
  late DateTime date;
  late Duration selangWaktu;
  late String salatNext;
  late String subuh = "-";
  late String dhuhur = "-";
  late String ashar = "-";
  late String maghrib = "-";
  late String isya = "-";

  final List<String> bulan = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli",
    "Agustus", "September", "Oktober", "November", "Desember"
  ];

  final Map<String, String> namaSalat = {
  "subuh": "Subuh",
  "dhuhr": "Dhuhr",
  "asr": "Ashar",
  "maghrib": "Maghrib",
  "isha": "Isya",
  "fajrafter": "Subuh",
  "ishabefore": "Isya",
  "sunrise": "Terbit",
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getWaktuSalat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void getWaktuSalat() {
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Jakarta');
    date = tz.TZDateTime.from(DateTime.now(), location);

    Coordinates coordinates = Coordinates(-7.68717650, 110.34345210); //todo : set to user location
    CalculationParameters params = CalculationMethod.karachi();
    params.madhab = Madhab.shafi;

    prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    setState(() {
      salatNext = prayerTimes.nextPrayer(date: date) ?? "fajr";
      subuh = formatTime(prayerTimes.fajr, location);
      dhuhur = formatTime(prayerTimes.dhuhr, location);
      ashar = formatTime(prayerTimes.asr, location);
      maghrib = formatTime(prayerTimes.maghrib, location);
      isya = formatTime(prayerTimes.isha, location);

      final DateTime nextSalatTime =
          prayerTimes.timeForPrayer(salatNext)?.toLocal() ?? DateTime.now();
      final DateTime now = DateTime.now();
      selangWaktu = nextSalatTime.difference(now);

      _timer?.cancel();
      _timer = Timer(selangWaktu, getWaktuSalat);
    });
  }

  String formatTime(DateTime? time, tz.Location location) {
    if (time == null) return "-";
    return DateFormat('HH:mm').format(tz.TZDateTime.from(time, location));
  }

  Stream<String> jelangSalat() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final nextSalatTime =
          prayerTimes.timeForPrayer(salatNext)?.toLocal() ?? DateTime.now();
      final now = DateTime.now();
      final remaining = nextSalatTime.difference(now);
      yield detik2jam(remaining.inSeconds);
    }
  }

  String detik2jam(int seconds) {
    int jam = seconds ~/ 3600;
    int menit = (seconds % 3600) ~/ 60;
    int detik = seconds % 60;
    return "$jam : ${menit.toString().padLeft(2, '0')} : ${detik.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        children: [
          _remainNextSalah(salatNext),
          _imsakiyah(),
        ],
      ),
    );
  }

  Widget _remainNextSalah(String salah) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Salat Berikutnya:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 4,
            color: const Color.fromARGB(255, 255, 251, 5),
            margin: const EdgeInsets.all(8.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                namaSalat[salah]?.toUpperCase() ?? "-",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder(
            stream: jelangSalat(),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? "00:00:00");
            },
          ),
        ),
      ],
    );
  }

  Widget _imsakiyah() {
    return Card(
      elevation: 4,
      color: const Color.fromARGB(255, 2, 73, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Imsakiyah",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          buildPrayerTime("Subuh", subuh),
          buildPrayerTime("Dhuhr", dhuhur),
          buildPrayerTime("Ashar", ashar),
          buildPrayerTime("Maghrib", maghrib),
          buildPrayerTime("Isya", isya),
        ],
      ),
    );
  }

  Widget buildPrayerTime(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 18, color: Colors.white)),
          Text(time, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
