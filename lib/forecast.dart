import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  String apiKey = '105d997a8a1977cb138167503eb7afa1';
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
Widget getWeatherIcon(String description) {
  if (description.contains('Rain') || description.contains('Moderate Rain') || description.contains('Light Rain') )  {
    return Icon(Icons.umbrella, size: 120);
  } else if (description.contains('Cloud') || description.contains('overcast Clouds') || description.contains('Scattered Clouds')) {
    return Icon(Icons.wb_cloudy, size: 120);
  } else if (description.contains('Wind')) {
    return Icon(Icons.toys, size: 120);
  } else if (description.contains('Snow')) {
    return Icon(Icons.ac_unit, size: 120);
  } else if (description.contains('Haze')) {
    return Icon(Icons.filter_drama, size: 120);
  } else if (description.contains('Thunderstorm')) {
    return Icon(Icons.flash_on, size: 120);
  } else if (description.contains('Drizzle')) {
    return Icon(Icons.grain, size: 120);
  } else if (description.contains('Fog')) {
    return Icon(Icons.dehaze, size: 120);
  } else if (description.contains('Mist')) {
    return Icon(Icons.dehaze, size: 120);
  } else if (description.contains('Smoke')) {
    return Icon(Icons.smoking_rooms, size: 120);
  } else if (description.contains('Dust')) {
    return Icon(Icons.landscape, size: 120);
  } else if (description.contains('Sand')) {
    return Icon(Icons.landscape, size: 120);
  } else if (description.contains('Ash')) {
    return Icon(Icons.landscape, size: 120);
  } else if (description.contains('Squall')) {
    return Icon(Icons.waves, size: 120);
  } else if (description.contains('Tornado')) {
    return Icon(Icons.toys, size: 120);
  } else if (description.contains('Clear Sky') || description.contains('Sun'))  { // changed from 'sun' to 'clear sky'
      return Icon(Icons.wb_sunny, size: 120);
  }
  else {
    return Icon(Icons.wb_sunny, size: 120);
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

        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('EEEE').format(date)}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$temperature°C',
                            style:
                                Theme.of(context).textTheme.headline5?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(description),
                        ],
                      ),
                    ),
                    // Replace this with an icon that represents the weather conditions
                    getWeatherIcon(description),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}