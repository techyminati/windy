import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:windy/about.dart';
import 'package:windy/forecast.dart';
import 'package:windy/hourly.dart';
import 'package:windy/key.dart';
import 'package:windy/settings.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Windy',
      // themeMode: MyHomePage._key.currentState?._themeMode,

      theme: ThemeData.from(
        colorScheme: ColorScheme.light(),

        // primarySwatch: Colors.blue,
        textTheme: GoogleFonts.questrialTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.dark(),
        // brightness: Brightness.dark,
        // primarySwatch: Colors.blue,
        // scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.questrialTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        /* inputDecorationTheme: InputDecorationTheme(
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
 ),*/
      ),
      home: MyHomePage(title: 'Windy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  static final GlobalKey<MyHomePageState> _key = GlobalKey<MyHomePageState>();

  static MyHomePageState? of(BuildContext context) => _key.currentState;

  @override
  MyHomePageState createState() => MyHomePageState();
  late final String title;
}

class MyHomePageState extends State<MyHomePage> {
  String? city;
  double? temperature;
  double? highTemp; // new variable to store high temperature
  double? lowTemp; // new variable to store low temperature
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
  double? latitude;
  double? longitude;
  int? rsps;

  int? cloudCoverage;
  TextEditingController cityController = TextEditingController();
  String? errorMessage;
  bool searchBarVisible = false;
  bool isCelsius = true;
  bool isKilometersPerHour = true;
  bool isMillibars = true;
  bool isHourlyNotificationEnabled = true;
  double? windSpeed;
  int? windDirection;
  Duration animationDuration = Duration(milliseconds: 950);
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // GlobalKey<AnimatedIconState> _weatherIconKey = GlobalKey();

  String getCardinalDirection(int? deg) {
    if (deg != null) {
      final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
      final index = ((deg + 22.5) / 45).floor() % 8;
      return directions[index];
    } else {
      return '';
    }
  }

  Location location = new Location();

