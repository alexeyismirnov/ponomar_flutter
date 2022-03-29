import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'troparion_model.dart';
import 'book_page_single.dart';
import 'audio_player.dart';

class TroparionView extends StatefulWidget {
  final List<Troparion> troparia;
  const TroparionView(this.troparia);

  @override
  _TroparionViewState createState() => _TroparionViewState();
}

class _TroparionViewState extends State<TroparionView> {
  String title = "Тропари и кондаки";
  late double fontSize;

  @override
  void initState() {
    super.initState();

    fontSize = ConfigParam.fontSize.val();
  }

  Widget buildTroparion(Troparion t) {
    List<Widget> content = [];

    final glas = t.glas ?? "";
    var title = t.title;

    if (glas.isNotEmpty) title += ", $glas";

    content.add(RichText(
      text: TextSpan(
          text: title,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
      textAlign: TextAlign.center,
    ));

    if ((t.url ?? "").isNotEmpty) {
      content.add(const SizedBox(height: 10));
      content.add(AudioPlayerView(t.url!));
      content.add(const SizedBox(height: 10));

    } else {
      content.add(const SizedBox(height: 20));
    }

    content.add(RichText(
        text: TextSpan(children: [
      TextSpan(
          text: "${t.content}\n",
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: fontSize))
    ])));
    content.add(const SizedBox(height: 10));

    return Column(children: content);
  }

  @override
  Widget build(BuildContext context) => BookPageSingle(
      title,
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.troparia.map((t) => buildTroparion(t)).toList()));
}