class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity ;
  final double windSpeed;
  final int sunset ;
  final int sunrise;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.sunset,
    required this.sunrise,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble() - 273.15,
      description: json['weather'][0]['description'] as String, // weather is an array
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      sunset: json['sys']['sunset'] as int,
      sunrise: json['sys']['sunrise'] as int,
    );
  }
}