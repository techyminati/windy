import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:windy/weather_repository.dart';
import 'package:geolocator/geolocator.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial());

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    if (event is GetWeatherData) {
      yield* _mapGetWeatherDataToState(event);
    }
  }

  Stream<WeatherState> _mapGetWeatherDataToState(GetWeatherData event) async* {
    yield WeatherLoading();
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final weatherData = await weatherRepository
          .getWeatherDataByLocation(position.latitude, position.longitude);

      yield WeatherLoaded(weatherData: weatherData);
    } catch (e) {
      yield WeatherError(error: e.toString());
    }
  }
}
