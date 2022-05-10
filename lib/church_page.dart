import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:store_redirect/store_redirect.dart';

import 'card_view.dart';

class ChurchPage extends StatefulWidget {
  @override
  _ChurchPageState createState() => _ChurchPageState();
}

class _ChurchPageState extends State<ChurchPage> {
  Widget getContent() {
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Text("church_hk".tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6)),
      ]),
      const SizedBox(height: 20),
      Text("church_info".tr(), style: Theme.of(context).textTheme.subtitle1),
      const SizedBox(height: 10),
      Text("app_info".tr(), style: Theme.of(context).textTheme.subtitle1),
      const SizedBox(height: 10),
      SimpleCard(
          title: "install_church_app".tr(),
          image: "church_icon.jpg",
          onTap: () =>
              StoreRedirect.redirect(androidAppId: "com.rlc.church", iOSAppId: "1566259967")),
    ]);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(15), child: getContent())));
}
