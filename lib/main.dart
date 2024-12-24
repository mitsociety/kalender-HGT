import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import 'package:khgt/utils/hijriconverter.dart';
import 'dart:async';
import "package:khgt/pages/calendar_khgt.dart";


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 14, 138, 21)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kalender Hijriyah Global Tunggal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List bulan = ["Januari","Februari",'Maret',"April","Mei","Juni","Juli","Agustus","September","Oktober","November","Desember"];
Map<String, dynamic> namaSalat = {
"subuh" : "subuh",
"dhuhr" : "duhur",
"asr" : "ashar",
"maghrib" : "maghrib",
"isha" : "isya",
};


class _MyHomePageState extends State<MyHomePage> {
  late PrayerTimes prayerTimes;
  late DateTime date;
  late Duration selangWaktu;
  late Timer timer;
  String salatNext = "";
  String subuh = "";
  String dhuhur = "";
  String ashar = "";
  String maghrib = "";
  String isya = "";
  String tanggal = "";
  late HijriDateConverter _converter; // = HijriDateConverter();

  @override
  void initState() {
    getWaktuSalat();
    getTanggal();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getTanggal(){
    _converter = HijriDateConverter();
    _converter.hitungTanggal();

  }

  void getWaktuSalat() {
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(location);
    //debugPrint(location.toString());

    // Definitions
    date = tz.TZDateTime.from(DateTime.now(), location);
    //debugPrint(date.toString());
    //DateTime date = DateTime.now();
    Coordinates coordinates = Coordinates(-7.68717650, 110.34345210);

    // Parameters
    CalculationParameters params = CalculationMethod.karachi();
    params.madhab = Madhab.shafi;

    prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true);
    //prayerTimes.asr;
    //debugPrint(DateFormat("d MMMM yyyy").format(prayerTimes.date));

    setState(() {
      //salatSkrg = prayerTimes.currentPrayer(date: date);
      salatNext = prayerTimes.nextPrayer(date: date);
      subuh = DateFormat('HH:mm')
          .format(tz.TZDateTime.from(prayerTimes.fajr!.toLocal(), location));
      dhuhur = DateFormat('HH:mm')
          .format(tz.TZDateTime.from(prayerTimes.dhuhr!.toLocal(), location));
      ashar = DateFormat('HH:mm')
          .format(tz.TZDateTime.from(prayerTimes.asr!.toLocal(), location));
      maghrib = DateFormat('HH:mm')
          .format(tz.TZDateTime.from(prayerTimes.maghrib!.toLocal(), location));
      isya = DateFormat('HH:mm')
          .format(tz.TZDateTime.from(prayerTimes.isha!.toLocal(), location));
      tanggal =
          "${prayerTimes.date.day} ${bulan[prayerTimes.date.month - 1]} ${prayerTimes.date.year}";
      //prayerTimes.fajr!.toLocal();
      //subuh = prayerTimes.date.toString();
      final DateTime wktSalatNext = prayerTimes.timeForPrayer(salatNext)!.toLocal();
      final DateTime wktSkrg = DateTime.now();
      final Duration selangSalat = wktSalatNext.difference(wktSkrg);

      Timer(selangSalat,(){
        getWaktuSalat();
      });
    });
  }

  jelangSalat() async* {
    yield* Stream.periodic(Duration(seconds: 1), (t) {
      String waktuSalat = prayerTimes.nextPrayer(date: date);
      DateTime nextSalat = prayerTimes.timeForPrayer(waktuSalat)!.toLocal();
      DateTime skrg = DateTime.now();
      selangWaktu = nextSalat.difference(skrg);
     
      //debugPrint(selangWaktu.inSeconds.toString());
      return detik2jam(selangWaktu.inSeconds);
    });
  }
  
  
  detik2jam(int seconds) {
    int menit = seconds ~/ 60;
    int jam = menit ~/ 60;
    seconds = seconds - menit * 60;
    menit = menit - jam * 60;
    return "$jam : $menit : $seconds";
  }

  //final HijriDateConverter _converter = HijriDateConverter();
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 570;
            return Row(
              children: [
                // Left Panel
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.green,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _converter.iTanggalH.toString(),
                          style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "${_converter.namaBulanH[_converter.iBulanH]} ${_converter.iTahunH} H",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                        
                        SizedBox(height: 10),
                       
                        Text(
                          _converter.sPasaran.toString() ,
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tanggal,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        StreamBuilder(
                            stream: jelangSalat(),
                            builder: (context, snapshot) {

                              return Text("${snapshot.data}");
                            }),
                        Text(
                          namaSalat[salatNext].toString().toUpperCase(),
                          style: TextStyle(fontSize: 26, color: Colors.yellow),
                        ),
                        SizedBox(height: 30),
                        SizedBox(height: 30),
                        Card(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          color: const Color.fromARGB(255, 2, 73, 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Imsakiyah",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: const Color.fromARGB(
                                          255, 245, 247, 245)),
                                ),
                              ),
                              buildPrayerTime("Subuh", subuh),
                              buildPrayerTime("Dhuhr", dhuhur),
                              buildPrayerTime("Ashar", ashar),
                              buildPrayerTime("Maghrib", maghrib),
                              buildPrayerTime("Isya", isya),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Right Panel (Hidden if screen width < 480)
                if (!isSmallScreen)
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: constraints.maxHeight - 30,
                      padding:EdgeInsets.all(20) ,
                      child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "KHGT 1446H",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        
                         Expanded(
                          child: CalendarKHGT(),
                          /*GridView.count(
                            crossAxisCount: 7,
                            children: List.generate(28, (index) {
                              return buildCalendarCell(index);
                            }),
                          ), */
                        ), 
                      
                      ],
                    ),
                    )
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildPrayerTime(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildCalendarCell(int index) {
    // Placeholder data for dates and colors
    List<String> dates = [
      "01-Dec-2024",
      "02-Dec-2024",
      "03-Dec-2024",
      "...",
      "15-Dec-2024",
      "16-Dec-2024",
      "...",
    ];
    Color cellColor = index == 15 ? const Color.fromARGB(255, 230, 226, 4) : Colors.white;
    Color textColor = index == 15 ? Colors.white : Colors.black;

    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cellColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
         Text(
          dates[index % dates.length],
          style: TextStyle(fontSize: 12, color: textColor),
          textAlign: TextAlign.center,
        ),
        Text("test"),
        ]
      ),
    );
  }
}

