import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiProvider {
  static final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<dynamic> getWeatherDataByLocation(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=${dotenv.env['API_KEY']}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
