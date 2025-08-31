import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherServices {
  final String apiKey = 'b6016dc68f8bb830ce549342061b3ed8';
  
  Future<Weather?> fetchWeather(String cityName) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
      
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}