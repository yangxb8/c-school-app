// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class BlurHashImageWithFallback extends StatelessWidget {
  /// Fallback image mush be assets image
  final String fallbackImg;
  final String mainImg;

  /// Boxfit will be applied to all image
  final BoxFit boxFit;
  final String blurHash;
  const BlurHashImageWithFallback(
      {Key key,
      @required this.fallbackImg,
      @required this.mainImg,
      this.boxFit = BoxFit.cover,
      this.blurHash = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mainImg == null) {
      return Image.asset(fallbackImg, fit: boxFit);
    } else {
      return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: mainImg,
          placeholder: (context, url) =>
              BlurHash(hash: blurHash, imageFit: boxFit),
          errorWidget: (context, url, error) => Image.asset(
                fallbackImg,
                fit: boxFit,
              ));
    }
  }
}
