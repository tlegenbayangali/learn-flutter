# Фаза 1 — Dart + Структура проекта

**Цель:** написать скелет приложения и освоить Dart через задачи, напрямую связанные с WeatherVibe.

---

## Задача 1.1 — Настройка проекта

```bash
flutter create weather_vibe --org com.yourname
cd weather_vibe
```

Создайте структуру папок:

```
lib/
  core/
    constants/
    errors/
    utils/
  data/
    models/
    repositories/
    sources/
  presentation/
    pages/
    widgets/
    providers/
  app.dart
  main.dart
```

**Почему такая структура:** feature-first или layer-first — оба варианта работают, но layer-first проще для одного разработчика на старте.

---

## Задача 1.2 — Модели данных (Dart классы)

Без пакетов — только чистый Dart. Напишите классы вручную:

```dart
// lib/data/models/weather.dart
class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;   // "clear", "rain", "snow", "clouds", "thunderstorm"
  final String description;
  final DateTime date;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.date,
  });

  // TODO: добавьте copyWith вручную
  // TODO: добавьте fromJson(Map<String, dynamic> json)
  // TODO: добавьте toJson()
  // TODO: переопределите == и hashCode
  // TODO: переопределите toString()
}
```

**Упражнение:** напишите все методы вручную. Потом в Фазе 3 заменим на `freezed` — и сразу поймёте, зачем он нужен.

---

## Задача 1.3 — Null safety и работа с данными

```dart
// Напишите функцию, которая:
// 1. Принимает nullable температуру
// 2. Конвертирует Цельсий → Фаренгейт (если не null)
// 3. Возвращает форматированную строку или "N/A"

String formatTemperature(double? celsius, {bool fahrenheit = false}) {
  // TODO
}

// Тест:
assert(formatTemperature(null) == "N/A");
assert(formatTemperature(25) == "25°C");
assert(formatTemperature(0, fahrenheit: true) == "32°F");
```

---

## Задача 1.4 — Enums с методами

В Flutter/Dart enums могут иметь методы и поля:

```dart
enum WeatherCondition {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist;

  String get emoji {
    // TODO: верните эмодзи для каждого условия
    // clear → ☀️, clouds → ☁️, rain → 🌧️ ...
  }

  String get label {
    // TODO: верните название на русском
  }

  // TODO: добавьте статический метод fromString(String value)
  // который маппит строку из API ("Clear", "Rain") → enum
}
```

---

## Задача 1.5 — Async/await и обработка ошибок

```dart
// Симулируйте сетевой запрос:
Future<Weather?> fetchWeatherMock(String city) async {
  await Future.delayed(const Duration(seconds: 1));
  
  if (city.isEmpty) throw ArgumentError('City cannot be empty');
  if (city == 'error') throw Exception('Network error');
  
  return Weather(
    cityName: city,
    temperature: 22.5,
    // ... остальные поля
  );
}

// Напишите обёртку с обработкой ошибок:
// Должна возвращать Either<AppError, Weather> 
// (используйте свой класс Result<T>, без сторонних пакетов)
```

**Создайте `lib/core/errors/result.dart`:**

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}

// Использование:
// final result = await fetchWeather('London');
// switch (result) {
//   case Success(data: final w) => print(w.temperature),
//   case Failure(message: final m) => print(m),
// }
```

---

## Задача 1.6 — Extensions

```dart
// lib/core/utils/weather_extensions.dart

extension WeatherConditionX on String {
  WeatherCondition toWeatherCondition() {
    // TODO: распарсите строку из API в enum
  }
}

extension TemperatureX on double {
  String toCelsius() => '${toStringAsFixed(1)}°C';
  String toFahrenheit() => '${((this * 9 / 5) + 32).toStringAsFixed(1)}°F';
}

extension DateTimeX on DateTime {
  String toWeekday() {
    // TODO: верните "Пн", "Вт", "Ср"... или "Сегодня" / "Завтра"
  }
  
  bool get isToday => /* TODO */;
  bool get isTomorrow => /* TODO */;
}
```

---

## Задача 1.7 — Первый экран (без дизайна)

Сделайте рабочий, но некрасивый экран — просто чтобы проверить данные:

```dart
// lib/presentation/pages/home_page.dart
// Требования:
// - FutureBuilder с fetchWeatherMock('London')
// - Показывает температуру, город, условие
// - Loading indicator пока грузит
// - Текст ошибки если что-то пошло не так
// - Кнопка "обновить"
```

---

## Чеклист Фазы 1

- [ ] Структура папок создана
- [ ] Класс Weather с fromJson / toJson / copyWith / == / hashCode
- [ ] Enum WeatherCondition с методами
- [ ] Result<T> sealed class
- [ ] Extensions на String, double, DateTime
- [ ] Первый экран работает с моковыми данными
- [ ] `flutter analyze` — 0 warnings
