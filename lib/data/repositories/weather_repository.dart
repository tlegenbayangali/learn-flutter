import 'package:flutter_application_1/core/errors/result.dart';
import 'package:flutter_application_1/data/models/forecast.dart';
import 'package:flutter_application_1/data/models/weather.dart';

abstract interface class WeatherRepository {
  Future<Result<Weather>> getCurrentWeather(String city);
  Future<Result<List<ForecastDay>>> getForecast(String city);
  Future<Result<List<HourlyWeather>>> getHourlyForecast(String city);
  Future<Result<List<String>>> searchCities(String query);
  Future<Result<Weather>> getWeatherByLocation(double lat, double lon);
}
