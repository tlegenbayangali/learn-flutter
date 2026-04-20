import 'package:flutter_application_1/data/models/weather_condition.dart';

extension WeatherConditionX on String {
  WeatherCondition toWeatherCondition() {
    return WeatherCondition.fromString(this);
  }
}

extension TemperatureX on double {
  String toCelsius() => '${toStringAsFixed(1)}°C';
  String toFahrenheit() => '${((this * 9 / 5) + 32).toStringAsFixed(1)}°F';
}

extension DateTimeX on DateTime {
  String toWeekday() {
    if (isToday) return 'Сегодня';
    if (isTomorrow) return 'Завтра';
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[weekday - 1];
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
}
