# Фаза 5 — Тестирование

**Цель:** покрыть критические части приложения тестами.

**Принцип:** не нужно 100% coverage. Тестируйте то, что сломается незаметно.

---

## Что тестировать в WeatherVibe

| Приоритет | Что | Тип теста |
|-----------|-----|-----------|
| Высокий | fromJson / toJson моделей | Unit |
| Высокий | WeatherRepository логика кэша | Unit |
| Высокий | WeatherCondition.fromString | Unit |
| Средний | Провайдеры с моком репозитория | Unit |
| Средний | WeatherHomePage отображение данных | Widget |
| Средний | GlassCard рендер | Widget |
| Низкий | Поиск города flow | Integration |

---

## Задача 5.1 — Unit тесты моделей

```dart
// test/data/models/weather_test.dart

void main() {
  group('Weather', () {
    final validJson = {
      'name': 'Moscow',
      'main': {
        'temp': 22.5,
        'feels_like': 21.0,
        'humidity': 65,
      },
      'wind': {'speed': 3.2},
      'weather': [{'main': 'Clear', 'description': 'ясно'}],
      'dt': 1700000000,
    };

    test('fromJson creates valid Weather', () {
      final weather = Weather.fromJson(validJson);
      expect(weather.cityName, 'Moscow');
      expect(weather.temperature, 22.5);
      expect(weather.condition, 'Clear');
    });

    test('fromJson throws on missing required field', () {
      final invalidJson = Map.of(validJson)..remove('main');
      expect(() => Weather.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });

    test('copyWith preserves unchanged fields', () {
      final original = Weather.fromJson(validJson);
      final modified = original.copyWith(temperature: 30.0);
      expect(modified.temperature, 30.0);
      expect(modified.cityName, original.cityName);
    });

    test('equality works correctly', () {
      final w1 = Weather.fromJson(validJson);
      final w2 = Weather.fromJson(validJson);
      expect(w1, equals(w2));
    });
  });

  group('WeatherCondition', () {
    test('fromString maps known conditions', () {
      expect(WeatherCondition.fromString('Clear'), WeatherCondition.clear);
      expect(WeatherCondition.fromString('Rain'), WeatherCondition.rain);
      expect(WeatherCondition.fromString('Snow'), WeatherCondition.snow);
    });

    test('fromString is case insensitive', () {
      expect(WeatherCondition.fromString('CLEAR'), WeatherCondition.clear);
      expect(WeatherCondition.fromString('clear'), WeatherCondition.clear);
    });

    test('fromString returns mist for unknown condition', () {
      expect(WeatherCondition.fromString('Unknown'), WeatherCondition.mist);
    });
  });
}
```

---

## Задача 5.2 — Тест репозитория с мок-источниками

```yaml
dev_dependencies:
  mocktail: ^1.0.4
```

```dart
// test/data/repositories/weather_repository_test.dart

class MockApiSource extends Mock implements WeatherApiSource {}
class MockCacheSource extends Mock implements WeatherCacheSource {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockApiSource mockApi;
  late MockCacheSource mockCache;

  setUp(() {
    mockApi = MockApiSource();
    mockCache = MockCacheSource();
    repository = WeatherRepositoryImpl(mockApi, mockCache);
  });

  group('getCurrentWeather', () {
    const city = 'London';
    final weather = Weather(
      cityName: city,
      temperature: 15.0,
      feelsLike: 13.0,
      humidity: 80,
      windSpeed: 5.0,
      condition: 'Clouds',
      description: 'облачно',
      date: DateTime(2024, 1, 1),
    );

    test('returns cached data when fresh cache exists', () async {
      when(() => mockCache.hasFreshCache(city)).thenReturn(true);
      when(() => mockCache.getCachedWeather(city)).thenReturn(weather);

      final result = await repository.getCurrentWeather(city);

      expect(result, isA<Success<Weather>>());
      verifyNever(() => mockApi.getCurrentWeather(any()));
    });

    test('fetches from API when cache is stale', () async {
      when(() => mockCache.hasFreshCache(city)).thenReturn(false);
      when(() => mockCache.getCachedWeather(city)).thenReturn(null);
      when(() => mockApi.getCurrentWeather(city))
          .thenAnswer((_) async => Success(weather));
      when(() => mockCache.saveWeather(city, weather))
          .thenAnswer((_) async {});

      final result = await repository.getCurrentWeather(city);

      expect(result, isA<Success<Weather>>());
      verify(() => mockApi.getCurrentWeather(city)).called(1);
      verify(() => mockCache.saveWeather(city, weather)).called(1);
    });

    test('returns stale cache when API fails', () async {
      when(() => mockCache.hasFreshCache(city)).thenReturn(false);
      when(() => mockCache.getCachedWeather(city)).thenReturn(weather);
      when(() => mockApi.getCurrentWeather(city))
          .thenAnswer((_) async => const Failure('Network error'));

      final result = await repository.getCurrentWeather(city);

      // Должен вернуть устаревший кэш, не Failure
      expect(result, isA<Success<Weather>>());
    });

    test('returns Failure when no cache and API fails', () async {
      when(() => mockCache.hasFreshCache(city)).thenReturn(false);
      when(() => mockCache.getCachedWeather(city)).thenReturn(null);
      when(() => mockApi.getCurrentWeather(city))
          .thenAnswer((_) async => const Failure('Network error'));

      final result = await repository.getCurrentWeather(city);

      expect(result, isA<Failure<Weather>>());
    });
  });
}
```

