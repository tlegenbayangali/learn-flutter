# Flutter Learning Plan — Стартап-разработчик

**Профиль:** Средний уровень (опыт на других языках), цель — продуктовый стартап  
**Темп:** 1–2 часа в день  
**Общая длительность:** ~12 недель

---

## Фаза 1 — Dart + Основы Flutter (Недели 1–2)

Цель: уверенно читать и писать Flutter-код.

| День | Тема | Практика |
|------|------|----------|
| 1–2 | Dart: типы, null safety, async/await | Dart pad — 10 задач |
| 3–4 | Dart: классы, миксины, extensions | Описать модель User |
| 5–7 | Flutter: Widget tree, Stateless vs Stateful | Верстка экрана профиля |
| 8–10 | Навигация: Navigator 2.0 / go_router | 3 экрана с переходами |
| 11–14 | Layouts: Column, Row, Stack, Flexible | Копия экрана из App Store |

**Проект недели:** мини-приложение с 3 экранами и навигацией

---

## Фаза 2 — UI и Анимации (Недели 3–4)

Цель: создавать красивые и отзывчивые интерфейсы.

| День | Тема | Практика |
|------|------|----------|
| 1–3 | Темизация: ThemeData, ColorScheme, TextTheme | Светлая + тёмная тема |
| 4–5 | CustomPainter, декорации, ClipPath | Кастомный фон/карточка |
| 6–8 | Implicit animations: AnimatedContainer, AnimatedOpacity | Анимация появления |
| 9–11 | Explicit animations: AnimationController, Tween | Пульсирующая кнопка |
| 12–14 | Hero, PageRoute transitions, Lottie | Переход между экранами |

**Проект недели:** онбординг с анимированными слайдами

---

## Фаза 3 — State Management (Недели 5–6)

Цель: архитектурно грамотно управлять состоянием.

| День | Тема | Практика |
|------|------|----------|
| 1–2 | InheritedWidget / Provider — понять основу | Счётчик через Provider |
| 3–5 | Riverpod: StateProvider, FutureProvider, NotifierProvider | Список задач |
| 6–8 | Riverpod: семья провайдеров, invalidate, ref.watch | Фильтрация / поиск |
| 9–11 | Bloc: Cubit vs Bloc, Events/States | Форма с валидацией |
| 12–14 | Архитектура: Repository pattern, слои | Рефакторинг проекта |

**Выбор для стартапа:** рекомендую **Riverpod** — проще масштабировать соло-команде.

**Проект недели:** список товаров с фильтрами и корзиной

---

## Фаза 4 — Backend и API (Недели 7–9)

Цель: подключить реальные данные.

| День | Тема | Практика |
|------|------|----------|
| 1–3 | HTTP / Dio: GET, POST, interceptors | Список постов из API |
| 4–5 | JSON сериализация: json_serializable, freezed | Модели данных |
| 6–8 | Firebase Auth: email, Google Sign-In | Экраны входа/регистрации |
| 9–11 | Firestore: CRUD, real-time streams | Чат или лента |
| 12–14 | Локальный кэш: Hive / SharedPreferences | Офлайн-режим |
| 15–17 | Supabase как альтернатива Firebase | Таблицы + RLS |
| 18–21 | Безопасность: хранение токенов, flutter_secure_storage | Рефакторинг auth |

**Проект недели:** приложение с авторизацией и данными из Firebase

---

## Фаза 5 — Тестирование и Качество (Неделя 10)

Минимум для продакшн-продукта.

| День | Тема |
|------|------|
| 1–2 | Unit-тесты: логика, репозитории |
| 3–4 | Widget-тесты: ключевые экраны |
| 5–7 | Integration-тесты: критические флоу (login, checkout) |

---

## Фаза 6 — Публикация и Стартап-инфраструктура (Недели 11–12)

Цель: запустить приложение в сторах.

| День | Тема |
|------|------|
| 1–2 | Иконки, сплэш, конфиг android/ios |
| 3–4 | Android: подпись APK/AAB, Google Play Console |
| 5–6 | iOS: сертификаты, provisioning, App Store Connect |
| 7–8 | CI/CD: GitHub Actions + Fastlane |
| 9–10 | Crashlytics, Analytics, performance monitoring |
| 11–12 | OTA-обновления: Shorebird или CodePush |
| 13–14 | Финальный запуск MVP |

---

## Итоговый проект — MVP Стартапа

К концу плана у вас должно быть:

- [ ] Авторизация (email + Google)
- [ ] Минимум 5 экранов с навигацией
- [ ] Данные из Backend (Firebase/Supabase)
- [ ] Офлайн-кэш
- [ ] Опубликовано в Google Play (TestTrack) и/или TestFlight

---

## Ресурсы

| Ресурс | Для чего |
|--------|----------|
| [docs.flutter.dev](https://docs.flutter.dev) | Официальная документация |
| [dart.dev/codelabs](https://dart.dev/codelabs) | Dart с нуля |
| [riverpod.dev](https://riverpod.dev) | Документация Riverpod |
| [pub.dev](https://pub.dev) | Пакеты |
| Flutter YouTube (официальный) | Widget of the Week |
| Reso Coder (YouTube) | Архитектура, Bloc, TDD |
| [codewithandrea.com](https://codewithandrea.com) | Продвинутые паттерны |

---

## Трекер прогресса

Отмечайте выполненные фазы:

- [ ] Фаза 1 — Dart + Основы
- [ ] Фаза 2 — UI / Анимации
- [ ] Фаза 3 — State Management
- [ ] Фаза 4 — Backend / API
- [ ] Фаза 5 — Тестирование
- [ ] Фаза 6 — Публикация
- [ ] MVP запущен 🚀
