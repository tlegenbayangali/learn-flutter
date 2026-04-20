# Упражнения: Weather App от нуля до продакшна

## Приложение: **WeatherVibe**

Прогноз погоды с кастомным UI, анимациями и сменой города.  
Каждая фаза добавляет новый слой — в итоге получается полнофункциональный продукт.

### Что будет в финале

- Кастомный glassmorphism UI (не Material Design)
- Текущая погода + 7-дневный прогноз + почасовой
- Поиск и переключение городов (с историей)
- Живые анимации под тип погоды (дождь, снег, солнце...)
- Определение локации
- Офлайн-кэш
- Тёмная / светлая тема
- Опубликовано в Google Play

### Стек

| Слой | Пакет |
|------|-------|
| Навигация | `go_router` |
| State | `riverpod` + `hooks_riverpod` |
| HTTP | `dio` |
| Модели | `freezed` + `json_serializable` |
| Кэш | `hive_flutter` |
| Анимации | `lottie` + `flutter_animate` |
| Локация | `geolocator` |
| Секреты | `flutter_dotenv` |

### API

Используем **OpenWeatherMap** (бесплатный tier):  
https://openweathermap.org/api — зарегистрируйтесь и получите API key.

---

## Файлы упражнений

- [phase1_dart_basics.md](phase1_dart_basics.md) — Dart + базовая структура
- [phase2_ui_animations.md](phase2_ui_animations.md) — Glassmorphism UI + анимации
- [phase3_state_management.md](phase3_state_management.md) — Riverpod архитектура
- [phase4_backend_api.md](phase4_backend_api.md) — HTTP, кэш, локация
- [phase5_testing.md](phase5_testing.md) — Unit + Widget тесты
- [phase6_publication.md](phase6_publication.md) — Сборка и публикация
- [best_practices.md](best_practices.md) — Best practices по всем аспектам
- [project_spec.md](project_spec.md) — Финальная спецификация приложения
