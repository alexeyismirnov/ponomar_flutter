import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'calendar_appbar.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late DateTime date;
  late DateTime savedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context,
                          bool innerBoxIsScrolled) =>
                      [CalendarAppbar(title: "library", showActions: false)],
                  body: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(child: Text("library page")))))));
}
