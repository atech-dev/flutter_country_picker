import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class CountryCircularFlagImage extends StatelessWidget {
  const CountryCircularFlagImage({
    super.key,
    required this.flagName,
    required this.flagSize,
  });

  final String flagName;
  final double flagSize;

  CountryCircularFlagImage copyWith({
    double? flagSize,
  }) {
    return CountryCircularFlagImage(
      flagName: flagName,
      flagSize: flagSize ?? this.flagSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final flagUri = "flags/${flagName.toLowerCase()}.svg";
    return Container(
      width: flagSize,
      height: flagSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFAFAFA),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: FutureBuilder(
          future: vecFileExists(flagUri),
          builder: (_, data) {
            try {
              if (!data.hasData) {
                return const SizedBox.shrink();
              } else if (data.data != null) {
                return SvgPicture(
                  AssetBytesLoader(
                    data.data!,
                    packageName: 'fp_country_picker',
                  ),
                  fit: BoxFit.cover,
                  width: flagSize * 2,
                );
              } else {
                return SvgPicture.asset(
                  flagUri,
                  fit: BoxFit.cover,
                  width: flagSize * 2,
                  package: 'fp_country_picker',
                );
              }
            } catch (e, stackTrace) {
              print("ERROR: $e");
              print("stackTrace: $stackTrace");
              rethrow;
            }
          },
        ),
      ),
    );
  }

  Future<String?> vecFileExists(String assetPath) async {
    try {
      final uri = "$assetPath.vec";
      await rootBundle.load("packages/fp_country_picker/$uri");
      return uri;
    } catch (e) {
      return null;
    }
  }
}
