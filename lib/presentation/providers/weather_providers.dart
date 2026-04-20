import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/core/errors/result.dart';
import 'package:flutter_application_1/data/models/forecast.dart';
import 'package:flutter_application_1/data/models/weather.dart';
import 'package:flutter_application_1/data/repositories/weather_repository.dart';
import 'package:flutter_application_1/data/repositories/weather_repository_impl.dart';

part 'weather_providers.g.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

@riverpod
WeatherRepository weatherRepository(Ref ref) {
  return MockWeatherRepository();
}

// ─── Selected city ────────────────────────────────────────────────────────────

@riverpod
class SelectedCity extends _$SelectedCity {
  @override
  String build() => 'London';

  void setCity(String city) => state = city;
}

// ─── Saved cities ─────────────────────────────────────────────────────────────

@riverpod
class SavedCities extends _$SavedCities {
  @override
  List<String> build() => ['London', 'Moscow', 'New York'];

  void addCity(String city) {
    if (!state.contains(city)) state = [city, ...state];
  }

  void removeCity(String city) {
    state = state.where((c) => c != city).toList();
  }
}

// ─── Current weather ──────────────────────────────────────────────────────────

@riverpod
Future<Weather> currentWeather(Ref ref) async {
  final city = ref.watch(selectedCityProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.getCurrentWeather(city);
  return switch (result) {
    Success(data: final w) => w,
    Failure(message: final m) => throw WeatherException(m),
  };
}

// ─── Forecast ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<ForecastDay>> forecast(Ref ref) async {
  final city = ref.watch(selectedCityProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.getForecast(city);
  return switch (result) {
    Success(data: final f) => f,
    Failure(message: final m) => throw WeatherException(m),
  };
}

@riverpod
Future<List<HourlyWeather>> hourlyForecast(Ref ref) async {
  final city = ref.watch(selectedCityProvider);
  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.getHourlyForecast(city);
  return switch (result) {
    Success(data: final h) => h,
    Failure(message: final m) => throw WeatherException(m),
  };
}

// ─── City search with debounce ────────────────────────────────────────────────

@riverpod
class CitySearchQuery extends _$CitySearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<String>> citySearchResults(Ref ref) async {
  final query = ref.watch(citySearchQueryProvider);
  // Debounce: ждём 500ms, пока пользователь печатает
  await Future.delayed(const Duration(milliseconds: 500));
  if (query.length < 2) return [];
  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.searchCities(query);
  return switch (result) {
    Success(data: final cities) => cities,
    Failure() => [],
  };
}

// ─── Theme mode ───────────────────────────────────────────────────────────────

@riverpod
class AppThemeMode extends _$AppThemeMode {
  static const _key = 'is_dark';

  @override
  ThemeMode build() {
    _loadFromPrefs();
    return ThemeMode.dark;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, !isDark);
  }
}
