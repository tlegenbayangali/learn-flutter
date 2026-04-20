enum WeatherCondition {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist;

  String get emoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.clouds:
        return '☁️';
      case WeatherCondition.rain:
        return '🌧️';
      case WeatherCondition.drizzle:
        return '🌦️';
      case WeatherCondition.thunderstorm:
        return '⛈️';
      case WeatherCondition.snow:
        return '❄️';
      case WeatherCondition.mist:
        return '🌫️';
    }
  }

  String get label {
    switch (this) {
      case WeatherCondition.clear:
        return 'Ясно';
      case WeatherCondition.clouds:
        return 'Облачно';
      case WeatherCondition.rain:
        return 'Дождь';
      case WeatherCondition.drizzle:
        return 'Морось';
      case WeatherCondition.thunderstorm:
        return 'Гроза';
      case WeatherCondition.snow:
        return 'Снег';
      case WeatherCondition.mist:
        return 'Туман';
    }
  }

  // Маппинг строки из API ("Clear", "Rain") → enum
  static WeatherCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'clear':
        return WeatherCondition.clear;
      case 'clouds':
        return WeatherCondition.clouds;
      case 'rain':
        return WeatherCondition.rain;
      case 'drizzle':
        return WeatherCondition.drizzle;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snow;
      case 'mist':
      case 'fog':
      case 'haze':
        return WeatherCondition.mist;
      default:
        return WeatherCondition.clear;
    }
  }
}
