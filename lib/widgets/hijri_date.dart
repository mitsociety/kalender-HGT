import "package:flutter/material.dart";
import "package:khgt/utils/khgt/hijriconverter.dart";
import "dart:async";

class HijriKHGT extends StatefulWidget {
  const HijriKHGT({super.key});

  @override
  State<HijriKHGT> createState() => _HijriKHGTState();
}

class _HijriKHGTState extends State<HijriKHGT> {
  late HijriDateConverter _khgt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getTanggal();
    startPeriodicUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void getTanggal() {
    _khgt = HijriDateConverter();
    
  }

  void startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(hours: 24), (timer) {
      setState(() {
        getTanggal();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      color: const Color.fromARGB(255, 2, 73, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _khgt.sPasaran,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                _khgt.iTanggalH.toString(),
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "${_khgt.sBulanH} ${_khgt.iTahunH} H",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "[ ${_khgt.iTanggalM} ${HijriDateConverter.namaBulanE[_khgt.iBulanM]} ${_khgt.iTahunM} ]",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
