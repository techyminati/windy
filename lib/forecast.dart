import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForecastPage extends StatefulWidget {
  final double? lat;
  final double? lon;
  final String? apiKey;

  const ForecastPage({
    Key? key,
    required this.lat,
    required this.lon,
    required this.apiKey,
  }) : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  String? apiKey;
  List<dynamic> forecastData = [];

  @override
  void initState() {
    super.initState();
    getForecast();
  }

  void getForecast() async {
    try {
      http.Response response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=${widget.lat}&lon=${widget.lon}&exclude=current,minutely,hourly,alerts&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          forecastData = data['daily'];
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7-day forecast'),
      ),
      body: ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index) {
          var dayData = forecastData[index];
          var date =
              DateTime.fromMillisecondsSinceEpoch(dayData['dt'] * 1000);
          var temperature = dayData['temp']['day'].round();
          var description = dayData['weather'][0]['description'];

          return ListTile(
            title: Text('${date.month}/${date.day}: $temperature°C'),
            subtitle: Text(description),
          );
        },
      ),
    );
  }
}
