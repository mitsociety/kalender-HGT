import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:khgt/widgets/hijri_date.dart';
import 'package:khgt/widgets/imsakiyah.dart';
import "package:khgt/widgets/calendar_khgt.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHGT Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 14, 138, 21)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kalender Hijriyah Global Tunggal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*
this widget should responsive page 
- widget tanggal KHGT :
-- nama hari, tanggal, bulan tahun, tanggal masehi

- widget Imsakiyah
-- remain to next salah
-- imsakiyah yaumi

- widget calendar KHGT
-- monthly, year selectable
-- first date of month and alyaumilbith 
-- islamic holyday

run on desktop and mobile
- if on desktop the display is landscape 2 column, while in mobile show in portraits

*/

class _MyHomePageState extends State<MyHomePage> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            // Mobile layout: Only the green section
            return Row(
              children: [
                Expanded(
                  child: _leftSideBox(constraints),
                ),
              ],
            );
          } else {
            // Desktop/Tablet layout
            return Row(
              children: [
                // Green Section
                Expanded(
                  flex: 3,
                  child: _leftSideBox(constraints),
                ),
                // Red Section
                Expanded(
                  flex: 9,
                  child: _calendarKHGT(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

//left side widget
Widget _leftSideBox(Constraints constraints) {
    return Container(
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: HijriKHGT(),
          ),
          Expanded(
            flex: 5,
            child: Imsakiyah(),//Container(color: Colors.green[900]),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(color: const Color.fromARGB(255, 254, 255, 254)),
            )
            
          )
        ],
      ),
    );
  }


//right side widget 
Widget _calendarKHGT() {
    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          Expanded(
            flex: 8,
            child: CalendarKHGT(),
          ),
          
        ],
        
      ),
    );
  }

  
}

