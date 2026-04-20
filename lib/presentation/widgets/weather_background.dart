import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/weather_condition.dart';

class WeatherBackground extends StatefulWidget {
  final WeatherCondition condition;
  final bool isNight;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
    this.isNight = false,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _colorsFor(WeatherCondition condition, bool isNight) {
    if (condition == WeatherCondition.clear && isNight) {
      return [const Color(0xFF0D0D1A), const Color(0xFF1A1A3E), const Color(0xFF0D2137)];
    }
    return switch (condition) {
      WeatherCondition.clear => [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
      WeatherCondition.clouds => [const Color(0xFF2C3E50), const Color(0xFF4A5568), const Color(0xFF2D3748)],
      WeatherCondition.rain || WeatherCondition.drizzle => [const Color(0xFF2C3E50), const Color(0xFF2980B9), const Color(0xFF3498DB)],
      WeatherCondition.thunderstorm => [const Color(0xFF1A1A2E), const Color(0xFF2C2C54), const Color(0xFF1A0533)],
      WeatherCondition.snow => [const Color(0xFFDFE9F3), const Color(0xFFA8C0FF), const Color(0xFFD4E8FF)],
      WeatherCondition.mist => [const Color(0xFF757F9A), const Color(0xFFD7DDE8), const Color(0xFF8E9EAB)],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(widget.condition, widget.isNight);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathe = sin(_controller.value * 2 * pi) * 0.08;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, -1 + breathe),
              end: Alignment(0, 1 - breathe),
              colors: colors,
            ),
          ),
          child: child,
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: widget.child,
      ),
    );
  }
}
