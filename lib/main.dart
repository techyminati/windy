import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:windy/weather_bloc.dart';
import 'package:windy/weather_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository = WeatherRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Windy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => WeatherBloc(weatherRepository: weatherRepository)
          ..add(GetWeatherData()),
        child: WeatherPage(),
      ),
    );
  }
}

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Windy'),
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WeatherLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WeatherLoaded) {
            final weatherData = state.weatherData;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${weatherData['name']}, ${weatherData['sys']['country']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  SvgPicture.network(
                    'https://openweathermap.org/img/w/${weatherData['weather'][0]['icon']}.png',
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${weatherData['weather'][0]['description']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${(weatherData['main']['temp'] - 273.15).toStringAsFixed(0)}°C',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is WeatherError) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
