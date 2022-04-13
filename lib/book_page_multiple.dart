import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:page_view_indicators/linear_progress_page_indicator.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:after_init/after_init.dart';

import 'book_model.dart';

class BookPageMultiple extends StatefulWidget {
  final BookPosition pos;

  BookPageMultiple(this.pos);

  @override
  _BookPageMultipleState createState() => _BookPageMultipleState();
}

class _BookPageMultipleState extends State<BookPageMultiple>
    with AfterInitMixin<BookPageMultiple>, SingleTickerProviderStateMixin {
  BookModel get model => widget.pos.model!;
  BookPosition get pos => widget.pos;

  bool ready = false;
  List<BookPosition> bookPos = [];
  late int initialPos;
  int totalChapters = 0;

  @override
  void initState() {
    super.initState();

    BookPosition? curPos = (model.hasChapters)
        ? BookPosition.index(pos.index!, chapter: 0)
        : BookPosition.index(IndexPath(section: 0, index: 0));

    do {
      bookPos.add(curPos!);

      if (curPos == pos) {
        initialPos = totalChapters;
      }

      totalChapters++;
      curPos = model.getNextSection(curPos);
    } while (curPos != null);
  }


  @override
  void didInitState() {

  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Container();

    return Container();
  }
}
