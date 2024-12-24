import 'package:flutter/material.dart';
import 'package:khgt/utils/hijriconverter.dart';
import "package:intl/intl.dart";

class CalendarKHGT extends StatefulWidget {
  const CalendarKHGT({super.key});
  @override
  State<CalendarKHGT> createState()=> _CalendarKHGTState();
}

class _CalendarKHGTState extends State<CalendarKHGT> {
  late HijriDateConverter _khgt;
  late String blnH;
  late String thnH;
  late String hari;
  late String pasaran;
  final PageController _pageController = PageController(initialPage: DateTime.now().month - 1);
  DateTime _currentMonth = DateTime.now();
  
  bool slctdCrntYear = false;

  @override
  void initState() {
    getKHGT();
    super.initState();
  }

  void getKHGT(){
    _khgt = HijriDateConverter();
    _khgt.hitungTanggal();
    blnH = _khgt.sBulanH;

  }

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              
              _buildHeader(),
              _buildWeeks(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index){
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, index + 1,1);
                    });
                  },
                  itemCount: 12 * 10,
                  itemBuilder: (context,pageIndex){
                    DateTime month = DateTime(_currentMonth.year, (pageIndex % 12) + 1, 1);
                    return buildCalendar(month);
                  },
                  )
                  )
            ],
          );
        
  }
  // widget _buildHeader
  Widget _buildHeader() {
  // Checks if the current month is the last month of the year (December)
  bool isLastMonthOfYear = _currentMonth.month == 12;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Moves to the previous page if the current page index is greater than 0
            if (_pageController.page! > 0) {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        // Displays the name of the current month
        Text(
          '${DateFormat('MMMM').format(_currentMonth)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<int>(
          // Dropdown for selecting a year
          value: _currentMonth.year,
          onChanged: (int? year) {
            if (year != null) {
              setState(() {
                // Sets the current month to January of the selected year
                _currentMonth = DateTime(year, 1, 1);

                // Calculates the month index based on the selected year and sets the page
                int yearDiff = DateTime.now().year - year;
                int monthIndex = 12 * yearDiff + _currentMonth.month - 1;
                _pageController.jumpToPage(monthIndex);
              });
            }
          },
          items: [
            // Generates DropdownMenuItems for a range of years from current year to 10 years ahead
            for (int year = DateTime.now().year;
                year <= DateTime.now().year + 10;
                year++)
              DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            // Moves to the next page if it's not the last month of the year
            if (!isLastMonthOfYear) {
              setState(() {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            }
          },
        ),
      ],
    ),
  );
}
  //widget _buildWeeks
  Widget _buildWeeks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeekDay('Mon'),
          _buildWeekDay('Tue'),
          _buildWeekDay('Wed'),
          _buildWeekDay('Thu'),
          _buildWeekDay('Fri'),
          _buildWeekDay('Sat'),
          _buildWeekDay('Sun'),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        day,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
  //widget _buildCalendar
  // This widget builds the detailed calendar grid for the chosen month.
Widget buildCalendar(DateTime month) {
  // Calculating various details for the month's display
  int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
  int weekdayOfFirstDay = firstDayOfMonth.weekday;

  DateTime lastDayOfPreviousMonth =
      firstDayOfMonth.subtract(Duration(days: 1));
  int daysInPreviousMonth = lastDayOfPreviousMonth.day;

  return GridView.builder(
    padding: EdgeInsets.zero,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7,
      //childAspectRatio:0.9,
    ),
    // Calculating the total number of cells required in the grid
    itemCount: daysInMonth + weekdayOfFirstDay - 1,
    itemBuilder: (context, index) {
      if (index < weekdayOfFirstDay - 1) {
        // Displaying dates from the previous month in grey
        int previousMonthDay =
            daysInPreviousMonth - (weekdayOfFirstDay - index) + 2;
        return Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            previousMonthDay.toString(),
            style: TextStyle(color: Colors.grey),
          ),
        );
      } else {
        // Displaying the current month's days
        DateTime date = DateTime(month.year, month.month, index - weekdayOfFirstDay + 2);
        String text = date.day.toString();

        return InkWell(
          onTap: () {
            // Handle tap on a date cell
            // This is where you can add functionality when a date is tapped
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey),
               borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: SizedBox(height: 2.0),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: Text(
                      'Sample Text', // Sample text
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 127, 126, 126),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}
/*
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}*/

}