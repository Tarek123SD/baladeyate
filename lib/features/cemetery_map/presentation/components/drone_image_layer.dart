import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Intrinsic size of the drone orthophoto (must match the source image).
const double mapWidth = 2000;
const double mapHeight = 1500;

/// Placeholder high-res URL simulating a drone orthophoto until the backend
/// serves the real cemetery map.
const String droneOrthophotoUrl =
    'https://baladeyate.me/cemeteries/map_v1.jpg';

/// Full-size drone orthophoto layer with optional tap-to-place handling.
class DroneImageLayer extends StatelessWidget {
  const DroneImageLayer({
    super.key,
    required this.isAddingMode,
    required this.onMapTap,
  });

  final bool isAddingMode;
  final ValueChanged<Offset> onMapTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:
          isAddingMode ? (details) => onMapTap(details.localPosition) : null,
      child: CachedNetworkImage(
        imageUrl: droneOrthophotoUrl,
        width: mapWidth,
        height: mapHeight,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      ),
    );
  }
}
