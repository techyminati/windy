import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
 return MaterialApp(
 title: 'Windy',
 theme: ThemeData(
 primarySwatch: Colors.blue,
 textTheme: GoogleFonts.questrialTextTheme(
 Theme.of(context).textTheme,
 ),
 ),
 darkTheme: ThemeData(
 brightness: Brightness.dark,
 primarySwatch: Colors.blue,
 scaffoldBackgroundColor: Colors.black,
 textTheme: GoogleFonts.questrialTextTheme(
 Theme.of(context).textTheme.apply(
 bodyColor: Colors.white,
 displayColor: Colors.white,
 ),
 ),
 inputDecorationTheme: InputDecorationTheme(
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(32),
 borderSide: BorderSide(color: Colors.white),
 ),
 enabledBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(32),
 borderSide: BorderSide(color: Colors.white),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(32),
 borderSide: BorderSide(color: Colors.white),
 ),
 labelStyle: TextStyle(color: Colors.white),
 ),
 ),
 home: MyHomePage(title: 'Windy'),
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
 String? city;
 double? temperature;
 String? description;
 int? humidity;
 int? pressure;
 double? feels_like;
 int? country;
 int? sunrise;
 int? sunset;
 int? aqi;
 TextEditingController cityController = TextEditingController();
 String? errorMessage;

String toTitleCase(String text) {
  return text
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

 void getWeather() async {
 if (city == null) return;
 try {
 http.Response response = await http.get(Uri.parse(
 'http://api.openweathermap.org/data/2.5/weather?q=${city!.trim()}&appid=$apiKey&units=metric'));
 
 if (response.statusCode == 200) {
 var data = jsonDecode(response.body);
 http.Response aqiResponse = await http.get(Uri.parse(
    'http://api.openweathermap.org/data/2.5/air_pollution?lat=${data['coord']['lat']}&lon=${data['coord']['lon']}&appid=$apiKey'));

  if (aqiResponse.statusCode == 200) {
  var aqiData = jsonDecode(aqiResponse.body);
  setState(() {
    aqi = aqiData['list'][0]['main']['aqi'];
  });
}
 setState(() {
 temperature = data['main']['temp'];
 description = toTitleCase(data['weather'][0]['description']);
 humidity = data['main']['humidity'];
 pressure = data['main']['pressure'];
 feels_like = data['main']['feels_like'];
 country = data['main']['country'];
 sunrise = data['sys']['sunrise'];
 sunset = data['sys']['sunset'];
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
 
void _getLastSearchedCity() async {
 SharedPreferences prefs = await SharedPreferences.getInstance();
 setState(() {
 city = prefs.getString('lastSearchedCity');
 });
 getWeather();
}

void _saveLastSearchedCity(String cityName) async {
 SharedPreferences prefs = await SharedPreferences.getInstance();
 prefs.setString('lastSearchedCity', cityName);
}
Widget getWeatherIcon(String description) {
  if (description.contains('rain') || description.contains('moderate rain')) {
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
    DateTime now = DateTime.now();
    if (now.isAfter(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000)) &&
        now.isBefore(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000))) {
      // It's daytime
      return Icon(Icons.wb_sunny, size: 120);
    } else {
      return Icon(Icons.brightness_3, size: 120); // This is the moon icon
    }
  } else {
        DateTime now = DateTime.now();
    if (now.isAfter(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000)) &&
        now.isBefore(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000))) {
      // It's daytime
      return Icon(Icons.wb_sunny, size: 120);
    } else {
      return Icon(Icons.brightness_3, size: 120); // This is the moon icon
    }
  }
}


@override
void initState() {
 super.initState();
 _getLastSearchedCity();
}

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: Text(widget.title),
 ),
 body: SingleChildScrollView(
 child: Padding(
 padding: const EdgeInsets.all(16.0),
 child: Column(
 children: <Widget>[
 TextField(
 controller: cityController,
 decoration: InputDecoration(
 labelText: 'Enter City',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(32),
 ),
 ),
 textCapitalization: TextCapitalization.words,
 ),
 SizedBox(height: 16),
 ElevatedButton(
 onPressed: () {
 setState(() {
 city = cityController.text;
 _saveLastSearchedCity(city!);
 getWeather();
 });
 },
 child: Text('Search'),
 style: ElevatedButton.styleFrom(
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(32),
 ),
 ),
),
 SizedBox(height: 32),
 if (city == null)
 Text('Enter a city name to continue')
 else ...[
  //if (city != null)
 Text(
 '$city',
 style:
 Theme.of(context).textTheme.headline4?.copyWith(fontSize:
52),
 ),
 SizedBox(height:
32),
 getWeatherIcon(description ?? ''),
 SizedBox(height:
32),
 Text(
 '${temperature?.round()}°C',
 style:
 Theme.of(context).textTheme.headline4?.copyWith(fontSize:58),
 ),
 Center(
 child: Text(
 '$description',
 style:
 Theme.of(context).textTheme.headline6?.copyWith(fontSize:44),
textAlign: TextAlign.center,
 ),
 ),
 SizedBox(height:32),
 Text('Humidity: $humidity%', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:28)),
 Text('Pressure: $pressure hPa', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:28)),
 Text('Feels like: ${feels_like?.round()}°C', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:28)),
Text('AQI: $aqi', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 28)),
 ],
 if (errorMessage != null)
 Text(
 '$errorMessage',
 style:
 TextStyle(color:
Colors.red, fontWeight:
FontWeight.bold),
 ),
 ],
 ),
 ),
 ),
 );
 }
}
