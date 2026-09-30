import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A listing photo that fills the space it is given. It shows a plain surface
/// while it loads and an icon if it fails (or if there is no URL), so a missing
/// image never changes the layout or throws. It is hidden from screen readers:
/// the widget around it says what the photo is.
class ListingImage extends StatelessWidget {
  const ListingImage({required this.url, super.key});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return const _ImagePlaceholder(icon: Icons.image_not_supported_outlined);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _ImagePlaceholder(),
      errorBuilder: (context, error, stackTrace) =>
          const _ImagePlaceholder(icon: Icons.image_not_supported_outlined),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceSecondary,
      child: icon == null
          ? null
          : Center(
              child: Icon(icon, size: AppSizes.iconL, color: colors.textMuted),
            ),
    );
  }
}