---

## Задача 5.3 — Тест Riverpod провайдеров

```dart
// test/presentation/providers/weather_providers_test.dart

void main() {
  late ProviderContainer container;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('currentWeatherProvider returns weather for selected city', () async {
    const city = 'Moscow';
    final weather = buildTestWeather(city: city);

    when(() => mockRepository.getCurrentWeather(city))
        .thenAnswer((_) async => Success(weather));

    container.read(selectedCityProvider.notifier).setCity(city);

    final result = await container.read(currentWeatherProvider.future);
    expect(result.cityName, city);
  });

  test('currentWeatherProvider refreshes when city changes', () async {
    final weather1 = buildTestWeather(city: 'Moscow');
    final weather2 = buildTestWeather(city: 'London');

    when(() => mockRepository.getCurrentWeather('Moscow'))
        .thenAnswer((_) async => Success(weather1));
    when(() => mockRepository.getCurrentWeather('London'))
        .thenAnswer((_) async => Success(weather2));

    container.read(selectedCityProvider.notifier).setCity('Moscow');
    await container.read(currentWeatherProvider.future);

    container.read(selectedCityProvider.notifier).setCity('London');
    final result = await container.read(currentWeatherProvider.future);

    expect(result.cityName, 'London');
  });
}

// Фабрика тестовых данных:
Weather buildTestWeather({String city = 'TestCity', double temp = 20.0}) {
  return Weather(
    cityName: city,
    temperature: temp,
    feelsLike: temp - 2,
    humidity: 60,
    windSpeed: 3.0,
    condition: 'Clear',
    description: 'ясно',
    date: DateTime(2024, 1, 1),
  );
}
```

---

## Задача 5.4 — Widget тесты

```dart
// test/presentation/widgets/glass_card_test.dart

void main() {
  testWidgets('GlassCard renders child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(child: Text('test')),
        ),
      ),
    );

    expect(find.text('test'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);
  });

  testWidgets('GlassCard calls onTap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassCard(
            onTap: () => tapped = true,
            child: const Text('tap me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('tap me'));
    expect(tapped, isTrue);
  });
}

// test/presentation/pages/weather_home_page_test.dart

void main() {
  testWidgets('shows loading state', (tester) async {
    final container = ProviderContainer(
      overrides: [
        currentWeatherProvider.overrideWith((ref) async {
          await Future.delayed(const Duration(seconds: 1));
          return buildTestWeather();
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: WeatherHomePage()),
      ),
    );

    expect(find.byType(WeatherLoadingView), findsOneWidget);
  });

  testWidgets('shows weather data', (tester) async {
    final weather = buildTestWeather(city: 'Moscow', temp: 25.0);
    final container = ProviderContainer(
      overrides: [
        currentWeatherProvider.overrideWith((_) async => weather),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: WeatherHomePage()),
      ),
    );

    await tester.pump(); // начало загрузки
    await tester.pumpAndSettle(); // завершение

    expect(find.text('Moscow'), findsOneWidget);
    expect(find.textContaining('25'), findsWidgets);
  });
}
```

---

## Чеклист Фазы 5

- [ ] Weather.fromJson тестирован (valid, invalid, edge cases)
- [ ] WeatherCondition.fromString тестирован
- [ ] Репозиторий: все 4 сценария кэша покрыты
- [ ] Провайдеры тестированы с моком
- [ ] GlassCard widget тест
- [ ] WeatherHomePage: loading/error/data states
- [ ] `flutter test` — все тесты зелёные
- [ ] Coverage > 70% для data/ слоя
