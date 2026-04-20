# Фаза 2 — Glassmorphism UI + Анимации

**Цель:** создать уникальный визуальный стиль WeatherVibe без стандартного Material Design.

---

## Концепция дизайна

**Glassmorphism** — матовое стекло, размытый фон, полупрозрачные карточки.  
Цвет фона динамически меняется под тип погоды:

| Погода | Градиент |
|--------|----------|
| Ясно (день) | `#1a1a2e` → `#16213e` → `#0f3460` с золотым оттенком |
| Ясно (ночь) | `#0d0d1a` → `#1a1a3e` с синим |
| Дождь | `#2c3e50` → `#3498db` |
| Гроза | `#1a1a2e` → `#2c2c54` |
| Снег | `#dfe9f3` → `#a8c0ff` |
| Туман | `#757f9a` → `#d7dde8` |

---

## Задача 2.1 — Тема и цветовая система

```dart
// lib/core/constants/app_theme.dart

class AppTheme {
  // Не используем ThemeData.light() или .dark() напрямую
  // Создаём полностью кастомную тему
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7EB8F7),
      secondary: Color(0xFFB8E0FF),
      surface: Colors.transparent,  // карточки рисуем сами
      background: Color(0xFF0D0D1A),
    ),
    // Убираем все тени Material
    cardTheme: const CardTheme(elevation: 0, color: Colors.transparent),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    // Шрифт — межплатформенный современный
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 80, fontWeight: FontWeight.w200, letterSpacing: -2),
      displayMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xB3FFFFFF)), // 70% white
    ),
  );
}
```

Добавьте шрифт Inter в `pubspec.yaml` через Google Fonts:
```yaml
dependencies:
  google_fonts: ^6.2.1
```

---

## Задача 2.2 — GlassCard виджет

Это будет базовый строительный блок всего UI:

```dart
// lib/presentation/widgets/glass_card.dart
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.tint,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (tint ?? Colors.white).withOpacity(0.08),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

**Упражнение:** создайте вариант `GlassCard.colored(WeatherCondition condition)` который меняет tint в зависимости от погоды.

---

## Задача 2.3 — Анимированный градиентный фон

```dart
// lib/presentation/widgets/weather_background.dart

class WeatherBackground extends StatefulWidget {
  final WeatherCondition condition;
  final bool isNight;
  final Widget child;
  // ...
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // TODO: при смене condition — плавно анимируйте переход между градиентами
  // Подсказка: используйте AnimatedContainer или TweenAnimationBuilder
  
  // Градиент должен медленно "дышать" — двигаться вверх-вниз
  // Подсказка: меняйте begin/end точки градиента через sin(animation.value)
}
```

---

## Задача 2.4 — Экран текущей погоды

Разбейте на виджеты:

```
WeatherHomePage
├── WeatherBackground (анимированный)
├── SafeArea
│   ├── _TopBar (город + иконка настроек)
│   ├── _MainTemperature (большое число + условие)
│   ├── _WeatherDetails (влажность, ветер, ощущается)
│   ├── _HourlyForecast (горизонтальный scroll)
│   └── _DailyForecast (7 дней)
```

**Требования к `_MainTemperature`:**

```dart
// Температура отображается шрифтом размера 96sp, weight: 100 (thin)
// Под ней — emoji условия (из WeatherCondition.emoji) размером 48
// Под emoji — описание строчными буквами
// Всё центрировано, белый текст с тенью
```

**Требования к `_WeatherDetails`:**

```dart
// GlassCard с Row из 3 элементов:
// [💧 Влажность] [💨 Ветер] [🌡 Ощущается]
// Каждый элемент: иконка + значение крупно + подпись мелко
```

---

## Задача 2.5 — Горизонтальная почасовая лента

```dart
// _HourlyForecast — ListView.builder horizontal
// Каждый элемент — GlassCard 60x100:
//   время (14:00)
//   emoji погоды
//   температура

// ТРЕБОВАНИЕ: текущий час должен быть выделен
// (другой tint, чуть больше, border цветной)
```

---

## Задача 2.6 — Анимация появления экрана

```dart
// При загрузке данных каждый блок появляется с задержкой (stagger):
// _TopBar — delay 0ms
// _MainTemperature — delay 150ms
// _WeatherDetails — delay 300ms
// _HourlyForecast — delay 450ms
// _DailyForecast — delay 600ms

// Используйте пакет flutter_animate:
// child.animate().fadeIn(delay: 300.ms).slideY(begin: 0.3)
```

```yaml
# pubspec.yaml
dependencies:
  flutter_animate: ^4.5.0
```

---

## Задача 2.7 — Анимации погоды с Lottie

```yaml
dependencies:
  lottie: ^3.1.0
```

Скачайте бесплатные анимации с [LottieFiles](https://lottiefiles.com):
- Солнце: `assets/animations/sunny.json`
- Дождь: `assets/animations/rain.json`  
- Снег: `assets/animations/snow.json`
- Гроза: `assets/animations/thunderstorm.json`
- Облачно: `assets/animations/cloudy.json`

```dart
// lib/presentation/widgets/weather_animation.dart
class WeatherAnimation extends StatelessWidget {
  final WeatherCondition condition;
  final double size;

  Widget build(BuildContext context) {
    return Lottie.asset(
      condition.animationPath, // добавьте getter в enum
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
```

---

## Задача 2.8 — Поиск города (bottom sheet)

```dart
// Кастомный draggable bottom sheet (не showModalBottomSheet)
// - появляется снизу с анимацией
// - имеет кастомный drag handle
// - TextField с кастомным стилем (glass input)
// - результаты поиска в ListView

class CitySearchSheet extends StatefulWidget { ... }

// GlassTextField:
class GlassTextField extends StatelessWidget {
  // Container с BackdropFilter + TextField без стандартных decoration
  // Кастомный cursor color, hint style, icon
}
```

---

## Задача 2.9 — Частицы для анимации дождя/снега (бонус)

```dart
// lib/presentation/widgets/particles_overlay.dart
// Используйте CustomPainter для рисования частиц
// При condition == rain — падающие синие капли
// При condition == snow — медленные белые снежинки
// Анимируйте через AnimationController + ticker

class RainPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0 из AnimationController
  final List<Offset> drops; // позиции капель
  
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: рисуйте линии для капель дождя
    // или круги для снега
  }
}
```

---

## Чеклист Фазы 2

- [ ] Кастомная тема без стандартного Material
- [ ] GlassCard виджет работает
- [ ] Анимированный фон меняет цвет под погоду
- [ ] Экран разбит на виджеты < 100 строк каждый
- [ ] Stagger анимации при загрузке
- [ ] Lottie анимации для каждого типа погоды
- [ ] Поиск города через bottom sheet
- [ ] Выглядит красиво на iOS и Android
