class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
