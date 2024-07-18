import 'dart:io';

import 'package:country_picker/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../country_picker.dart';
import 'country_list_item.dart';
import 'country_list_item_theme_data.dart';
import 'country_list_view.dart';

void showCountryListBottomSheet({
  required BuildContext context,
  required ValueChanged<Country> onSelect,
  String? defaultCountryCode,
  Country? selectedCountry,
  VoidCallback? onClosed,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  CustomFlagBuilder? customFlagBuilder,
  FlagErrorBuilder? flagErrorBuilder,
  CountryListThemeData? countryListTheme,
  CountryListItemThemeData? countryListItemTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
  bool showSearch = true,
  bool useSafeArea = false,
  bool useRootNavigator = false,
  bool moveAlongWithKeyboard = false,
}) {
  Widget buildBuilder(BuildContext context) {
    final builder = _builder(
      context,
      defaultCountryCode,
      selectedCountry,
      onSelect,
      favorite,
      exclude,
      countryFilter,
      showPhoneCode,
      countryListTheme,
      countryListItemTheme,
      searchAutofocus,
      showWorldWide,
      showSearch,
      moveAlongWithKeyboard,
      customFlagBuilder,
      flagErrorBuilder,
    );

    return isPlatformIOS
        ? Transition(
            body: builder,
          )
        : builder;
  }

  if (isPlatformIOS) {
    showCupertinoModalBottomSheet(
      elevation: 4,
      context: context,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.white,
      builder: buildBuilder,
    ).whenComplete(() {
      if (onClosed != null) onClosed();
    });
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      builder: buildBuilder,
    ).whenComplete(() {
      if (onClosed != null) onClosed();
    });
  }
}

Widget _builder(
  BuildContext context,
  String? defaultCountryCode,
  Country? selectedCountry,
  ValueChanged<Country> onSelect,
  List<String>? favorite,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode,
  CountryListThemeData? countryListTheme,
  CountryListItemThemeData? countryListItemTheme,
  bool searchAutofocus,
  bool showWorldWide,
  bool showSearch,
  bool moveAlongWithKeyboard,
  CustomFlagBuilder? customFlagBuilder,
  FlagErrorBuilder? flagErrorBuilder,
) {
  final device = MediaQuery.of(context).size.height;
  final statusBarHeight = MediaQuery.of(context).padding.top;
  final height = countryListTheme?.bottomSheetHeight ??
      device - (isPlatformIOS ? 0 : (statusBarHeight + (kToolbarHeight / 1.5)));
  final width = countryListTheme?.bottomSheetWidth;

  Color? _backgroundColor = countryListTheme?.backgroundColor ??
      Theme.of(context).bottomSheetTheme.backgroundColor;

  if (_backgroundColor == null) {
    if (Theme.of(context).brightness == Brightness.light) {
      _backgroundColor = Colors.white;
    } else {
      _backgroundColor = Colors.black;
    }
  }

  final BorderRadius _borderRadius = countryListTheme?.borderRadius ??
      const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      );

  return Material(
    type: MaterialType.transparency,
    child: Padding(
      padding: moveAlongWithKeyboard
          ? MediaQuery.of(context).viewInsets
          : EdgeInsets.zero,
      child: Container(
        height: height,
        width: width,
        padding: countryListTheme?.padding,
        margin: countryListTheme?.margin,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: _borderRadius,
        ),
        child: CountryListView(
          defaultCountryCode: defaultCountryCode,
          selectedCountry: selectedCountry,
          onSelect: onSelect,
          exclude: exclude,
          favorite: favorite,
          countryFilter: countryFilter,
          showPhoneCode: showPhoneCode,
          countryListTheme: countryListTheme,
          countryListItemTheme: countryListItemTheme,
          searchAutofocus: searchAutofocus,
          showWorldWide: showWorldWide,
          showSearch: showSearch,
          customFlagBuilder: customFlagBuilder,
          flagErrorBuilder: flagErrorBuilder,
        ),
      ),
    ),
  );
}
