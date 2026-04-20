import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/presentation/providers/weather_providers.dart';

class CitySearchSheet extends ConsumerWidget {
  final ValueChanged<String> onCitySelected;

  const CitySearchSheet({super.key, required this.onCitySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GlassTextField(
                  onChanged: (q) => ref.read(citySearchQueryProvider.notifier).update(q),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _SearchResults(onCitySelected: onCitySelected)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final ValueChanged<String> onCitySelected;

  const _SearchResults({required this.onCitySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(citySearchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
      error: (e, st) => const SizedBox.shrink(),
      data: (cities) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cities.length,
        itemBuilder: (context, i) {
          final city = cities[i];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onCitySelected(city);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFF7EB8F7), size: 18),
                  const SizedBox(width: 10),
                  Text(city, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
          ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _GlassTextField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TextField(
        onChanged: onChanged,
        autofocus: true,
        cursorColor: const Color(0xFF7EB8F7),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Поиск города...',
          hintStyle: TextStyle(color: Color(0x80FFFFFF)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF7EB8F7), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
