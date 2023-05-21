import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
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
  static final GlobalKey<_MyHomePageState> _key = GlobalKey<_MyHomePageState>();

  static _MyHomePageState? of(BuildContext context) => _key.currentState;

  @override
  _MyHomePageState createState() => _MyHomePageState();
 late final String title;

 // @override
 // _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
 String apiKey = '';
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
 int? cloudCoverage;
 TextEditingController cityController = TextEditingController();
 String? errorMessage;
 bool searchBarVisible = false;
 double? windSpeed;
 int? windDirection;
 Duration animationDuration = Duration(milliseconds: 950);
 final ScrollController _scrollController = ScrollController();
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

bool _serviceEnabled=false;
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
      return;
    }
  }

  _locationData = await location.getLocation();
}


String toTitleCase(String text) {
  return text
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

 void getWeather() async {
    if (city == null || city!.trim().isEmpty) {
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
 highTemp = data['main']['temp_max']; 
 lowTemp = data['main']['temp_min'];

 
 errorMessage = null;
      HomeWidget.saveWidgetData('temperature', temperature);
      HomeWidget.saveWidgetData('description', description);
      HomeWidget.saveWidgetData('humidity', humidity);
      HomeWidget.saveWidgetData('pressure', pressure);
      HomeWidget.saveWidgetData('feels_like', feels_like);
      HomeWidget.saveWidgetData('country', country);
      HomeWidget.saveWidgetData('sunrise', sunrise);
      HomeWidget.saveWidgetData('sunset', sunset);
      HomeWidget.saveWidgetData('city', city);
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
 
 Future<void> _handleRefresh() async {
  // Refresh the weather data
  getWeather();
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
  DateTime now = DateTime.now();
  bool isDaytime = now.isAfter(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000)) &&
      now.isBefore(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000));

  if (description.contains('Rain') || description.contains('Moderate Rain') || description.contains('Light Rain')) {
    return BoxedIcon(WeatherIcons.rain, size: 127);
  } else if (description.contains('Cloud') || description.contains('overcast Clouds') || description.contains('Scattered Clouds')) {
    return BoxedIcon(isDaytime ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy, size: 127);
  } else if (description.contains('Wind')) {
    return BoxedIcon(WeatherIcons.strong_wind, size: 127);
  } else if (description.contains('Snow')) {
    return BoxedIcon(WeatherIcons.snow, size: 127);
  } else if (description.contains('Haze')) {
    return BoxedIcon(isDaytime ? WeatherIcons.day_haze : WeatherIcons.night_fog, size: 127);
  } else if (description.contains('Thunderstorm')) {
    return BoxedIcon(WeatherIcons.thunderstorm, size: 127);
  } else if (description.contains('Drizzle')) {
    return BoxedIcon(WeatherIcons.sprinkle, size: 127);
  } else if (description.contains('Fog')) {
    return BoxedIcon(isDaytime ? WeatherIcons.day_fog : WeatherIcons.night_fog, size: 127);
  } else if (description.contains('Mist')) {
    return BoxedIcon(isDaytime ? WeatherIcons.day_fog : WeatherIcons.night_fog, size: 127);
  } else if (description.contains('Smoke')) {
    return BoxedIcon(WeatherIcons.smoke, size: 127);
  } else if (description.contains('Dust')) {
    return BoxedIcon(WeatherIcons.dust, size: 127);
  } else if (description.contains('Sand')) {
    return BoxedIcon(WeatherIcons.sandstorm, size: 127);
  } else if (description.contains('Ash')) {
    return BoxedIcon(WeatherIcons.volcano, size: 127);
  } else if (description.contains('Squall')) {
    return BoxedIcon(WeatherIcons.strong_wind, size: 127);
  } else if (description.contains('Tornado')) {
    return BoxedIcon(WeatherIcons.tornado, size: 127);
  } else if (description.contains('Clear Sky') || description.contains('Sun')) { // changed from 'sun' to 'clear sky'
    return BoxedIcon(isDaytime ? WeatherIcons.day_sunny : WeatherIcons.night_clear, size: 127);
   }
   else {
     return BoxedIcon(isDaytime ? WeatherIcons.day_sunny_overcast : WeatherIcons.night_alt_partly_cloudy, size: 127);
   }
}



@override
void initState() {
  super.initState();
  _getLastSearchedCity();
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
}


@override
Widget build(BuildContext context) {
  return Scaffold(
         // extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text(widget.title),
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              searchBarVisible = true;
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
        title: Text('7-Day Weather Forecast', style: TextStyle(fontSize: 18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ListTile(
        title: Text('About', style: TextStyle(fontSize: 18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        decoration:
                            InputDecoration(labelText:
'Enter City', filled: true, border:
OutlineInputBorder(borderRadius:
BorderRadius.circular(32))),

                        textCapitalization:
TextCapitalization.words,
                        onSubmitted:
(String value) {
                          setState(() {
                            city = value;
                            _saveLastSearchedCity(city!);
                            getWeather();
                            searchBarVisible =
false; // hide the search bar
                          });
                        },
                      ),
                      SizedBox(height:
16),
                      ElevatedButton(
                        onPressed:
() {
                          setState(() {
                            city = cityController.text;
                            _saveLastSearchedCity(city!);
                            getWeather();
                            searchBarVisible =
false; // hide the search bar
                          });
                        },
                        child:
Text('Search'),
                        style:
ElevatedButton.styleFrom(shape:
RoundedRectangleBorder(borderRadius:
BorderRadius.circular(32))),
                      ),
                      SizedBox(height:
32),
                    ],
                  ),
                ),
              ],
              if (city != null && city!.isNotEmpty && name != null && name!.isNotEmpty) ...[
                Text('$name', style:
Theme.of(context).textTheme.headline4?.copyWith(fontSize:
52)),
                SizedBox(height:
32),
                getWeatherIcon(description ?? ''),
                SizedBox(height:
32),
                Text('${temperature?.round()}°C', style:
Theme.of(context).textTheme.headline4?.copyWith(fontSize:
58)),
/*
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('H: ${highTemp?.round()}°C', style: TextStyle(fontSize: 18)),
    SizedBox(width: 16),
    Text('L: ${lowTemp?.round()}°C', style: TextStyle(fontSize: 18)),
  ],
), */
                Center(child:
Text('$description', style:
Theme.of(context).textTheme.headline6?.copyWith(fontSize:
44), textAlign:
TextAlign.center)),
SizedBox(height: 22), 
                Row(children:[
                  Expanded(child:
Card(margin:
EdgeInsets.all(8), 
shape: CardTheme.of(context).shape,
child:
Padding(padding:
EdgeInsets.all(16), child:
Column(crossAxisAlignment:
CrossAxisAlignment.center, children:[
Text('Humidity', style:
Theme.of(context).textTheme.headline6),
SizedBox(height:
8),
Text('$humidity%', style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),
],),),),),
                  Expanded(child:
Card(margin: EdgeInsets.all(8),
shape: CardTheme.of(context).shape,child: 
Padding(padding: EdgeInsets.all(16),child:
Column(crossAxisAlignment:
CrossAxisAlignment.center,children:[
Text('Pressure',style:
Theme.of(context).textTheme.headline6),SizedBox(height:
8),Text('$pressure hPa',style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),],),),),)
                ]),
                Row(children:[
                  Expanded(child:
Card(margin:
EdgeInsets.all(8),
shape: CardTheme.of(context).shape,child:
Padding(padding:
EdgeInsets.all(16),child:
Column(crossAxisAlignment:
CrossAxisAlignment.center,children:[
Text('Feels like',style:
Theme.of(context).textTheme.headline6),SizedBox(height:
8),Text('${feels_like?.round()}°C',style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),],),),),),
                  Expanded(child:
Card(margin:
EdgeInsets.all(8),
shape: CardTheme.of(context).shape,child:
Padding(padding: 
EdgeInsets.all(16),child: 
Column(crossAxisAlignment: 
CrossAxisAlignment.center,children:[
Text('AQI',style: 
Theme.of(context).textTheme.headline6),SizedBox(height: 
8),Text('$aqi',style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),],
),),))

                ]),
                Row(
  children: [
    Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: CardTheme.of(context).shape,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Winds (${getCardinalDirection(windDirection)})', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8),
              Text('${(windSpeed! * 3.6).round()} km/h', style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold)),
              //SizedBox(height: 8),
             // Text('Direction: ${getCardinalDirection(windDirection)}', style:Theme.of(context).textTheme.headline6),
            ],
          ),
        ),
      ),
    ),
    Expanded(
      child:
Card(margin:
EdgeInsets.symmetric(horizontal:8, vertical:8),
shape: CardTheme.of(context).shape,
child:
Padding(padding:
EdgeInsets.all(16),child:
Column(crossAxisAlignment:
CrossAxisAlignment.center,children:[
Text('Cloudiness',style:
Theme.of(context).textTheme.headline6),SizedBox(height:
8),Text('$cloudCoverage%',style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),],),),))
  ],
),
          Row(
  children: [
    Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: CardTheme.of(context).shape,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny),
              SizedBox(height: 8),
              Text('Sunrise', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8),
              Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(sunrise! * 1000)), style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ),
    Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: CardTheme.of(context).shape,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.brightness_3),
              SizedBox(height: 8),
              Text('Sunset', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8),
              Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(sunset! * 1000)), style:
Theme.of(context).textTheme.headline5?.copyWith(fontWeight:
FontWeight.bold)),
            ],
          ),
        ),
      ),
    ),
  ],
)

                
              ] else ...[
                // display a message asking the user to enter a city name
                Center(child:
Column(mainAxisAlignment:
MainAxisAlignment.center, children:[
Icon(Icons.search, size:
120),
SizedBox(height:
16),
Text('Enter a valid city name to get started', style:
Theme.of(context).textTheme.headline6, textAlign:
TextAlign.center),
]),)
              ],
              if (errorMessage != null)
                Text('$errorMessage', style:
TextStyle(color:
Colors.red, fontWeight:
FontWeight.bold))
            ],
          ),
        ),
      ),
    ),
  );
}

 }
