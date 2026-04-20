# Фаза 3 — State Management с Riverpod

**Цель:** построить реактивную архитектуру приложения на Riverpod.

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  hooks_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
```

---

## Архитектура WeatherVibe

```
UI (Widgets)
    ↕ watch/read
Providers (Riverpod)
    ↕ depends on
Repositories (abstract interfaces)
    ↕ implements
Data Sources (API / Cache / Location)
```

**Правило:** виджеты не знают об API. Провайдеры не знают о виджетах.

---

## Задача 3.1 — Замените ручные классы на freezed

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
dev_dependencies:
  freezed: ^2.5.2
  json_serializable: ^6.7.1
```

```dart
// lib/data/models/weather.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required String cityName,
    required double temperature,
    required double feelsLike,
    required int humidity,
    required double windSpeed,
    required String condition,
    required String description,
    required DateTime date,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
}

// Запустите: dart run build_runner build
// Сравните с тем, что писали вручную в Фазе 1 — заметьте разницу
```

Создайте также:

```dart
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
```

---

## Задача 3.2 — Repository pattern

```dart
// lib/data/repositories/weather_repository.dart

abstract interface class WeatherRepository {
  Future<Result<Weather>> getCurrentWeather(String city);
  Future<Result<List<ForecastDay>>> getForecast(String city);
  Future<Result<List<HourlyWeather>>> getHourlyForecast(String city);
  Future<Result<List<String>>> searchCities(String query);
  Future<Result<Weather>> getWeatherByLocation(double lat, double lon);
}
```

```dart
// lib/data/repositories/weather_repository_impl.dart

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiSource _apiSource;
  final WeatherCacheSource _cacheSource;

  const WeatherRepositoryImpl(this._apiSource, this._cacheSource);

  @override
  Future<Result<Weather>> getCurrentWeather(String city) async {
    // Стратегия: cache-first с TTL 10 минут
    // 1. Проверить кэш
    // 2. Если свежий (< 10 мин) — вернуть кэш
    // 3. Если устаревший — запросить API, обновить кэш, вернуть
    // 4. Если API недоступен — вернуть устаревший кэш с флагом
    // 5. Если кэша нет и API недоступен — Failure
  }
}
```

---

## Задача 3.3 — Providers

```dart
// lib/presentation/providers/weather_providers.dart

// 1. Провайдер репозитория (singleton)
@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  return WeatherRepositoryImpl(
    ref.watch(weatherApiSourceProvider),
    ref.watch(weatherCacheSourceProvider),
  );
}

// 2. Текущий выбранный город
@riverpod
class SelectedCity extends _$SelectedCity {
  @override
  String build() => 'Moscow'; // дефолт

  void setCity(String city) => state = city;
}

// 3. Список сохранённых городов
@riverpod
class SavedCities extends _$SavedCities {
  @override
  List<String> build() => ['Moscow', 'London', 'New York'];

  void addCity(String city) {
    if (!state.contains(city)) {
      state = [city, ...state]; // новый город первым
    }
  }

  void removeCity(String city) {
    state = state.where((c) => c != city).toList();
  }
}

// 4. Погода для текущего города (зависит от selectedCity)
@riverpod
Future<Weather> currentWeather(CurrentWeatherRef ref) async {
  final city = ref.watch(selectedCityProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  
  final result = await repo.getCurrentWeather(city);
  return switch (result) {
    Success(data: final w) => w,
    Failure(message: final m) => throw WeatherException(m),
  };
}

// 5. Прогноз (keepAlive чтобы не перегружать при переходах)
@Riverpod(keepAlive: false)
Future<List<ForecastDay>> forecast(ForecastRef ref) async {
  final city = ref.watch(selectedCityProvider);
  // ...
}
```

---

## Задача 3.4 — Подключите провайдеры к UI

```dart
// Замените FutureBuilder на ConsumerWidget

class WeatherHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    
    return weatherAsync.when(
      loading: () => const WeatherLoadingView(),
      error: (e, st) => WeatherErrorView(error: e, onRetry: () {
        ref.invalidate(currentWeatherProvider);
      }),
      data: (weather) => WeatherLoadedView(weather: weather),
    );
  }
}
```

**Задача:** создайте `WeatherLoadingView` с skeleton анимацией (shimmer эффект):

```dart
// Shimmer эффект без пакетов:
// AnimationController 0→1, repeat
// ShaderMask с LinearGradient который сдвигается
// Контейнеры-заглушки с BorderRadius
```

---

## Задача 3.5 — Множественные города

```dart
// WeatherCard для списка городов
// Каждая карточка сама загружает свою погоду через провайдер с параметром:

@riverpod
Future<Weather> cityWeather(CityWeatherRef ref, String city) async {
  // параметр city — автоматически создаёт отдельный экземпляр провайдера
  // для каждого города
}

// В виджете:
class CityWeatherCard extends ConsumerWidget {
  final String city;
  
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(cityWeatherProvider(city));
    // ...
  }
}
```

---

## Задача 3.6 — Управление темой

```dart
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    // TODO: загрузите сохранённое значение из SharedPreferences
    return ThemeMode.dark;
  }

  Future<void> toggle() async {
    // TODO: переключите и сохраните в SharedPreferences
  }
}

// Задача: сделайте автоматическое переключение на светлую тему
// когда condition == 'snow' и isDay == true
```

---

## Задача 3.7 — Debounce для поиска

```dart
// Поиск не должен стрелять на каждый символ

@riverpod
class CitySearchQuery extends _$CitySearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<String>> citySearchResults(CitySearchResultsRef ref) async {
  final query = ref.watch(citySearchQueryProvider);
  
  // Debounce 500ms — не делайте запрос пока пользователь печатает
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Проверьте, не устарел ли запрос (ref.state может смениться)
  if (ref.state.isRefreshing) return [];
  if (query.length < 2) return [];
  
  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.searchCities(query);
  return switch (result) {
    Success(data: final cities) => cities,
    Failure() => [],
  };
}
```

---

## Чеклист Фазы 3

- [ ] Все модели переведены на freezed
- [ ] WeatherRepository абстрактный интерфейс
- [ ] Провайдеры: selectedCity, savedCities, currentWeather, forecast
- [ ] UI использует ConsumerWidget, нет FutureBuilder
- [ ] Shimmer loading state
- [ ] Поиск с debounce
- [ ] Тема сохраняется между сессиями
- [ ] `dart run build_runner build` — 0 ошибок
