import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../country_picker.dart';
import 'country_list_item.dart';
import 'country_list_item_theme_data.dart';
import 'res/country_codes.dart';

typedef CustomFlagBuilder = Widget Function(Country country);

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

const BoxDecoration _kDefaultRoundedBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

class CountryListView extends StatefulWidget {
  final String? defaultCountryCode;
  final Country? selectedCountry;

  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for customizing the country list item.
  final CountryListItemThemeData? countryListItemTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// Custom builder function for flag widget
  final CustomFlagBuilder? customFlagBuilder;
  final FlagErrorBuilder? flagErrorBuilder;

  const CountryListView({
    super.key,
    required this.onSelect,
    this.defaultCountryCode,
    this.selectedCountry,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.countryListItemTheme,
    this.searchAutofocus = false,
    this.showWorldWide = false,
    this.showSearch = true,
    this.customFlagBuilder,
    this.flagErrorBuilder,
  }) : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        );

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();

  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;
  String? _selectedCountryCode;
  ScrollController? _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    // Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    if (widget.selectedCountry != null || widget.defaultCountryCode != null) {
      final idx = widget.selectedCountry != null
          ? _countryList.indexWhere(
              (e) => e.countryCode == widget.selectedCountry!.countryCode)
          : _countryList.indexWhere(
              (e) => e.countryCode.toLowerCase() == widget.defaultCountryCode);
      if (idx != -1) {
        final countryFound = _countryList[idx];
        _selectedCountryCode = countryFound.countryCode;
        _countryList.removeAt(idx);
        _countryList.insert(0, countryFound);
      }
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    final String searchLabel = CountryLocalizations.of(context)
            ?.countryName(countryCode: 'procurar') ??
        'Procurar';

    return Column(
      children: <Widget>[
        SizedBox(height: isPlatformIOS ? 6 : 32),
        if (widget.showSearch) _buildSearch(context, searchLabel),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              children: [
                if (_favoriteList != null) ...[
                  ..._favoriteList!.map<Widget>(
                    (currency) => CountryListItem(
                      country: currency,
                      onSelect: widget.onSelect,
                      showPhoneCode: widget.showPhoneCode,
                      countryListItemTheme: widget.countryListItemTheme,
                      flagErrorBuilder: widget.flagErrorBuilder,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(thickness: 1),
                  ),
                ],
                ..._filteredList.map<Widget>(
                  (country) => CountryListItem(
                    country: country,
                    onSelect: widget.onSelect,
                    showPhoneCode: widget.showPhoneCode,
                    countryListItemTheme: widget.countryListItemTheme,
                    flagErrorBuilder: widget.flagErrorBuilder,
                    selectedCountryCode: _selectedCountryCode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);

  Widget _buildSearch(BuildContext context, String searchLabel) {
    return Padding(
      padding: EdgeInsets.only(
        left: !isPlatformIOS ? 8 : 14,
        right: isPlatformIOS ? 8 : 14,
        top: !isPlatformIOS ? 8 : 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isPlatformIOS)
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          Flexible(
            child: _buildTextField(context, searchLabel),
          ),
          if (isPlatformIOS)
            CupertinoButton(
              child: Text(
                "Cancelar",
                style: widget.countryListTheme?.iosCancelTextStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String searchLabel) {
    if (isPlatformIOS) {
      return CupertinoTextField(
        autofocus: _searchAutofocus,
        controller: _searchController,
        placeholder:
            widget.countryListTheme?.inputDecoration?.hintText ?? searchLabel,
        // placeholderStyle: widget.countryListTheme?.inputDecoration?.hintStyle,
        style: widget.countryListTheme?.searchTextStyle ?? _defaultTextStyle,
        prefix: const Padding(
          padding: EdgeInsets.only(
            left: 8,
            bottom: 2,
          ),
          child: Icon(
            CupertinoIcons.search,
            size: 22,
          ),
        ),
        decoration: BoxDecoration(
          color: const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGrey6,
            darkColor: CupertinoColors.black,
          ),
          // border: _kDefaultRoundedBorder,
          borderRadius: BorderRadius.circular(20),
        ),
        onChanged: _filterSearchResults,
      );
    }
    return TextField(
      autofocus: _searchAutofocus,
      controller: _searchController,
      style: widget.countryListTheme?.searchTextStyle ?? _defaultTextStyle,
      decoration: widget.countryListTheme?.inputDecoration ??
          InputDecoration(
            // labelText: searchLabel,
            hintText: searchLabel,
            // prefixIcon: const Icon(FeatherIcons.search),
            border: InputBorder.none,
          ),
      onChanged: _filterSearchResults,
    );
  }
}
