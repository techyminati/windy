import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

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
 int? feels_like;
 int? country;
 TextEditingController cityController = TextEditingController();
 String? errorMessage;

 void getWeather() async {
 if (city == null) return;
 try {
 http.Response response = await http.get(Uri.parse(
 'http://api.openweathermap.org/data/2.5/weather?q=${city!.trim()}&appid=$apiKey&units=metric'));
 if (response.statusCode == 200) {
 var data = jsonDecode(response.body);
 setState(() {
 temperature = data['main']['temp'];
 description = data['weather'][0]['description'];
 humidity = data['main']['humidity'];
 pressure = data['main']['pressure'];
 feels_like = data['main']['feels_like'];
 country = data['main']['country'];
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
 return Icon(Icons.wb_sunny, size: 128);
 } else if (description.contains('cloud')) {
 return Icon(Icons.wb_cloudy, size: 128);
 } else if (description.contains('sun')) {
 return Icon(Icons.wb_sunny, size: 128);
 } else if (description.contains('wind')) {
 return Icon(Icons.toys, size: 128);
 } else {
 return Icon(Icons.wb_sunny, size: 128);
 }
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
 ),
 SizedBox(height: 16),
 ElevatedButton(
 onPressed: () {
 setState(() {
 city = cityController.text;
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
 Text(
 '$city',
 style:
 Theme.of(context).textTheme.headline4?.copyWith(fontSize:
64),
 ),
 SizedBox(height:
32),
 getWeatherIcon(description ?? ''),
 SizedBox(height:
32),
 Text(
 '${temperature?.round()}°C',
 style:
 Theme.of(context).textTheme.headline4?.copyWith(fontSize:
58),
 ),
 Text(
 '$description',
 style:
 Theme.of(context).textTheme.headline6?.copyWith(fontSize:
44),
 ),
 SizedBox(height:
42),
 Text('Humidity: $humidity%', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:
32)),
 Text('Pressure: $pressure hPa', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:
32)),
 Text('Feels Like: $feels_like ', style:
 Theme.of(context).textTheme.bodyText1?.copyWith(fontSize:
32)),
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
