import 'package:freezed_annotation/freezed_annotation.dart';

part 'forecast.freezed.dart';
part 'forecast.g.dart';

@freezed
class ForecastDay with _$ForecastDay {
  const factory ForecastDay({
    required DateTime date,
    required double tempMax,
    required double tempMin,
    required String condition,
  }) = _ForecastDay;

  factory ForecastDay.fromJson(Map<String, dynamic> json) => _$ForecastDayFromJson(json);
}

@freezed
class HourlyWeather with _$HourlyWeather {
  const factory HourlyWeather({
    required DateTime time,
    required double temperature,
    required String condition,
  }) = _HourlyWeather;

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => _$HourlyWeatherFromJson(json);
}
