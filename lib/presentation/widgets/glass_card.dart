import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/weather_condition.dart';

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

  factory GlassCard.colored({
    Key? key,
    required Widget child,
    required WeatherCondition condition,
    double borderRadius = 20,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final tint = switch (condition) {
      WeatherCondition.clear => const Color(0xFFFFD700),
      WeatherCondition.clouds => const Color(0xFF90A4AE),
      WeatherCondition.rain || WeatherCondition.drizzle => const Color(0xFF3498DB),
      WeatherCondition.thunderstorm => const Color(0xFF6C3483),
      WeatherCondition.snow => const Color(0xFFA8C0FF),
      WeatherCondition.mist => const Color(0xFF757F9A),
    };
    return GlassCard(
      key: key,
      tint: tint,
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

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
              color: (tint ?? Colors.white).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
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
