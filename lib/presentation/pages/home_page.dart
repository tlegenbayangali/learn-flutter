import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/models/forecast.dart';
import 'package:flutter_application_1/data/models/weather.dart';
import 'package:flutter_application_1/data/models/weather_condition.dart';
import 'package:flutter_application_1/presentation/providers/weather_providers.dart';
import 'package:flutter_application_1/presentation/widgets/city_search_sheet.dart';
import 'package:flutter_application_1/presentation/widgets/glass_card.dart';
import 'package:flutter_application_1/presentation/widgets/shimmer_loading.dart';
import 'package:flutter_application_1/presentation/widgets/weather_background.dart';

class WeatherHomePage extends ConsumerWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    final condition = weatherAsync.valueOrNull != null
        ? WeatherCondition.fromString(weatherAsync.valueOrNull!.condition)
        : WeatherCondition.clear;
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour >= 20;

    return WeatherBackground(
      condition: condition,
      isNight: isNight,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: weatherAsync.when(
            loading: () => const ShimmerLoading(),
            error: (e, _) => _ErrorView(
              message: e.toString().replaceFirst('WeatherException: ', ''),
              onRetry: () => ref.invalidate(currentWeatherProvider),
            ),
            data: (weather) => _WeatherContent(weather: weather),
          ),
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

// ─── Main content ─────────────────────────────────────────────────────────────

class _WeatherContent extends ConsumerWidget {
  final Weather weather;

  const _WeatherContent({required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourlyAsync = ref.watch(hourlyForecastProvider);
    final forecastAsync = ref.watch(forecastProvider);
    final condition = WeatherCondition.fromString(weather.condition);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _TopBar(city: weather.cityName)
            .animate().fadeIn(delay: 0.ms).slideY(begin: -0.2),
        const SizedBox(height: 32),
        _MainTemperature(weather: weather, condition: condition)
            .animate().fadeIn(delay: 150.ms).slideY(begin: 0.3),
        const SizedBox(height: 24),
        _WeatherDetails(weather: weather)
            .animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        const SizedBox(height: 20),
        hourlyAsync.when(
          loading: () => const ShimmerBox(height: 110),
          error: (e, st) => const SizedBox.shrink(),
          data: (hourly) => _HourlyForecast(items: hourly)
              .animate().fadeIn(delay: 450.ms).slideY(begin: 0.3),
        ),
        const SizedBox(height: 20),
        forecastAsync.when(
          loading: () => const ShimmerBox(height: 240),
          error: (e, st) => const SizedBox.shrink(),
          data: (daily) => _DailyForecast(items: daily)
              .animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final String city;

  const _TopBar({required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
            Text(_formattedDate(), style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
          ],
        ),
        GestureDetector(
          onTap: () => _openSearch(context, ref),
          child: GlassCard(
            padding: const EdgeInsets.all(10),
            borderRadius: 14,
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: CitySearchSheet(
          onCitySelected: (city) {
            ref.read(selectedCityProvider.notifier).setCity(city);
            ref.read(savedCitiesProvider.notifier).addCity(city);
          },
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}

// ─── Main Temperature ─────────────────────────────────────────────────────────

class _MainTemperature extends StatelessWidget {
  final Weather weather;
  final WeatherCondition condition;

  const _MainTemperature({required this.weather, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${weather.temperature.toStringAsFixed(0)}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 96,
            fontWeight: FontWeight.w100,
            height: 1,
            shadows: [Shadow(color: Colors.black26, blurRadius: 16)],
          ),
        ),
        const SizedBox(height: 4),
        Text(condition.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          weather.description,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 16,
              shadows: [Shadow(color: Colors.black26, blurRadius: 8)]),
        ),
      ],
    );
  }
}

// ─── Weather Details ──────────────────────────────────────────────────────────

class _WeatherDetails extends StatelessWidget {
  final Weather weather;

  const _WeatherDetails({required this.weather});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DetailItem(icon: '💧', value: '${weather.humidity}%', label: 'Влажность'),
          _DetailItem(icon: '💨', value: '${weather.windSpeed} м/с', label: 'Ветер'),
          _DetailItem(icon: '🌡', value: '${weather.feelsLike.toStringAsFixed(0)}°C', label: 'Ощущается'),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _DetailItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
      ],
    );
  }
}

// ─── Hourly Forecast ──────────────────────────────────────────────────────────

class _HourlyForecast extends StatelessWidget {
  final List<HourlyWeather> items;

  const _HourlyForecast({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          final isNow = i == 0;
          final condition = WeatherCondition.fromString(item.condition);
          return GlassCard(
            tint: isNow ? const Color(0xFF7EB8F7) : null,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  isNow ? 'Сейчас' : '${item.time.hour}:00',
                  style: TextStyle(
                    color: isNow ? Colors.white : const Color(0xB3FFFFFF),
                    fontSize: 12,
                    fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Text(condition.emoji, style: const TextStyle(fontSize: 20)),
                Text(
                  '${item.temperature.toStringAsFixed(0)}°',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Daily Forecast ───────────────────────────────────────────────────────────

class _DailyForecast extends StatelessWidget {
  final List<ForecastDay> items;

  const _DailyForecast({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: items.map((item) => _DailyRow(item: item)).toList()),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final ForecastDay item;

  const _DailyRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCondition.fromString(item.condition);
    final isToday = _isToday(item.date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              isToday ? 'Сегодня' : _weekday(item.date),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(condition.emoji, style: const TextStyle(fontSize: 18)),
          const Spacer(),
          Text('${item.tempMin.toStringAsFixed(0)}°',
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14)),
          const SizedBox(width: 8),
          Text('${item.tempMax.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _weekday(DateTime d) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[d.weekday - 1];
  }
}
