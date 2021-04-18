// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class BlurHashImageWithFallback extends StatelessWidget {
  /// Fallback image mush be a String to asset or a widget
  final dynamic fallbackImg;
  final String? mainImgUrl;

  /// Boxfit will be applied to all image
  final BoxFit boxFit;
  final String blurHash;
  const BlurHashImageWithFallback(
      {Key? key,
      this.fallbackImg,
      this.mainImgUrl,
      this.boxFit = BoxFit.cover,
      this.blurHash = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mainImgUrl == null) {
      if (fallbackImg is String) {
        return Image.asset(fallbackImg, fit: boxFit);
      } else if (fallbackImg is Widget) {
        return fallbackImg;
      }
      return Container();
    } else {
      return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: mainImgUrl!,
          placeholder: (context, url) => BlurHash(
                hash: blurHash,
                imageFit: boxFit,
                color: Colors.white70,
              ),
          errorWidget: (context, url, error) => (fallbackImg is String)
              ? Image.asset(
                  fallbackImg,
                  fit: boxFit,
                )
              : fallbackImg);
    }
  }
}
