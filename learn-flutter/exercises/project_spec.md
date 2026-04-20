# Спецификация: WeatherVibe

Полнофункциональное приложение прогноза погоды.  
Итог всех 6 фаз обучения.

---

## Экраны

### 1. Home — Текущая погода
```
┌─────────────────────────────┐
│  Moscow          ⚙  🔍      │  ← TopBar (город + иконки)
│                             │
│           ☀️               │  ← Lottie анимация
│                             │
│          22°               │  ← Температура (96sp, thin)
│         Ясно               │  ← Описание
│                             │
│  ┌─────────────────────────┐│
│  │💧 65%  💨 3м/с  🌡 20°  ││  ← GlassCard детали
│  └─────────────────────────┘│
│                             │
│  [12:00][13:00][14:00][15:00]│  ← Горизонтальный scroll (hourly)
│                             │
│  [Пн][Вт][Ср][Чт][Пт][Сб][Вс]│  ← 7-дневный прогноз
└─────────────────────────────┘
  Фон: анимированный градиент под тип погоды
```

### 2. City Search — Поиск города
```
Bottom sheet (draggable, glassmorphism)
┌─────────────────────────────┐
│    ━━━━━   (drag handle)    │
│                             │
│  [ 🔍 Поиск города...     ] │  ← GlassTextField
│                             │
│  Сохранённые города:        │
│  ┌─────────┐ ┌─────────┐   │
│  │ Москва  │ │ Лондон  │   │  ← Chips (удаляемые)
│  └─────────┘ └─────────┘   │
│                             │
│  Результаты:                │
│  ○ Moscow, RU               │
│  ○ Moscow, ID               │
└─────────────────────────────┘
```

### 3. Settings
```
┌─────────────────────────────┐
│  ← Настройки                │
│                             │
│  Единицы температуры        │
│  ○ Цельсий  ○ Фаренгейт    │
│                             │
│  Тема                       │
│  ○ Тёмная  ○ Светлая  ○ Авто│
│                             │
│  Уведомления                │
│  [ Утренний прогноз    ] ●  │
│                             │
│  Кэш                        │
│  [ Очистить кэш        ] →  │
└─────────────────────────────┘
```

---

## Навигация (go_router)

```dart
// lib/app/router.dart
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const WeatherHomePage()),
  GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  // City search — через showModalBottomSheet, не отдельный route
]);
```

---

## Структура проекта (итоговая)

```
lib/
  app/
    router.dart
    app.dart
  core/
    constants/
      app_theme.dart
      app_colors.dart
    errors/
      result.dart
      exceptions.dart
    utils/
      extensions.dart
      formatters.dart
    env.dart
  data/
    models/
      weather.dart + .freezed.dart + .g.dart
      forecast_day.dart
      hourly_weather.dart
    repositories/
      weather_repository.dart          # interface
      weather_repository_impl.dart
    sources/
      weather_api_source.dart
      weather_cache_source.dart
      location_source.dart
  presentation/
    pages/
      home/
        weather_home_page.dart
        widgets/
          weather_background.dart
          main_temperature.dart
          weather_details.dart
          hourly_forecast.dart
          daily_forecast.dart
          weather_loading_view.dart
          weather_error_view.dart
      search/
        city_search_sheet.dart
        widgets/
          glass_text_field.dart
          city_chip.dart
          search_result_tile.dart
      settings/
        settings_page.dart
    widgets/
      glass_card.dart
      weather_animation.dart
      particles_overlay.dart
    providers/
      weather_providers.dart
      city_providers.dart
      settings_providers.dart
  main.dart

assets/
  animations/
    sunny.json
    rain.json
    snow.json
    thunderstorm.json
    cloudy.json
  icon/
    app_icon.png
  splash.png
  .env  ← в .gitignore!

test/
  data/
    models/
      weather_test.dart
    repositories/
      weather_repository_test.dart
  presentation/
    providers/
      weather_providers_test.dart
    widgets/
      glass_card_test.dart
      weather_home_page_test.dart
  helpers/
    test_data.dart  ← фабрики тестовых объектов
```

---

## pubspec.yaml (финальный)

```yaml
name: weather_vibe
description: WeatherVibe - beautiful weather forecast

version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Навигация
  go_router: ^14.2.7

  # State management
  flutter_riverpod: ^2.5.1
  hooks_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  flutter_hooks: ^0.20.5

  # Модели
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # HTTP
  dio: ^5.7.0

  # Кэш
  hive_flutter: ^1.1.0

  # Анимации
  lottie: ^3.1.0
  flutter_animate: ^4.5.0

  # Локация
  geolocator: ^12.0.0

  # Конфигурация
  flutter_dotenv: ^5.1.0

  # Шрифты
  google_fonts: ^6.2.1

  # Мониторинг соединения
  connectivity_plus: ^6.0.3

  # Безопасное хранение
  flutter_secure_storage: ^9.2.2

  # Firebase
  firebase_core: ^3.6.0
  firebase_crashlytics: ^4.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Генерация кода
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0

  # Тесты
  mocktail: ^1.0.4

  # Иконки и сплэш
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.0

  # Lint
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/animations/
    - assets/icon/
    - assets/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Thin.ttf
          weight: 100
        - asset: assets/fonts/Inter-Light.ttf
          weight: 300
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
```

---

## Milestone-карта

| Неделя | Результат |
|--------|-----------|
| 1–2 | Моковые данные, рабочий экран без дизайна |
| 3–4 | Glassmorphism UI + анимации, нет данных |
| 5–6 | Riverpod + Repository, архитектура готова |
| 7–8 | Реальный API, кэш, геолокация |
| 9 | Несколько городов, поиск, настройки |
| 10 | Тесты (coverage > 70% data слоя) |
| 11 | Иконка, сплэш, keystore, CI/CD |
| 12 | Опубликовано в Internal Testing 🚀 |