  bool _serviceEnabled = false;
  bool isLoading = true;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Future<void> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
                'Please grant location permission to use this feature or enter location manually.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  void updateWeatherWithCurrentLocation() async {
    if (_locationData != null) {
      setState(() {
        latitude = _locationData!.latitude;
        longitude = _locationData!.longitude;
      });
      await getWeather();
      _saveLastSearchedCity(name!);
      latitude = null;
      longitude = null;
      // city = name;
    }
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCelsius = prefs.getBool('isCelsius') ?? true;
      isKilometersPerHour = prefs.getBool('isKilometersPerHour') ?? true;
      isMillibars = prefs.getBool('isMillibars') ?? true;
      isHourlyNotificationEnabled =
          prefs.getBool('isHourlyNotificationEnabled') ?? true;
    });
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isCelsius', isCelsius);
    prefs.setBool('isKilometersPerHour', isKilometersPerHour);
    prefs.setBool('isMillibars', isMillibars);
    prefs.setBool('isHourlyNotificationEnabled', isHourlyNotificationEnabled);
  }

  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void checkConnectivity() async {
    // Check for network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No network connectivity, display a toast message
      Fluttertoast.showToast(
        msg: "Please check your internet connection and try again",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
  }

  Future<void> getWeather() async {
    checkConnectivity();
    if (latitude != null && longitude != null) {
      // Use the user's current location
      try {
        http.Response response = await http.get(Uri.parse(
            'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          http.Response aqiResponse = await http.get(Uri.parse(
              'http://api.openweathermap.org/data/2.5/air_pollution?lat=${data['coord']['lat']}&lon=${data['coord']['lon']}&appid=$apiKey'));

          if (aqiResponse.statusCode == 200) {
            var aqiData = jsonDecode(aqiResponse.body);
            setState(() {
              aqi = aqiData['list'][0]['main']['aqi'];
            });
            if (response.statusCode == 200) {
              var data = jsonDecode(response.body);
              http.Response onecall = await http.get(Uri.parse(
                  'https://api.openweathermap.org/data/3.0/onecall?lat=${data['coord']['lat']}&lon=${data['coord']['lon']}&exclude=minutely,hourly&appid=$apiKey&units=metric'));
              if (onecall.statusCode == 200) {
                var onedata = jsonDecode(onecall.body);
                //Map<String, dynamic> onedata = jsonDecode(response.body);
                // List<dynamic> daily = onedata['daily'];
                //Map<String, dynamic> tempp = daily[0]['temp'];
                // lowTemp  = tempp['min'];
                setState(() {
                  lowTemp = onedata['daily'][0]['temp']['min'];
                  double temps = data['main']['temp'];
                  double ht = onedata['daily'][0]['temp']['max'];
                  if (temps > ht) {
                    highTemp = temps;
                  } else {
                    highTemp = onedata['daily'][0]['temp']['max'];
                  }
                });
              }
            }
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
            name = data['name'];
            lat = data['coord']['lat'];
            lon = data['coord']['lon'];
            windSpeed = data['wind']['speed'];
            windDirection = data['wind']['deg'];
            cloudCoverage = data['clouds']['all'];
            city = name;
            _saveLastSearchedCity(name!);

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
    } else if (city == null || city!.trim().isEmpty) {
      setState(() {
        // errorMessage = 'Please enter a city name';
      });
      return;
    }
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

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            http.Response onecall = await http.get(Uri.parse(
                'https://api.openweathermap.org/data/3.0/onecall?lat=${data['coord']['lat']}&lon=${data['coord']['lon']}&exclude=minutely,hourly&appid=$apiKey&units=metric'));
            if (onecall.statusCode == 200) {
              var onedata = jsonDecode(onecall.body);
              //Map<String, dynamic> onedata = jsonDecode(response.body);
              // List<dynamic> daily = onedata['daily'];
              //Map<String, dynamic> tempp = daily[0]['temp'];
              // lowTemp  = tempp['min'];
              setState(() {
                lowTemp = onedata['daily'][0]['temp']['min'];
                double temps = data['main']['temp'];
                double ht = onedata['daily'][0]['temp']['max'];
                if (temps > ht) {
                  highTemp = temps;
                } else {
                  highTemp = onedata['daily'][0]['temp']['max'];
                }
              });
            }
          }
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
          name = data['name'];
          lat = data['coord']['lat'];
          lon = data['coord']['lon'];
          windSpeed = data['wind']['speed'];
          windDirection = data['wind']['deg'];
          cloudCoverage = data['clouds']['all'];
          // latitude = lat;
          // longitude = lon;
          _saveLastSearchedCity(name!);

          errorMessage = null;
        });
      } else {
        setState(() {
          rsps = response.statusCode;
          errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
      _initializeNotifications();
  }

  Future<void> _handleRefresh() async {
    // Refresh the weather data
    getWeather();
  }

  void _getLastSearchedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      city = prefs.getString('lastSearchedCity');
    });
    await getWeather();
    setState(() {
      isLoading = false;
    });
  }

  void _saveLastSearchedCity(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSearchedCity', cityName);
  }

  Widget getWeatherIcon(String description) {
  DateTime now = DateTime.now();
  bool isDaytime =
      now.isAfter(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000)) &&
          now.isBefore(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000));

  switch (description) {
    case 'Heavy Intensity Rain':
      return BoxedIcon(WeatherIcons.rain_wind, size: 127);
    case 'Moderate Rain':
      return BoxedIcon(WeatherIcons.rain, size: 127);
    case 'Light Rain':
    case 'Drizzle':
    case 'Showers':
      return BoxedIcon(WeatherIcons.showers, size: 127);
    case 'Cloud':
    case 'overcast Clouds':
    case 'Scattered Clouds':
      return BoxedIcon(
          isDaytime ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy,
          size: 127);
    case 'Wind':
      return BoxedIcon(WeatherIcons.strong_wind, size: 127);
    case 'Snow':
      return BoxedIcon(WeatherIcons.snow, size: 127);
    case 'Haze':
      return BoxedIcon(
          isDaytime ? WeatherIcons.day_haze : WeatherIcons.night_fog,
          size: 127);
    case 'Thunderstorm':
      return BoxedIcon(WeatherIcons.thunderstorm, size: 127);
    case 'Drizzle':
      return BoxedIcon(WeatherIcons.sprinkle, size: 127);
    case 'Fog':
    case 'Mist':
      return BoxedIcon(
          isDaytime ? WeatherIcons.day_fog : WeatherIcons.night_fog,
          size: 127);
    case 'Smoke':
      return BoxedIcon(WeatherIcons.smoke, size: 127);
    case 'Dust':
      return BoxedIcon(WeatherIcons.dust, size: 127);
    case 'Sand':
      return BoxedIcon(WeatherIcons.sandstorm, size: 127);
    case 'Ash':
      return BoxedIcon(WeatherIcons.volcano, size: 127);
    case 'Squall':
      return BoxedIcon(WeatherIcons.strong_wind, size: 127);
    case 'Tornado':
      return BoxedIcon(WeatherIcons.tornado, size: 127);
    case 'Clear Sky':
    case 'Sun':
      return BoxedIcon(
          isDaytime ? WeatherIcons.day_sunny : WeatherIcons.night_clear,
          size: 127);
    default:
      return BoxedIcon(
          isDaytime
              ? WeatherIcons.day_sunny_overcast
              : WeatherIcons.night_alt_partly_cloudy,
          size: 127);
  }
}


  @override
  void initState() {
    super.initState();
    loadPreferences();
    _getLastSearchedCity();
    requestNotificationPermission();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        setState(() {
          widget.title = name ?? 'Windy';
        });
      } else {
        setState(() {
          widget.title = 'Windy';
        });
      }
    });
    //   _initializeNotifications();
  }

  Future<void> requestNotificationPermission() async {
    // final status = await permission_handler.Permission.notification.status;
    final status = await permission_handler.Permission.notification.request();

    if (status.isGranted) {
      // Notification permissions are already granted, no need to show a toast.
    } else if (status.isDenied) {
      // Permission is denied. You can prompt the user to open app settings.
      Fluttertoast.showToast(
        msg: "Notification Permissions Not Granted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
      // permission_handler.openAppSettings();
    }
  }

  void _initializeNotifications() async {
    /// await getWeather();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
      await selectNotification(response.payload);
    });
    showNotification();
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    // Handle the notification action like opening the app, etc.
  }

  Future<void> showNotification() async {
    if (isHourlyNotificationEnabled) {
      // double temperature = this.temperature!;
      // String? city = name;
      var time = Time(8, 0, 0); // 8:00:00 am

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('weather_channel_id', 'weather_channel',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher');

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        '${isCelsius ? temperature?.round() : (temperature! * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'} in $city',
        '$description',
        RepeatInterval.hourly,
        platformChannelSpecifics,
        payload: 'Weather Notification',
        //icon: '@mipmap/your_icon_name',
      );
    } else {
      // Cancel the hourly notification if it's not enabled
      await flutterLocalNotificationsPlugin.cancel(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.gps_fixed),
            onPressed: () async {
              await getLocation();
              // city = null;
              name = null;
              updateWeatherWithCurrentLocation();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                searchBarVisible = true;
                _saveLastSearchedCity('');
                // latitude = null;
                // longitude = null;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                // minati add here shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
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
              title: Text('Hourly Weather Forecast',
                  style: TextStyle(fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Icon(Icons.access_time),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HourlyForecastPage(
                      lat: lat,
                      lon: lon,
                      apiKey: apiKey,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('7-Day Weather Forecast',
                  style: TextStyle(fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Icon(Icons.wb_sunny_outlined),
              onTap: () {
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
            /* ListTile(
  title: Text('Switch to Light/Dark Mode', style: TextStyle(fontSize: 18)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  leading: Icon(Icons.brightness_6),
  onTap: () {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  },
), */
            ListTile(
              title: Text('Settings', style: TextStyle(fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                          homePageState: this,
                          onSettingsChanged: () => setState(() {}))),
                );
              },
            ),
            ListTile(
              title: Text('About', style: TextStyle(fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (searchBarVisible) ...[
                  AnimatedOpacity(
                    opacity: searchBarVisible ? 1.0 : 0.0,
                    duration: animationDuration,
                    child: Column(
                      children: [
                        TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                              labelText: 'Enter City',
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (String value) {
                            setState(() {
                              city = value;
                              // _saveLastSearchedCity(city!);
                              getWeather();
                              searchBarVisible = false; // hide the search bar
                              name = null;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              city = cityController.text;
                              //  _saveLastSearchedCity(city!);
                              getWeather();
                              searchBarVisible = false; // hide the search bar
                              name = null;
                            });
                          },
                          child: Text('Search'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32))),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
                if (city != null &&
                    city!.isNotEmpty &&
                    name != null &&
                    name!.isNotEmpty &&
                    rsps != '404') ...[
                  Text('$name',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(fontSize: 52)),
                  SizedBox(height: 32),
                  getWeatherIcon(description ?? ''),
                  SizedBox(height: 32),
                  Text(
                      '${isCelsius ? temperature?.round() : (temperature! * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(fontSize: 58)),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'H: ${isCelsius ? highTemp?.round() : (highTemp! * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                          style: TextStyle(fontSize: 17)),
                      SizedBox(width: 16),
                      Text(
                          'L: ${isCelsius ? lowTemp?.round() : (lowTemp! * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                          style: TextStyle(fontSize: 17)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Center(
                      child: Text('$description',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(fontSize: 44),
                          textAlign: TextAlign.center)),
                  SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.all(8),
                        shape: CardTheme.of(context).shape,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Humidity',
                                  style: Theme.of(context).textTheme.headline6),
                              SizedBox(height: 8),
                              Text('$humidity%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.all(8),
                        shape: CardTheme.of(context).shape,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Pressure',
                                  style: Theme.of(context).textTheme.headline6),
                              SizedBox(height: 8),
                              Text(
                                  '${isMillibars ? pressure : (pressure! / 33.864).round()} ${isMillibars ? 'hPa' : 'inHg'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                  Row(children: [
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.all(8),
                        shape: CardTheme.of(context).shape,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Feels like',
                                  style: Theme.of(context).textTheme.headline6),
                              SizedBox(height: 8),
                              Text(
                                  '${isCelsius ? feels_like?.round() : (feels_like! * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Card(
                      margin: EdgeInsets.all(8),
                      shape: CardTheme.of(context).shape,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('AQI',
                                style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: 8),
                            Text('$aqi',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ))
                  ]),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          shape: CardTheme.of(context).shape,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    'Winds (${getCardinalDirection(windDirection)})',
                                    style:
                                        Theme.of(context).textTheme.headline6),
                                SizedBox(height: 8),
                                Text(
                                    '${isKilometersPerHour ? (windSpeed! * 3.6).round() : (windSpeed! * 2.237).round()} ${isKilometersPerHour ? 'km/h' : 'mph'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                //SizedBox(height: 8),
                                // Text('Direction: ${getCardinalDirection(windDirection)}', style:Theme.of(context).textTheme.headline6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: CardTheme.of(context).shape,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Cloudiness',
                                  style: Theme.of(context).textTheme.headline6),
                              SizedBox(height: 8),
                              Text('$cloudCoverage%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          shape: CardTheme.of(context).shape,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.wb_sunny),
                                SizedBox(height: 8),
                                Text('Sunrise',
                                    style:
                                        Theme.of(context).textTheme.headline6),
                                SizedBox(height: 8),
                                Text(
                                    DateFormat('HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            sunrise! * 1000)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          shape: CardTheme.of(context).shape,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.brightness_3),
                                SizedBox(height: 8),
                                Text('Sunset',
                                    style:
                                        Theme.of(context).textTheme.headline6),
                                SizedBox(height: 8),
                                Text(
                                    DateFormat('HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            sunset! * 1000)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ] else ...[
                  if (isLoading != true) ...[
                    // display a message asking the user to enter a city name
                    Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 120),
                            SizedBox(height: 16),
                            Text('Enter a valid city name to get started',
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.center),
                            SizedBox(height: 16),
                            Text('or',
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.center),
                            SizedBox(height: 16),
                            Text(
                                'Use GPS to get weather of your current location',
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.center),
                          ]),
                    )
                  ],
                ],
                if (errorMessage != null)
                  Text('$errorMessage',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                if (isLoading)
                  Container(
                    // color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
