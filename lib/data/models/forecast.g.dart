// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ForecastDayImpl _$$ForecastDayImplFromJson(Map<String, dynamic> json) =>
    _$ForecastDayImpl(
      date: DateTime.parse(json['date'] as String),
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
    );

Map<String, dynamic> _$$ForecastDayImplToJson(_$ForecastDayImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'tempMax': instance.tempMax,
      'tempMin': instance.tempMin,
      'condition': instance.condition,
    };

_$HourlyWeatherImpl _$$HourlyWeatherImplFromJson(Map<String, dynamic> json) =>
    _$HourlyWeatherImpl(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
    );

Map<String, dynamic> _$$HourlyWeatherImplToJson(_$HourlyWeatherImpl instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'temperature': instance.temperature,
      'condition': instance.condition,
    };
