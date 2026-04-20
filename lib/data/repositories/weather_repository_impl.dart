import 'package:flutter_application_1/core/errors/result.dart';
import 'package:flutter_application_1/data/models/forecast.dart';
import 'package:flutter_application_1/data/models/weather.dart';
import 'package:flutter_application_1/data/repositories/weather_repository.dart';

// Временная мок-реализация — в Фазе 4 заменим на реальный API
class MockWeatherRepository implements WeatherRepository {
  @override
  Future<Result<Weather>> getCurrentWeather(String city) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (city.isEmpty) return const Failure('Город не указан');
    if (city.toLowerCase() == 'error') return const Failure('Ошибка сети');

    return Success(Weather(
      cityName: city,
      temperature: 22.5,
      feelsLike: 21.0,
      humidity: 60,
      windSpeed: 5.4,
      condition: 'clear',
      description: 'ясное небо',
      date: DateTime.now(),
    ));
  }

  @override
  Future<Result<List<ForecastDay>>> getForecast(String city) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final today = DateTime.now();
    final conditions = ['clear', 'clouds', 'rain', 'thunderstorm', 'clouds', 'clear', 'clear'];
    final mins = [18.0, 15.0, 12.0, 11.0, 14.0, 17.0, 19.0];
    final maxs = [24.0, 21.0, 16.0, 14.0, 19.0, 23.0, 25.0];
    return Success(List.generate(7, (i) => ForecastDay(
      date: today.add(Duration(days: i)),
      tempMin: mins[i],
      tempMax: maxs[i],
      condition: conditions[i],
    )));
  }

  @override
  Future<Result<List<HourlyWeather>>> getHourlyForecast(String city) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final conditions = ['clear', 'clear', 'clouds', 'clouds', 'rain', 'rain', 'clouds', 'clear'];
    final temps = [22.5, 23.1, 22.0, 20.5, 18.0, 17.5, 19.0, 21.0];
    return Success(List.generate(8, (i) => HourlyWeather(
      time: now.add(Duration(hours: i)),
      temperature: temps[i],
      condition: conditions[i],
    )));
  }

  @override
  Future<Result<List<String>>> searchCities(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    const all = [
      'London', 'Los Angeles', 'Lisbon',
      'New York', 'New Delhi',
      'Tokyo', 'Toronto', 'Tashkent',
      'Paris', 'Prague',
      'Berlin', 'Barcelona', 'Bangkok',
      'Moscow', 'Madrid', 'Milan',
      'Dubai', 'Dublin',
      'Singapore', 'Sydney', 'Seoul',
      'Almaty', 'Amsterdam', 'Athens',
    ];
    final q = query.toLowerCase();
    return Success(all.where((c) => c.toLowerCase().contains(q)).toList());
  }

  @override
  Future<Result<Weather>> getWeatherByLocation(double lat, double lon) async {
    return getCurrentWeather('My Location');
  }
}
