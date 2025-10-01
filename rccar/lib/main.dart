import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 Car',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CarControlPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CarControlPage extends StatefulWidget {
  const CarControlPage({super.key});

  @override
  State<CarControlPage> createState() => _CarControlPageState();
}

class _CarControlPageState extends State<CarControlPage> {
  String mode = "manual";
  int speed = 60;
  Map<String, dynamic> telemetry = {};

  final String baseUrl = "http://192.168.4.1"; // ESP8266 AP IP

  Future<void> sendMove(String dir) async {
    final url = Uri.parse("$baseUrl/move?dir=$dir&speed=$speed");
    await http.get(url);
  }

  Future<void> sendMode(String newMode) async {
    final url = Uri.parse("$baseUrl/mode?name=$newMode");
    await http.get(url);
    setState(() => mode = newMode);
  }

  Future<void> fetchTelemetry() async {
    try {
      final url = Uri.parse("$baseUrl/telemetry");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() => telemetry = json.decode(res.body));
      }
    } catch (e) {
      // ignore errors if disconnected
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTelemetry();
    Future.delayed(const Duration(seconds: 1), () {
      fetchTelemetry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Speedometer + slider
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Speedometer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SleekCircularSlider(
                  min: 0,
                  max: 100,
                  initialValue: speed.toDouble(),
                  appearance: CircularSliderAppearance(
                    size: 150,
                    customColors: CustomSliderColors(
                      progressBarColor: Colors.blue,
                      trackColor: Colors.grey.shade300,
                      dotColor: Colors.blueAccent,
                    ),
                    infoProperties: InfoProperties(
                      mainLabelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      modifier: (val) => "${val.toInt()}%",
                    ),
                  ),
                  onChange: (val) {
                    setState(() => speed = val.toInt());
                  },
                ),
              ],
            ),
          ),

          // Right side: Controls
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => sendMode("manual"), child: const Text("Manual")),
                    const SizedBox(width: 10),
                    ElevatedButton(onPressed: () => sendMode("line"), child: const Text("Line")),
                    const SizedBox(width: 10),
                    ElevatedButton(onPressed: () => sendMode("avoid"), child: const Text("Avoid")),
                  ],
                ),
                const SizedBox(height: 20),

                // Direction pad
                Column(
                  children: [
                    GestureDetector(
                      onTapDown: (_) => sendMove("forward"),
                      onTapUp: (_) => sendMove("stop"),
                      child: ElevatedButton(child: const Text("▲"), onPressed: () {}),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => sendMove("left"),
                          onTapUp: (_) => sendMove("stop"),
                          child: ElevatedButton(child: const Text("◀"), onPressed: () {}),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTapDown: (_) => sendMove("right"),
                          onTapUp: (_) => sendMove("stop"),
                          child: ElevatedButton(child: const Text("▶"), onPressed: () {}),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTapDown: (_) => sendMove("back"),
                      onTapUp: (_) => sendMove("stop"),
                      child: ElevatedButton(child: const Text("▼"), onPressed: () {}),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
