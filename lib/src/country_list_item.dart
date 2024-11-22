import 'package:fp_country_picker/country_picker.dart';
import 'package:fp_country_picker/src/country_list_item_theme_data.dart';
import 'package:flutter/material.dart';

import 'country_circular_flag_image.dart';

typedef FlagErrorBuilder = Widget Function(
  Exception exception,
  StackTrace stacktrace,
);

class CountryListItem extends StatefulWidget {
  const CountryListItem({
    super.key,
    required this.country,
    required this.onSelect,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.customFlagBuilder,
    this.flagErrorBuilder,
    this.countryListItemTheme,
    this.selectedCountryCode,
  });

  /// Country object from the list
  final Country country;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for customizing the country list item.
  final CountryListItemThemeData? countryListItemTheme;

  /// Custom builder function for flag widget
  final CustomFlagBuilder? customFlagBuilder;

  /// Custom builder function for flag if showing error displaying
  final FlagErrorBuilder? flagErrorBuilder;

  final String? selectedCountryCode;

  @override
  State<CountryListItem> createState() => _CountryListItemState();
}

class _CountryListItemState extends State<CountryListItem> {
  bool get isSelected =>
      widget.country.countryCode == widget.selectedCountryCode;

  @override
  Widget build(BuildContext context) {
    final TextStyle _textStyle = (isSelected
            ? widget
                .countryListItemTheme?.countrySelectedItemThemeData?.textStyle
            : widget.countryListItemTheme?.textStyle) ??
        _defaultTextStyle;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final selectedBoxDecoration = widget
        .countryListItemTheme?.countrySelectedItemThemeData?.boxDecoration;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.country.nameLocalized = CountryLocalizations.of(context)
              ?.countryName(countryCode: widget.country.countryCode)
              ?.replaceAll(RegExp(r"\s+"), " ");
          widget.onSelect(widget.country);
          Navigator.pop(context);
        },
        child: Ink(
          decoration: (isSelected ? selectedBoxDecoration : null) ??
              BoxDecoration(
                color: isSelected
                    ? widget.countryListItemTheme?.countrySelectedItemThemeData
                        ?.backgroundColor
                    : Colors.transparent,
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: <Widget>[
                Row(
                  children: [
                    const SizedBox(width: 20),
                    if (widget.customFlagBuilder == null)
                      _flagWidget(widget.country)
                    else
                      widget.customFlagBuilder!(widget.country),
                    if (widget.showPhoneCode &&
                        !widget.country.iswWorldWide) ...[
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '${isRtl ? '' : '+'}${widget.country.phoneCode}${isRtl ? '+' : ''}',
                          style: _textStyle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ] else
                      const SizedBox(width: 15),
                  ],
                ),
                Expanded(
                  child: Text(
                    CountryLocalizations.of(context)
                            ?.countryName(
                                countryCode: widget.country.countryCode)
                            ?.replaceAll(RegExp(r"\s+"), " ") ??
                        widget.country.name,
                    style: _textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    Widget image = Text(
      country.countryCode,
      style: _defaultTextStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
    try {
      var countryCode = country.countryCode.toLowerCase();
      if (countryCode == "ac") countryCode = "gb";

      image = Stack(
        children: [
          CountryCircularFlagImage(
            flagName: countryCode,
            flagSize: widget.countryListItemTheme?.flagSize ?? kDefaultFlagSize,
          ),
          if (isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.countryListItemTheme
                      ?.countrySelectedItemThemeData?.iconBackgroundColor,
                ),
                padding: widget.countryListItemTheme
                    ?.countrySelectedItemThemeData?.iconPadding,
                child: Icon(
                  Icons.check_rounded,
                  size: widget.countryListItemTheme
                      ?.countrySelectedItemThemeData?.iconSize,
                  color: widget.countryListItemTheme
                      ?.countrySelectedItemThemeData?.iconColor,
                ),
              ),
            ),
        ],
      );
    } catch (e, stackTrace) {
      print("ERROR: _flagWidget $e");
      print(stackTrace);
    }

    return image;
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
