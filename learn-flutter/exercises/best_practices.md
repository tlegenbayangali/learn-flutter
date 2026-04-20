# Best Practices Flutter — WeatherVibe Edition

---

## 1. Архитектура и структура

### Правило одной ответственности для виджетов
```dart
// ПЛОХО — виджет знает всё
class WeatherPage extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    return Scaffold(
      body: weatherAsync.when(
        data: (w) => Column(children: [
          Text(w.cityName, style: TextStyle(fontSize: 24, ...)),
          // 200 строк вёрстки прямо здесь
        ]),
      ),
    );
  }
}

// ХОРОШО — виджет-оркестратор + маленькие компоненты
class WeatherPage extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(currentWeatherProvider).when(
      loading: () => const WeatherLoadingView(),
      error: (e, _) => WeatherErrorView(error: e),
      data: (w) => WeatherLoadedView(weather: w),
    );
  }
}
```

### Не держите бизнес-логику в виджетах
```dart
// ПЛОХО
class SearchPage extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (q) async {
        if (q.length > 2) {
          final dio = Dio();
          final response = await dio.get('/geo?q=$q');
          // ...
        }
      },
    );
  }
}

// ХОРОШО — логика в провайдере, виджет только вызывает
onChanged: (q) => ref.read(citySearchQueryProvider.notifier).update(q),
```

---

## 2. Производительность

### const везде где возможно
```dart
// Добавьте lint: prefer_const_constructors
// Каждый const = меньше rebuild

// ХОРОШО
const GlassCard(child: Text('hello'))
const EdgeInsets.symmetric(horizontal: 16)
const Color(0xFF7EB8F7)
```

### Используйте RepaintBoundary для анимаций
```dart
// Частицы дождя или Lottie анимация не должны перерисовывать весь экран
RepaintBoundary(
  child: WeatherAnimation(condition: condition),
)
```

### Lazy загрузка списков
```dart
// Для длинных списков всегда используйте builder
ListView.builder(          // не ListView(children: [...])
  itemCount: items.length,
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
)
```

### Избегайте лишних rebuild
```dart
// ПЛОХО — пересобирает весь Consumer при любом изменении
Consumer(builder: (_, ref, __) {
  final weather = ref.watch(currentWeatherProvider);
  final theme = ref.watch(appThemeModeProvider);
  // ...
})

// ХОРОШО — разделите на отдельные Consumer
// или используйте select:
final temperature = ref.watch(
  currentWeatherProvider.select((w) => w.value?.temperature)
);
// rebuild только при изменении temperature, не всей Weather
```

---

## 3. Управление состоянием

### Правило Riverpod: не держите state в провайдере если он нужен только локально
```dart
// Состояние анимации кнопки, фокус, hover — в виджете через useState (hooks)
// Состояние которое нужно нескольким экранам — в провайдере

// hooks_riverpod позволяет:
class WeatherCard extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);    // локальное состояние
    final weather = ref.watch(currentWeatherProvider); // глобальное
    // ...
  }
}
```

### Не злоупотребляйте keepAlive
```dart
// keepAlive: true нужен только для:
// - Данных которые дорого загружать (и не меняются часто)
// - User preferences
// Для погоды — keepAlive: false, пусть обновляется
```

### Инвалидируйте, не обновляйте вручную
```dart
// ПЛОХО — дублирование логики загрузки
void refresh() async {
  final weather = await repo.getCurrentWeather(city);
  state = weather;
}

// ХОРОШО — пусть провайдер сам пересоздастся
onTap: () => ref.invalidate(currentWeatherProvider),
```

---

## 4. Работа с API и сетью

### Всегда обрабатывайте все состояния ответа
```dart
// Минимальный контракт для любого сетевого запроса:
// 1. Loading
// 2. Success с данными
// 3. Error с понятным сообщением пользователю (не "Exception: ...")
// 4. Offline (нет соединения)
// 5. Stale (устаревшие данные из кэша)
```

### Не делайте запрос на каждый символ в поиске
```dart
// Debounce минимум 300-500ms
// Отменяйте предыдущий запрос при новом символе (Dio CancelToken)
```

### Логируйте запросы только в debug
```dart
if (kDebugMode) {
  _dio.interceptors.add(LogInterceptor(responseBody: true));
}
```

