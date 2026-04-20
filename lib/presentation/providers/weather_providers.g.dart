// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRepositoryHash() => r'58292093d492ac317567d1f04fdef52605ab4531';

/// See also [weatherRepository].
@ProviderFor(weatherRepository)
final weatherRepositoryProvider =
    AutoDisposeProvider<WeatherRepository>.internal(
      weatherRepository,
      name: r'weatherRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weatherRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeatherRepositoryRef = AutoDisposeProviderRef<WeatherRepository>;
String _$currentWeatherHash() => r'74e54e680a8d874b7a65291c19b270cbc8ccce8f';

/// See also [currentWeather].
@ProviderFor(currentWeather)
final currentWeatherProvider = AutoDisposeFutureProvider<Weather>.internal(
  currentWeather,
  name: r'currentWeatherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWeatherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWeatherRef = AutoDisposeFutureProviderRef<Weather>;
String _$forecastHash() => r'79e48578a795381396ae948987029bc7a3945d9f';

/// See also [forecast].
@ProviderFor(forecast)
final forecastProvider = AutoDisposeFutureProvider<List<ForecastDay>>.internal(
  forecast,
  name: r'forecastProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forecastHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ForecastRef = AutoDisposeFutureProviderRef<List<ForecastDay>>;
String _$hourlyForecastHash() => r'3804e2116282762b40ccf484ecb99e2cc9be3abc';

/// See also [hourlyForecast].
@ProviderFor(hourlyForecast)
final hourlyForecastProvider =
    AutoDisposeFutureProvider<List<HourlyWeather>>.internal(
      hourlyForecast,
      name: r'hourlyForecastProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$hourlyForecastHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HourlyForecastRef = AutoDisposeFutureProviderRef<List<HourlyWeather>>;
String _$citySearchResultsHash() => r'ac4ffcc906fe6a87c0ef294194517293c882b8c7';

/// See also [citySearchResults].
@ProviderFor(citySearchResults)
final citySearchResultsProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
      citySearchResults,
      name: r'citySearchResultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$citySearchResultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CitySearchResultsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$selectedCityHash() => r'09aa285beba00d1425260202f46a5a6060118a64';

/// See also [SelectedCity].
@ProviderFor(SelectedCity)
final selectedCityProvider =
    AutoDisposeNotifierProvider<SelectedCity, String>.internal(
      SelectedCity.new,
      name: r'selectedCityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCity = AutoDisposeNotifier<String>;
String _$savedCitiesHash() => r'6a2b8973c23b38c1cc2fc3e86e916823da71bbf7';

/// See also [SavedCities].
@ProviderFor(SavedCities)
final savedCitiesProvider =
    AutoDisposeNotifierProvider<SavedCities, List<String>>.internal(
      SavedCities.new,
      name: r'savedCitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$savedCitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SavedCities = AutoDisposeNotifier<List<String>>;
String _$citySearchQueryHash() => r'54e7979c333758e99cb94f8cd8c447908adbd313';

/// See also [CitySearchQuery].
@ProviderFor(CitySearchQuery)
final citySearchQueryProvider =
    AutoDisposeNotifierProvider<CitySearchQuery, String>.internal(
      CitySearchQuery.new,
      name: r'citySearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$citySearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CitySearchQuery = AutoDisposeNotifier<String>;
String _$appThemeModeHash() => r'3e8120f7b7d013f5262419f358fb42e7208a2c66';

/// See also [AppThemeMode].
@ProviderFor(AppThemeMode)
final appThemeModeProvider =
    AutoDisposeNotifierProvider<AppThemeMode, ThemeMode>.internal(
      AppThemeMode.new,
      name: r'appThemeModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appThemeModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppThemeMode = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
