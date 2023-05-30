import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class HourlyForecastPage extends StatefulWidget {
  final double? lat;
  final double? lon;
  final String apiKey;

  HourlyForecastPage({Key? key, this.lat, this.lon, required this.apiKey})
      : super(key: key);

  @override
  _HourlyForecastPageState createState() => _HourlyForecastPageState();
}

class _HourlyForecastPageState extends State<HourlyForecastPage> {
  List hourlyData = [];

  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    getHourlyWeather();
  }

  void getHourlyWeather() async {
    try {
      http.Response response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=${widget.lat}&lon=${widget.lon}&exclude=current,minutely,daily&appid=${widget.apiKey}&units=metric'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          hourlyData = data['hourly'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

Widget getWeatherIcon(String description) {

  if (description.contains('Heavy Intensity Rain')) {
    return BoxedIcon(WeatherIcons.rain_wind, size: 90);
  } else if (description.contains('Moderate Rain')) {
    return BoxedIcon(WeatherIcons.rain, size: 90);
  } else if (description.contains('Light Rain') || description.contains('Drizzle') || description.contains('Showers')) {
    return BoxedIcon(WeatherIcons.showers, size: 90);
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

String formatTime(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp *1000);
    var formattedTime = DateFormat.jm().format(date);

    return formattedTime;
}

String formatDate(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp *1000);
    var formattedDate = DateFormat.MMMd().format(date);

    return formattedDate;
}

String formatDateTime(int timestamp) {

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp *1000);

    var formattedDate = DateFormat.MMMd().format(date);

    var formattedTime = DateFormat.jm().format(date);

    return '$formattedDate - $formattedTime';
}

String formatTemperature(double temperature) {

    var temp = temperature.round();

    return '$temp°C';
}

String formatWindSpeed(double speed) {

    var windSpeed = speed.round();

    return '$windSpeed m/s';
}

String formatHumidity(int humidity) {

    return '$humidity%';
}

String formatPressure(int pressure) {

    return '$pressure hPa';
}

String formatUvi(double uvi) {

    var uvIndex = uvi.round();

    return uvIndex.toString();
}

String formatClouds(int clouds) {

    return '$clouds%';
}

String formatVisibility(int visibility) {

    var visibiltyInKm = visibility /1000;

    return '$visibiltyInKm km';
}

String formatDewPoint(double dewPoint) {

    var dewPt = dewPoint.round();

    return '$dewPt°C';
}

String formatPop(double pop) {

    var probabilityOfPrecipitation = pop *100;

    probabilityOfPrecipitation.round();

    return '$probabilityOfPrecipitation%';
}

String getCardinalDirection(int deg) {

        final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        final index = ((deg +22.5)/45).floor() %8;

        return directions[index];
}


@override
Widget build(BuildContext context) {

return Scaffold(
appBar:

AppBar(title:
Text("Hourly Forecast"),
foregroundColor:
Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
shape:
RoundedRectangleBorder(borderRadius:
BorderRadius.vertical(bottom:
Radius.circular(16))),
elevation:
0,
backgroundColor:
Colors.transparent,
),

body:
ListView.builder(
itemCount:
hourlyData.length,
itemBuilder:
(context,index){
var hourly =
hourlyData[index];
var time =
DateTime.fromMillisecondsSinceEpoch(hourly['dt']*1000);
var temperature =
hourly['temp'].round();
var description =
toTitleCase(hourly['weather'][0]['description']);

return Card(
margin:
EdgeInsets.all(8),
child:
Padding(padding:
EdgeInsets.all(8),child:
Column(crossAxisAlignment:
CrossAxisAlignment.start,
children:[
Text(formatDateTime(hourly['dt']),style:
Theme.of(context).textTheme.headline6),
SizedBox(height:
8),
Row(children:[
Expanded(child:
Column(crossAxisAlignment:
CrossAxisAlignment.start,
children:[
//  SizedBox(width:3),
Text(formatTemperature(hourly['temp']),style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),
// SizedBox(width:8),
Text(description),
],),),
getWeatherIcon(description),
],),
],),),);},),);}}
