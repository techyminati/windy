import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

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

  String toTitleCase(String text) {
  return text
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

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

  if (description.contains('Rain') || description.contains('Moderate Rain') || description.contains('Light Rain')) {
    return BoxedIcon(WeatherIcons.rain, size: 90);
  } else if (description.contains('Cloud') || description.contains('overcast Clouds') || description.contains('Scattered Clouds')) {
    return BoxedIcon(WeatherIcons.day_cloudy, size: 90);
  } else if (description.contains('Wind')) {
    return BoxedIcon(WeatherIcons.strong_wind, size: 90);
  } else if (description.contains('Snow')) {
    return BoxedIcon(WeatherIcons.snow, size: 90);
  } else if (description.contains('Haze')) {
    return BoxedIcon(WeatherIcons.day_haze, size: 90);
  } else if (description.contains('Thunderstorm')) {
    return BoxedIcon(WeatherIcons.thunderstorm, size: 90);
  } else if (description.contains('Drizzle')) {
    return BoxedIcon(WeatherIcons.sprinkle, size: 90);
  } else if (description.contains('Fog')) {
    return BoxedIcon(WeatherIcons.day_fog, size: 90);
  } else if (description.contains('Mist')) {
    return BoxedIcon(WeatherIcons.day_fog, size: 90);
  } else if (description.contains('Smoke')) {
    return BoxedIcon(WeatherIcons.smoke, size: 90);
  } else if (description.contains('Dust')) {
    return BoxedIcon(WeatherIcons.dust, size: 90);
  } else if (description.contains('Sand')) {
    return BoxedIcon(WeatherIcons.sandstorm, size: 90);
  } else if (description.contains('Ash')) {
    return BoxedIcon(WeatherIcons.volcano, size: 90);
  } else if (description.contains('Squall')) {
    return BoxedIcon(WeatherIcons.strong_wind, size: 90);
  } else if (description.contains('Tornado')) {
    return BoxedIcon(WeatherIcons.tornado, size: 90);
  } else if (description.contains('Clear Sky') || description.contains('Sun')) { // changed from 'sun' to 'clear sky'
    return BoxedIcon(WeatherIcons.day_sunny, size: 90);
   }
   else {
     return BoxedIcon(WeatherIcons.day_sunny_overcast, size: 90);
   }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('7-day weather forecast'),
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    body: ListView.builder(
      itemCount: forecastData.length,
      itemBuilder: (context, index) {
        var dayData = forecastData[index];
        var date =
            DateTime.fromMillisecondsSinceEpoch(dayData['dt'] * 1000);
        var temperature = dayData['temp']['day'].round();
        var description = toTitleCase(dayData['weather'][0]['description']);


        String dayLabel;
        if (index == 0) {
          dayLabel = 'Today';
        } else if (index == 1) {
          dayLabel = 'Tomorrow';
        } else {
          dayLabel = DateFormat('EEEE').format(date);
        }
        
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
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