---

## 5. UI и виджеты

### Размеры в dp через MediaQuery или LayoutBuilder
```dart
// ПЛОХО — хардкод не работает на всех экранах
Container(width: 375, height: 200)

// ХОРОШО
LayoutBuilder(builder: (context, constraints) {
  return Container(width: constraints.maxWidth * 0.9);
})

// Или используйте процентные размеры
SizedBox(height: MediaQuery.of(context).size.height * 0.3)
```

### Безопасные зоны
```dart
// Всегда оборачивайте контент в SafeArea
// или учитывайте MediaQuery.of(context).padding
Scaffold(
  body: SafeArea(child: content),
)
```

### Доступность (accessibility)
```dart
// Добавляйте Semantics для важных элементов
Semantics(
  label: 'Температура ${weather.temperature} градусов',
  child: TemperatureWidget(value: weather.temperature),
)
```

---

## 6. Обработка ошибок

### Типизированные ошибки
```dart
// ПЛОХО
throw Exception('City not found');

// ХОРОШО — пользователь получает понятное сообщение
sealed class WeatherException implements Exception {
  const WeatherException();
}

class CityNotFoundException extends WeatherException {
  final String city;
  const CityNotFoundException(this.city);
  
  @override
  String toString() => 'Город "$city" не найден';
}

class NetworkException extends WeatherException {
  const NetworkException();
  
  @override
  String toString() => 'Нет соединения с интернетом';
}
```

### Никогда не глотайте ошибки молча
```dart
// ПЛОХО
try {
  await doSomething();
} catch (e) {
  // ignore
}

// ХОРОШО
try {
  await doSomething();
} catch (e, st) {
  FirebaseCrashlytics.instance.recordError(e, st);
  return const Failure('Что-то пошло не так');
}
```

---

## 7. Безопасность

### API ключи
- В `.env`, не в коде
- `.env` в `.gitignore`
- В CI/CD — через secrets
- В продакшне — через remote config или backend proxy

### Чувствительные данные
```dart
// SharedPreferences — НЕ для токенов
// flutter_secure_storage — для токенов и паролей

final storage = const FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
final token = await storage.read(key: 'auth_token');
```

### Obfuscation (запутывание кода)
```bash
flutter build appbundle --obfuscate --split-debug-info=./debug-info
# Усложняет реверс-инжиниринг APK
```

---

## 8. Git-гигиена

```bash
# .gitignore — обязательно:
.env
*.env
android/key.properties
android/app/keystore.jks
*.jks
*.keystore
/debug-info
.flutter-plugins
.flutter-plugins-dependencies
```

```
# Коммиты в стиле Conventional Commits:
feat: add hourly forecast widget
fix: weather background not updating on city change  
refactor: extract GlassCard to separate file
test: add unit tests for WeatherRepository cache logic
```

---

## 9. Дебаггинг и DevTools

```bash
# Flutter DevTools — открыть браузер с инструментами:
flutter run --profile  # не debug, не release
# В терминале появится ссылка на DevTools

# Что смотреть:
# Widget Inspector — дерево виджетов, rebuild highlights
# Performance — jank, dropped frames
# Memory — утечки памяти
# Network — все HTTP запросы
```

### Логирование в провайдерах
```dart
// Добавьте riverpod_observer для отладки:
class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    if (kDebugMode) {
      print('[Riverpod] ${provider.name} changed: $newValue');
    }
  }
}

// main.dart:
runApp(ProviderScope(
  observers: [if (kDebugMode) RiverpodLogger()],
  child: const App(),
));
```

---

## 10. Финальный чеклист перед релизом

- [ ] `flutter analyze` — 0 ошибок и предупреждений
- [ ] `flutter test` — все тесты зелёные
- [ ] API ключ не попал в git (`git log -S "ваш_ключ"`)
- [ ] Приложение работает без интернета
- [ ] Проверено на Android < 8.0 и iOS < 14
- [ ] Нет утечек памяти (DevTools Memory)
- [ ] Размер APK разумный (`flutter build apk --analyze-size`)
- [ ] ProGuard/R8 не сломал release сборку
- [ ] Crashlytics получает тестовый крэш
- [ ] Скриншоты в Play Store актуальны
