import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/models/forecast.dart';
import 'package:flutter_application_1/data/models/weather.dart';
import 'package:flutter_application_1/data/models/weather_condition.dart';
import 'package:flutter_application_1/presentation/providers/weather_providers.dart';
import 'package:flutter_application_1/presentation/widgets/city_search_sheet.dart';

class WeatherHomePage extends ConsumerWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      body: SafeArea(
        child: weatherAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e.toString().replaceFirst('WeatherException: ', ''),
            onRetry: () => ref.invalidate(currentWeatherProvider),
          ),
          data: (weather) => _WeatherContent(weather: weather),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        _TopBar(city: weather.cityName),
        const SizedBox(height: 32),
        _MainTemperature(weather: weather),
        const SizedBox(height: 24),
        _WeatherDetails(weather: weather),
        const SizedBox(height: 16),
        hourlyAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => const SizedBox.shrink(),
          data: (hourly) => _HourlyForecast(items: hourly),
        ),
        const SizedBox(height: 16),
        forecastAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => const SizedBox.shrink(),
          data: (daily) => _DailyForecast(items: daily),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city, style: textTheme.titleLarge),
            Text(_formattedDate(), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        IconButton.filledTonal(
          onPressed: () => _openSearch(context, ref),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

  const _MainTemperature({required this.weather});

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCondition.fromString(weather.condition);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          '${weather.temperature.toStringAsFixed(0)}°',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 96,
                fontWeight: FontWeight.w100,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 4),
        Text(condition.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          weather.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _DetailItem(icon: Icons.water_drop_outlined, value: '${weather.humidity}%', label: 'Влажность'),
            _DetailItem(icon: Icons.air, value: '${weather.windSpeed} м/с', label: 'Ветер'),
            _DetailItem(icon: Icons.thermostat, value: '${weather.feelsLike.toStringAsFixed(0)}°C', label: 'Ощущается'),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final isNow = i == 0;
          final condition = WeatherCondition.fromString(item.condition);
          return Card(
            color: isNow ? colorScheme.primaryContainer : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    isNow ? 'Сейчас' : '${item.time.hour}:00',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isNow ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                          fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                  Text(condition.emoji, style: const TextStyle(fontSize: 20)),
                  Text(
                    '${item.temperature.toStringAsFixed(0)}°',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isNow ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: items.map((item) => _DailyRow(item: item)).toList()),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              isToday ? 'Сегодня' : _weekday(item.date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
          Text(condition.emoji, style: const TextStyle(fontSize: 18)),
          const Spacer(),
          Text(
            '${item.tempMin.toStringAsFixed(0)}°',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.tempMax.toStringAsFixed(0)}°',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
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
