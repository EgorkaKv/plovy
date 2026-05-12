import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plovy/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:plovy/features/catalog/presentation/widgets/hairstyle_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hairstyle Catalog')),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (BuildContext context, CatalogState state) {
          if (state is CatalogLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CatalogError) {
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
                      onPressed: () => context
                          .read<CatalogBloc>()
                          .add(const CatalogRefreshRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          final result = (state as CatalogLoaded).result;
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
                  leading:
                      const Icon(Icons.info_outline, color: Colors.orange),
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
                      child:
                          HairstyleCard(hairstyle: result.hairstyles[index]),
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
