import 'package:windy/api_provider.dart';

class WeatherRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<dynamic> getWeatherDataByLocation(double lat, double lon) async {
    final weatherData = await _apiProvider.getWeatherDataByLocation(lat, lon);
    return weatherData;
  }
}
