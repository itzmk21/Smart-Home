import 'dart:convert';

import 'package:http/http.dart' as http;

class Weather {
  final num temp;
  final String weather;
  final String icon;

  const Weather({
    required this.temp,
    required this.weather,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: json['main']['temp'],
      weather: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}

Future<Weather> fetchWeather() async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?appid=appid&units=metric&q=City,Country'));

  return Weather.fromJson(jsonDecode(response.body));
}
