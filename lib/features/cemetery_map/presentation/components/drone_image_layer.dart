import 'package:baladeyate/features/cemetery_map/repo/cemetery_map_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-size drone orthophoto layer with optional tap-to-place handling.
class DroneImageLayer extends StatelessWidget {
  const DroneImageLayer({
    super.key,
    required this.isAddingMode,
    required this.onMapTap,
    required this.mapWidth,
    required this.mapHeight,
    this.imageUrl,
  });

  final bool isAddingMode;
  final ValueChanged<Offset> onMapTap;
  final double mapWidth;
  final double mapHeight;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!.trim()
        : CemeteryMapRepository.fallbackMapUrl;

    final cacheWidth = mapWidth.round().clamp(800, 2400);
    final cacheHeight = mapHeight.round().clamp(600, 1800);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          isAddingMode ? (details) => onMapTap(details.localPosition) : null,
      child: CachedNetworkImage(
        imageUrl: url,
        width: mapWidth,
        height: mapHeight,
        fit: BoxFit.fill,
        fadeInDuration: const Duration(milliseconds: 250),
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
        placeholder: (context, _) => ColoredBox(
          color: const Color(0xFF1A1A1A),
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, _, error) => ColoredBox(
          color: const Color(0xFF2A2A2A),
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        size: 36, color: Colors.white70),
                    SizedBox(width: 12),
                    Text(
                      'تعذر تحميل صورة الخريطة',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
