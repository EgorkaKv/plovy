import 'package:flutter/material.dart';
import 'package:plovy/core/di/injection.dart';
import 'package:plovy/features/catalog/domain/repositories/hairstyle_repository.dart';
import 'package:plovy/features/catalog/presentation/widgets/hairstyle_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<HairstyleResult> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<HairstyleRepository>().getHairstyles();
  }

  void _retry() {
    setState(() {
      _future = getIt<HairstyleRepository>().getHairstyles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hairstyle Catalog')),
      body: FutureBuilder<HairstyleResult>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<HairstyleResult> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load hairstyles.\nNo cached data available.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: _retry,
                    ),
                  ],
                ),
              ),
            );
          }

          final result = snap.data!;
          return Column(
            children: <Widget>[
              if (result.isFromCache)
                MaterialBanner(
                  content: Text(
                    result.isStale
                        ? 'Данные могут быть устаревшими (кеш > 24 ч)'
                        : 'Отображаются данные из кеша',
                  ),
                  backgroundColor: Colors.amber.shade100,
                  leading: const Icon(Icons.info_outline, color: Colors.orange),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .hideCurrentMaterialBanner(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: result.hairstyles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HairstyleCard(hairstyle: result.hairstyles[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
