import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plovy/features/catalog/domain/entities/hairstyle.dart';

class HairstyleCard extends StatelessWidget {
  const HairstyleCard({required this.hairstyle, super.key});

  final Hairstyle hairstyle;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: hairstyle.imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 160,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hairstyle.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  hairstyle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _SmallChip(label: hairstyle.category),
                    const SizedBox(width: 4),
                    _SmallChip(label: hairstyle.difficulty),
                    const Spacer(),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      hairstyle.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
