import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the dart:convert library
import 'dart:math';
import 'package:intl/intl.dart'; // Import the intl library

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SBB Roulette',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(198, 0, 24, 1.0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SBB Roulette'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _track = '';
  String _departureTime = '';
  String _destination = '';
  String _station = '';
  String _mode = '';
  String _delay = '';
  String _modeIdentifier = '';

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }

  Future<void> _getRandomDeparture() async {
    // Replace 'YOUR_API_ENDPOINT' with the actual API endpoint URL

    const int limit = 10;
    final String api =
        'http://transport.opendata.ch/v1/stationboard?station=$_station&limit=$limit';
    final response = await http.get(Uri.parse(api));

    // generate a random number between 0 and limit
    var random = Random();
    var randomNumber = random.nextInt(limit);

    if (response.statusCode == 200) {
      // API request was successful
      final responseData = jsonDecode(response.body);

      final connection = responseData['stationboard'][randomNumber];
      setState(() {
        _track = connection['stop']['platform'];
        _departureTime = formatDateTime(connection['stop']['departure']);
        _delay = connection['stop']['delay'].toString();
        _destination = connection['to'];
        _mode = connection['category'];
        // _modeIdentifier = _mode + connection['number'];
      });
    } else {
      // API request failed
      // You can handle errors here, e.g., show a snackbar or error message
      print('API request failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyCustomForm(
              onStationChanged: (station) {
                setState(() {
                  print(station);
                  _station = station;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _getRandomDeparture,
              child: const Text('Zufällige Verbindung'),
            ),
            const SizedBox(height: 30),
            if (_departureTime != '') ...[
              Text('Track: $_track'),
              Text('Departure Time: $_departureTime'),
              Text('Destination: $_destination'),
              Text('Mode: $_mode'),
              Text('Delay: $_delay'),
              Text('Mode Identifier: $_modeIdentifier'),
            ],
          ],
        ),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  final ValueChanged<String> onStationChanged;

  const MyCustomForm({Key? key, required this.onStationChanged})
      : super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final TextEditingController _stationController = TextEditingController();

  @override
  void dispose() {
    _stationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Bahnhof/Haltestelle'),
          TextField(
            controller: _stationController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'z.B. Zürich HB',
            ),
            onChanged: (String value) {
              widget.onStationChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
