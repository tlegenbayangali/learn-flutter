import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/presentation/providers/weather_providers.dart';

class CitySearchSheet extends ConsumerWidget {
  final ValueChanged<String> onCitySelected;

  const CitySearchSheet({super.key, required this.onCitySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchBar(
                  hintText: 'Поиск города...',
                  leading: const Icon(Icons.search),
                  autoFocus: true,
                  onChanged: (q) => ref.read(citySearchQueryProvider.notifier).update(q),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _SearchResults(onCitySelected: onCitySelected, scrollController: scrollController)),
            ],
          ),
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final ValueChanged<String> onCitySelected;
  final ScrollController scrollController;

  const _SearchResults({required this.onCitySelected, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(citySearchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
      data: (cities) {
        final navigator = Navigator.of(context);
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: cities.length,
          itemBuilder: (context, i) {
            final city = cities[i];
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(city),
              onTap: () {
                navigator.pop();
                onCitySelected(city);
              },
            );
          },
        );
      },
    );
  }
}
