import 'package:flutter/material.dart';

const double kDefaultFlagSize = 40.0;
const Color kDefaultSelectedBackgroundColor = Color(0xFFFAFBFC);
const Color kDefaultSelectedIconBackgroundColor = Color(0xFF51DB62);

class CountryListItemThemeData {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double flagSize;
  final TextStyle? textStyle;

  final CountrySelectedItemThemeData? countrySelectedItemThemeData;

  const CountryListItemThemeData({
    this.padding,
    this.margin,
    this.flagSize = kDefaultFlagSize,
    this.textStyle,
    this.countrySelectedItemThemeData = const CountrySelectedItemThemeData(),
  });
}

class CountrySelectedItemThemeData {
  final BoxDecoration? boxDecoration;
  final Color? backgroundColor;
  final double? flagSize;
  final TextStyle? textStyle;

  final Color? iconBackgroundColor;
  final double? iconSize;
  final EdgeInsets? iconPadding;
  final Color? iconColor;

  const CountrySelectedItemThemeData({
    this.boxDecoration,
    this.backgroundColor = kDefaultSelectedBackgroundColor,
    this.flagSize,
    this.textStyle,
    this.iconBackgroundColor = kDefaultSelectedIconBackgroundColor,
    this.iconSize = 10,
    this.iconPadding = const EdgeInsets.all(2.6),
    this.iconColor,
  });
}
