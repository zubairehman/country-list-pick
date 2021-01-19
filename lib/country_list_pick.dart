import 'package:flutter/material.dart';

import 'country_selection_theme.dart';
import 'selection_list.dart';
import 'support/code_countries_en.dart';
import 'support/code_country.dart';
import 'support/code_countrys.dart';

export 'support/code_country.dart';

export 'country_selection_theme.dart';

class CountryListPick extends StatefulWidget {
  CountryListPick({
    this.onChanged,
    this.enabled,
    this.initialSelection,
    this.appBar,
    this.pickerBuilder,
    this.countryBuilder,
    this.theme,
    this.localizedStrings,
  });

  final Map<String, String> localizedStrings;
  final bool enabled;
  final String initialSelection;
  final ValueChanged<CountryCode> onChanged;
  final PreferredSizeWidget appBar;
  final Widget Function(BuildContext context, CountryCode countryCode)
      pickerBuilder;
  final CountryTheme theme;
  final Widget Function(BuildContext context, CountryCode countryCode)
      countryBuilder;

  @override
  _CountryListPickState createState() {
    List<Map> jsonList =
        this.theme?.showEnglishName ?? true ? countriesEnglish : codes;

    List elements = jsonList
        .map((s) => CountryCode(
              name: s['name'],
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: 'flags/${s['code'].toLowerCase()}.png',
            ))
        .toList();
    return _CountryListPickState(elements);
  }
}

class _CountryListPickState extends State<CountryListPick> {
  CountryCode selectedItem;
  List elements = [];

  _CountryListPickState(this.elements);

  @override
  void initState() {
    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
          (e) =>
              (e.code.toUpperCase() == widget.initialSelection.toUpperCase()) ||
              (e.dialCode == widget.initialSelection) ||
              (e.name == widget.initialSelection),
          orElse: () => elements[0] as CountryCode);
    } else {
      selectedItem = elements[0];
    }

    super.initState();
  }

  void _awaitFromSelectScreen(BuildContext context, PreferredSizeWidget appBar,
      CountryTheme theme) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectionList(
            elements,
            selectedItem,
            localizedStrings: widget.localizedStrings,
            appBar: widget.appBar ??
                AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  title: Text(widget.localizedStrings['country_selection_select_country']),
                ),
            theme: theme,
            countryBuilder: widget.countryBuilder,
          ),
        ));

    setState(() {
      selectedItem = result ?? selectedItem;
      widget.onChanged(result ?? selectedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // padding: EdgeInsets.symmetric(horizontal: 0.0),
      onTap: () {
        if (widget.enabled) {
          _awaitFromSelectScreen(context, widget.appBar, widget.theme);
        }
      },
      child: widget.pickerBuilder != null
          ? widget.pickerBuilder(context, selectedItem)
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                if (widget.theme?.isShowFlag ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.asset(
                        selectedItem.flagUri,
                        package: 'country_list_pick',
                        width: 22.0,
                      ),
                    ),
                  ),
                if (widget.theme?.isShowCode ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(selectedItem.toString()),
                    ),
                  ),
                if (widget.theme?.isShowTitle ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        selectedItem.toCountryStringOnly().toUpperCase(),
                        style: TextStyle(
                            color: Color(0xFFA8ADB7),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (widget.theme?.isDownIcon ?? true == true)
                  Flexible(
                    child: Icon(Icons.keyboard_arrow_down),
                  )
              ],
            ),
    );
  }
}
