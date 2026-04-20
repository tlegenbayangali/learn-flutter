# Фаза 4 — Backend, API, Кэш, Локация

**Цель:** подключить реальное API, добавить офлайн-кэш и геолокацию.

---

## Задача 4.1 — Настройка Dio с interceptors

```dart
// lib/data/sources/weather_api_source.dart

class WeatherApiSource {
  late final Dio _dio;
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherApiSource() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.addAll([
      _ApiKeyInterceptor(),    // добавляет appid ко всем запросам
      _LoggingInterceptor(),   // логи в debug режиме
      _RetryInterceptor(),     // 3 попытки при сетевых ошибках
    ]);
  }
}

// _ApiKeyInterceptor
class _ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['appid'] = Env.weatherApiKey; // из .env
    options.queryParameters['units'] = 'metric';
    options.queryParameters['lang'] = 'ru';
    handler.next(options);
  }
}

// _RetryInterceptor
class _RetryInterceptor extends Interceptor {
  int _retryCount = 0;
  static const _maxRetries = 3;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_retryCount < _maxRetries && _shouldRetry(err)) {
      _retryCount++;
      await Future.delayed(Duration(seconds: _retryCount)); // exponential backoff
      try {
        final response = await err.requestOptions.sendRequest(); // TODO
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      _retryCount = 0;
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      err.response?.statusCode == 503;
}
```

---

## Задача 4.2 — Переменные окружения

**Никогда не храните API ключи в коде!**

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```bash
# .env (добавьте в .gitignore!)
WEATHER_API_KEY=ваш_ключ_здесь
```

```dart
// lib/core/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
}

// main.dart
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: App()));
}
```

```bash
# .gitignore — добавьте:
.env
*.env
```

---

## Задача 4.3 — Реальные API запросы

```dart
// Эндпоинты OpenWeatherMap:
// Текущая погода:  GET /weather?q={city}
// Прогноз 5 дней: GET /forecast?q={city}  (каждые 3 часа, 40 записей)
// Геолокация:     GET /weather?lat={lat}&lon={lon}
// Поиск городов:  GET http://api.openweathermap.org/geo/1.0/direct?q={query}&limit=5

Future<Result<Weather>> getCurrentWeather(String city) async {
  try {
    final response = await _dio.get('/weather', queryParameters: {'q': city});
    final weather = Weather.fromJson(response.data);
    return Success(weather);
  } on DioException catch (e) {
    return Failure(_mapDioError(e));
  }
}

String _mapDioError(DioException e) {
  return switch (e.response?.statusCode) {
    401 => 'Неверный API ключ',
    404 => 'Город не найден',
    429 => 'Превышен лимит запросов',
    503 => 'Сервис недоступен',
    _ => e.type == DioExceptionType.connectionTimeout
        ? 'Нет соединения с интернетом'
        : 'Неизвестная ошибка',
  };
}
```

**Задача:** разберите JSON ответ OpenWeatherMap и напишите `fromJson` для всех моделей.  
Пример ответа: https://openweathermap.org/current#example_JSON

---

## Задача 4.4 — Офлайн кэш с Hive

```yaml
dependencies:
  hive_flutter: ^1.1.0
```

```dart
// lib/data/sources/weather_cache_source.dart

class WeatherCacheSource {
  static const _weatherBox = 'weather_cache';
  static const _ttlMinutes = 10;

  late Box<Map> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_weatherBox);
  }

  Future<void> saveWeather(String city, Weather weather) async {
    await _box.put(city.toLowerCase(), {
      'data': weather.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Weather? getCachedWeather(String city) {
    final cached = _box.get(city.toLowerCase());
    if (cached == null) return null;

    final timestamp = DateTime.parse(cached['timestamp'] as String);
    final age = DateTime.now().difference(timestamp);

    if (age.inMinutes > _ttlMinutes) return null; // устарел

    return Weather.fromJson(Map<String, dynamic>.from(cached['data'] as Map));
  }

  bool hasFreshCache(String city) {
    // TODO
  }

  Future<void> clearAll() => _box.clear();
}
```

---

## Задача 4.5 — Геолокация

```yaml
dependencies:
  geolocator: ^12.0.0
  geocoding: ^3.0.0
```

```dart
// lib/data/sources/location_source.dart

class LocationSource {
  Future<Result<({double lat, double lon})>> getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        return const Failure('Разрешение на геолокацию отклонено');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Failure('Откройте настройки для разрешения геолокации');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // battery friendly
        timeLimit: const Duration(seconds: 5),
      );
      return Success((lat: position.latitude, lon: position.longitude));
    } on TimeoutException {
      return const Failure('Не удалось определить местоположение');
    }
  }
}
```

```dart
// Провайдер для погоды по локации:
@riverpod
Future<Weather> locationWeather(LocationWeatherRef ref) async {
  final locationSource = ref.watch(locationSourceProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  
  final locationResult = await locationSource.getCurrentLocation();
  
  return switch (locationResult) {
    Success(data: final loc) => switch (
      await repo.getWeatherByLocation(loc.lat, loc.lon)
    ) {
      Success(data: final w) => w,
      Failure(message: final m) => throw WeatherException(m),
    },
    Failure(message: final m) => throw LocationException(m),
  };
}
```

**Настройте permissions:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Для показа погоды в вашем городе</string>
```

---

## Задача 4.6 — Connectivity (онлайн/офлайн индикатор)

```yaml
dependencies:
  connectivity_plus: ^6.0.3
```

```dart
@riverpod
Stream<bool> isOnline(IsOnlineRef ref) {
  return Connectivity().onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );
}

// В UI показывайте баннер когда isOnline == false:
// "Офлайн • Данные от XX:XX"
```

---

## Задача 4.7 — Фоновое обновление (необязательно, бонус)

```dart
// Обновляйте кэш в фоне каждые 30 минут когда приложение открыто:
// Используйте Timer.periodic в провайдере
// Не делайте запрос если приложение в фоне (AppLifecycleListener)

@riverpod
class WeatherAutoRefresh extends _$WeatherAutoRefresh {
  Timer? _timer;

  @override
  void build() {
    ref.onDispose(() => _timer?.cancel());
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 30), (_) {
      ref.invalidate(currentWeatherProvider);
    });
  }
}
```

---

## Чеклист Фазы 4

- [ ] Dio настроен с interceptors (auth, logging, retry)
- [ ] API ключ в .env, не в коде
- [ ] Все эндпоинты работают с реальным API
- [ ] Hive кэш с TTL 10 минут
- [ ] Геолокация с обработкой всех permission states
- [ ] Офлайн баннер при потере соединения
- [ ] Приложение работает без интернета (из кэша)
- [ ] Нет API ключей в git истории
