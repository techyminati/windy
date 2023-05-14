import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiKey = '';
  String city = 'Bhopal';
  double? temperature;
  String? description;
  int? humidity;
  int? pressure;
  TextEditingController cityController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  void getWeather() async {
    try {
      http.Response response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          humidity = data['main']['humidity'];
          pressure = data['main']['pressure'];
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  Widget getWeatherIcon(String description) {
    if (description.contains('rain')) {
      return Icon(Icons.wb_sunny);
    } else if (description.contains('cloud')) {
      return Icon(Icons.wb_cloudy);
    } else if (description.contains('sun')) {
      return Icon(Icons.wb_sunny);
    } else if (description.contains('wind')) {
      return Icon(Icons.toys);
    } else {
      return Icon(Icons.wb_sunny);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  city = cityController.text;
                  getWeather();
                });
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Text(
              '$city',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            getWeatherIcon(description ?? ''),
            SizedBox(height: 20),
            Text(
              '${temperature?.round()}°C',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$description',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20),
            Text('Humidity: $humidity%'),
            Text('Pressure: $pressure hPa'),
            Text('Weather Report'),
            if (errorMessage != null)
              Text(
                '$errorMessage',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
