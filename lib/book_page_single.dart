import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'book_model.dart';
import 'bible_model.dart';

class BookPageSingle extends StatefulWidget {
  final BookPosition pos;
  const BookPageSingle(this.pos);

  @override
  _BookPageSingleState createState() => _BookPageSingleState();
}

class _BookPageSingleState extends State<BookPageSingle> {
  BookPosition get pos => widget.pos;

  bool ready = false;
  String title = "";
  late BibleUtil content;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(() => setState(() {}));

    pos.model!.getTitle(pos).then((_title) {
      title = _title ?? "";
      return pos.model!.getContent(pos);
    }).then((_result) {
      content = _result;

      setState(() {
        ready = true;
      });
    });
  }

  Widget getContent() {
    if (!ready) return Container();

    return RichText(text: TextSpan(children: content.getTextSpan(context)));

    //return Text(content, style: Theme.of(context).textTheme.titleMedium);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: SafeArea(
                bottom: false,
                child: Scrollbar(
                    controller: _scrollController,
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: AppTheme.bg_decor_2() ??
                            BoxDecoration(color: Theme.of(context).canvasColor),
                        child: SafeArea(
                            bottom: true,
                            child: CustomScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                    elevation: 0.0,
                                    floating: true,
                                    toolbarHeight: 50.0,
                                    pinned: false,
                                    title: Text(title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.headline6),
                                  ),

                                  SliverToBoxAdapter(
                                      child: Padding(
                                          padding: const EdgeInsets.all(15), child: getContent()))
                                  //    Padding(padding: const EdgeInsets.all(15), child: getContent())
                                ])))))));
  }
}
