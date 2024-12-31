import 'package:flutter/material.dart';
import 'package:khgt/utils/khgt/hijriconverter.dart';
import 'package:intl/intl.dart';
import 'package:khgt/utils/khgt/khgt_dat.dart';
import 'dart:async';
import 'package:khgt/utils/khgt/muhdatetime.dart';

class CalendarKHGT extends StatefulWidget {
  const CalendarKHGT({super.key});

  @override
  State<CalendarKHGT> createState() => _CalendarKHGTState();
}

class _CalendarKHGTState extends State<CalendarKHGT> {
  late MuhDateTime _currentMonth;
  //late String pasaran = '-';
  late Timer? _timer;
  final PageController _pageController = PageController(initialPage: DateTime.now().month - 1);
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    initializeCalendar();
    _timer = Timer.periodic(const Duration(hours: 24), (_) => initializeCalendar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void initializeCalendar() {
    setState(() {
      HijriDateConverter khgt = HijriDateConverter();
      debugPrint(khgt.sPasaran);
      _currentMonth = MuhDateTime(hijriYear: khgt.iTahunH, iMonth: khgt.iBulanH, iDay: 1);
      selectedYear = _currentMonth.hijriYear;
      debugPrint(_currentMonth.pasar);
      //pasaran = _currentMonth.pasaran;
    });
  }

  String getPasaranOffset(int startIndex, String psrOffset) {
    List<String> psrn = HijriDateConverter.namaPasaran;
    int offset = psrn.indexOf(psrOffset);
    if (offset == -1) {
      throw ArgumentError("Invalid pasaran offset value: $psrOffset");
    }
    return psrn[(startIndex + offset) % psrn.length];
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 1, child: _buildHeader()),
        _buildWeeks(),
        Expanded(
          flex: 8,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentMonth = MuhDateTime(
                  hijriYear: selectedYear,
                  iMonth: index,
                  iDay: 1,
                );
                //pasaran = _currentMonth.pasaran;
              });
            },
            itemCount: 12 * 23,
            itemBuilder: (context, pageIndex) {
              int month = pageIndex % 12;
              return _calGrid(month, selectedYear);
            },
          ),
        ),
        Expanded(flex: 1, child: _buildFooter()),
      ],
    );
  }

  Widget _buildHeader() {
    final List<int> years = data.keys.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_pageController.page! > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
          Text(
            _currentMonth.monthName,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 20),
          DropdownButton<int>(
            value: selectedYear,
            items: years.map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                selectedYear = newValue ?? selectedYear;
              });
            },
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            'Year: $selectedYear',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahd'].map(_buildWeekDay)
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Text(
        day,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dayCell(int tgl, String psrn, DateTime masehi) {
    return Container(
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 253, 253),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topRight,
              child: Card(
                color: const Color.fromARGB(255, 255, 254, 254),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateFormat('dd/MM/yy').format(masehi),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$tgl",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(psrn),
          ),
        ],
      ),
    );
  }

  Widget _calGrid(int hijriMonth, int yearCh) {
    int weekdayOfFirstDay = _currentMonth.startingDate.weekday;
    int totalCells = _currentMonth.daysInMonth + weekdayOfFirstDay - 1;
    String myPsrn = _currentMonth.pasar;
    debugPrint(hijriMonth.toString());
    debugPrint(_currentMonth.monthName.toString());
    debugPrint(myPsrn.toString());

    int rows = (totalCells / 7).ceil();
    int itemCount = rows * 7;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.6,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirstDay - 1 || index >= _currentMonth.daysInMonth + weekdayOfFirstDay - 1) {
          return const SizedBox.shrink();
        }
        return _dayCell(
          index - weekdayOfFirstDay + 2,
          getPasaranOffset(index - weekdayOfFirstDay + 1, myPsrn),
          _currentMonth.startingDate.add(Duration(days: index - weekdayOfFirstDay + 1)),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Copyleft 1446 acepby All Right Reversed inspired by falakmu.id/khgt",
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}