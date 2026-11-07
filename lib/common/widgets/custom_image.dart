import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friday_sa/util/images.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
    this.isHovered = false,
    this.alignment = Alignment.center,
    this.color,
  });
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Alignment alignment;
  final Color? color;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    bool isValidUrl = image.isNotEmpty && image.startsWith('http');

    if (!isValidUrl) {
      return Image.asset(
        placeholder.isNotEmpty
            ? placeholder
            : (isNotification
                  ? Images.notificationPlaceholder
                  : Images.placeholder),
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        color: color,
      );
    }

    return AnimatedScale(
      scale: isHovered ? 1.1 : 1.0, // Scale animation
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: kIsWeb
          ? Image.network(
              image,
              height: height,
              width: width,
              fit: fit,
              alignment: alignment,
              color: color,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  placeholder.isNotEmpty
                      ? placeholder
                      : (isNotification
                            ? Images.notificationPlaceholder
                            : Images.placeholder),
                  height: height,
                  width: width,
                  fit: fit,
                  alignment: alignment,
                );
              },
            )
          : CachedNetworkImage(
              imageUrl: image,
              height: height,
              width: width,
              fit: fit,
              alignment: alignment,
              color: color,
              placeholder: (context, url) => Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : (isNotification
                          ? Images.notificationPlaceholder
                          : Images.placeholder),
                height: height,
                width: width,
                fit: fit,
                alignment: alignment,
              ),
              errorWidget: (context, url, error) => Image.asset(
                placeholder.isNotEmpty
                    ? placeholder
                    : (isNotification
                          ? Images.notificationPlaceholder
                          : Images.placeholder),
                height: height,
                width: width,
                fit: fit,
                alignment: alignment,
              ),
            ),
    );
  }
}
