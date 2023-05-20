import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:windy/about.dart';
import 'package:windy/forecast.dart';

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
  static final GlobalKey<_MyHomePageState> _key = GlobalKey<_MyHomePageState>();
  

  static _MyHomePageState? of(BuildContext context) => _key.currentState;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  late final String title;
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
  String? name;
  double? lat;
  double? lon;
  int? cloudCoverage;
  TextEditingController cityController = TextEditingController();
  String? errorMessage;
  bool searchBarVisible = false;
  double? windSpeed;
  int? windDirection;
  Duration animationDuration = Duration(milliseconds: 950);
  final ScrollController _scrollController = ScrollController();

  String getCardinalDirection(int? deg) {
    if (deg != null) {
      final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
      final index = ((deg + 22.5) / 45).floor() % 8;
      return directions[index];
    } else {
      return '';
    }
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void getWeather() async {
    if (city == null || city!.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter a city name'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('city', city!);

    final String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      setState(() {
        temperature = result['main']['temp'];
        description = result['weather'][0]['description'];
        humidity = result['main']['humidity'];
        pressure = result['main']['pressure'];
        feels_like = result['main']['feels_like'];
        country = result['sys']['country'];
        sunrise = result['sys']['sunrise'];
        sunset = result['sys']['sunset'];
        aqi = result['main']['aqi'];
        name = result['name'];
        lat = result['coord']['lat'];
        lon = result['coord']['lon'];
        windSpeed = result['wind']['speed'];
        windDirection = result['wind']['deg'];
        cloudCoverage = result['clouds']['all'];
        errorMessage = null;
      });
    } else {
      setState(() {
        temperature = null;
        description = null;
        humidity = null;
        pressure = null;
        feels_like = null;
        country = null;
        sunrise = null;
        sunset = null;
        aqi = null;
        name = null;
        lat = null;
        lon = null;
        windSpeed = null;
        windDirection = null;
        cloudCoverage = null;
        errorMessage = 'Error getting weather data for $city. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId('group.com.example.windy');
    HomeWidget.saveWidgetData('city', '');
    HomeWidget.saveWidgetData('temperature', '');
    HomeWidget.saveWidgetData('description', '');
    HomeWidget.saveWidgetData('icon', '');
    HomeWidget.saveWidgetData('isDarkMode', '');
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cityName = prefs.getString('city');
      setState(() {
        city = cityName ?? '';
        cityController.text = city!;
      });
      getWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                searchBarVisible = !searchBarVisible;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Windy',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Weather App',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.wb_sunny_outlined),
              title: Text('Forecast'),
              onTap: () {
                Navigator.pop(context);
Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForecastPage(
                lat: lat,
                lon: lon,
                apiKey: apiKey,
              ),
            ),
          );
              },
            ),
            ListTile(
              leading: Icon(Icons.nightlight_round),
              title: Text('Toggle Dark Mode'),
              onTap: () {
                final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
                setThemeMode(newThemeMode);
                HomeWidget.saveWidgetData('isDarkMode', newThemeMode == ThemeMode.dark ? 'true' : 'false');
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            searchBarVisible = false;
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: searchBarVisible,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'Enter a city name',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              city = cityController.text;
                            });
                            getWeather();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (errorMessage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (temperature != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temperature °C',
                        style: TextStyle(fontSize: 48),
                      ),
                      Text(
                        description!,
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                SizedBox(height: 24),
                if (humidity != null)
                  Row(
                    children: [
                      Icon(WeatherIcons.humidity),
                      SizedBox(width: 8),
                      Text('Humidity: $humidity%'),
                    ],
                  ),
                SizedBox(height: 8),
                if (pressure != null)
                  Row(
                    children: [
                      Icon(WeatherIcons.barometer),
                      SizedBox(width: 8),
                      Text('Pressure: $pressure hPa'),
                    ],
                  ),
                SizedBox(height: 8),
                if (feels_like != null)
                  Row(
                    children: [
                      Icon(WeatherIcons.thermometer),
                      SizedBox(width: 8),
                      Text('Feels like: $feels_like°C'),
                    ],
                  ),
                SizedBox(height: 24),
                if (country != null)
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 8),
                      Text('Country: $country'),
                    ],
                  ),
                SizedBox(height: 8),
                if (sunrise != null)
                  Row(
                    children: [
                      Icon(Icons.wb_sunny),
                      SizedBox(width: 8),
                      Text('Sunrise: ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000))}'),
                    ],
                  ),
                SizedBox(height: 8),
                if (sunset != null)
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 8),
                      Text('Sunset: ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000))}'),
                    ],
                  ),
                SizedBox(height: 24),
                if (aqi != null)
                  Row(
                    children: [
                      Icon(Icons.air),
                      SizedBox(width: 8),
                      Text('Air Quality Index: $aqi'),
                    ],
                  ),
                SizedBox(height: 24),
                if (name != null)
                  Row(
                    children: [
                      Icon(Icons.location_city),
                      SizedBox(width: 8),
                      Text('City: $name'),
                    ],
                  ),
                SizedBox(height: 8),
                if (lat != null && lon != null)
                  Row(
                    children: [
                      Icon(Icons.map),
                      SizedBox(width: 8),
                      Text('Latitude: $lat, Longitude: $lon'),
                    ],
                  ),
                SizedBox(height: 24),
                if (windSpeed != null && windDirection != null)
                  Row(
                    children: [
                      Icon(WeatherIcons.wind),
                      SizedBox(width: 8),
                      Text('Wind: $windSpeed m/s ${getCardinalDirection(windDirection)}'),
                    ],
                  ),
                SizedBox(height: 24),
                if (cloudCoverage != null)
                  Row(
                    children: [
                      Icon(WeatherIcons.cloud),
                      SizedBox(width: 8),
                      Text('Cloud Coverage: $cloudCoverage%'),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
