import 'package:flutter/material.dart';
import 'package:ponomar/globals.dart';
import 'package:supercharged/supercharged.dart';
import 'dart:ui';

import 'church_calendar.dart';

enum FastingLevel { laymen, monastic }

enum FastingType {
  noFast,
  vegetarian,
  fishAllowed,
  fastFree,
  cheesefare,
  noFood,
  xerophagy,
  withoutOil,
  withOil,
  noFastMonastic
}

typedef FT = FastingType;

extension FastingTypeExt on FastingType {
  String get description => [
        "no_fast",
        "vegetarian",
        "fish_allowed",
        "fast_free",
        "maslenitsa",
        "no_food",
        "xerophagy",
        "without_oil",
        "with_oil",
        "no_fast"
      ][index];

  String get icon => [
        "food-salami.svg",
        "food-vegetables.svg",
        "food-fish.svg",
        "food-cupcake.svg",
        "food-pancake.svg",
        "food-nothing.svg",
        "food-fruits.svg",
        "food-without-oil.svg",
        "food-vegetables.svg",
        "food-mexican.svg",
      ][index];

  Color get color => [
        Colors.transparent,
        HexColor.fromHex("#30D5C8"),
        HexColor.fromHex("#FF9933"),
        HexColor.fromHex("#00BFFF"),
        HexColor.fromHex("#00BFFF"),
        HexColor.fromHex("#7B78EE"),
        HexColor.fromHex("#B4EEB4"),
        HexColor.fromHex("#9BCD9B"),
        HexColor.fromHex("#30D5C8"),
        Colors.transparent
      ][index];
}

class FastingModel {
  FastingType type;
  String description;

  static List<FastingType> get types {
    return ChurchFasting.fastingLevel == FastingLevel.laymen
        ? [FastingType.vegetarian, FastingType.fishAllowed, FastingType.fastFree]
        : [
            FastingType.noFood,
            FastingType.xerophagy,
            FastingType.withoutOil,
            FastingType.withOil,
            FastingType.fishAllowed,
            FastingType.fastFree
          ];
  }

  FastingModel(this.type, [_description]) : description = _description ?? type.description;
}

class ChurchFasting {
  static FastingLevel fastingLevel = FastingLevel.laymen;

  late Cal cal;
  late DateTime stNicholas;

  ChurchFasting(DateTime d) {
    cal = Cal.fromDate(d);
    stNicholas = DateTime(cal.year, 12, 19);
  }

  static Map<int, ChurchFasting> models = {};

  static FastingModel forDate(DateTime date) {
    if (!models.containsKey(date.year)) {
      models[date.year] = ChurchFasting(date);
    }

    return ChurchFasting.fastingLevel == FastingLevel.laymen
        ? models[date.year]!.getFastingLaymen(date)
        : models[date.year]!.getFastingMonastic(date);
  }

  FastingModel getFastingLaymen(DateTime date) {
    if (date == cal.d("meetingOfLord")) {
      return meetingOfLord(date, monastic: false);
    } else if (date == cal.d("theophany")) {
      return FastingModel(FT.noFast);
    } else if (date == cal.d("nativityOfTheotokos") ||
        date == cal.d("peterAndPaul") ||
        date == cal.d("dormition") ||
        date == cal.d("veilOfTheotokos")) {
      return _isWedFri(date) ? FastingModel(FT.fishAllowed) : FastingModel(FT.noFast);
    } else if (date == cal.d("nativityOfJohn") ||
        date == cal.d("transfiguration") ||
        date == cal.d("entryIntoTemple") ||
        date == cal.d("palmSunday") ||
        date == stNicholas) {
      return FastingModel(FT.fishAllowed);
    } else if (date == cal.d("eveOfTheophany") ||
        date == cal.d("beheadingOfJohn") ||
        date == cal.d("exaltationOfCross")) {
      return FastingModel(FT.vegetarian, "fast_day");
    } else if (date == cal.startOfYear) {
      return _isSatSun(date)
          ? FastingModel(FT.fishAllowed, "nativity_fast")
          : FastingModel(FT.vegetarian, "nativity_fast");
    } else if (date.isBetween(cal.startOfYear + 1.days, cal.d("nativityOfGod") - 1.days)) {
      return FastingModel(FT.vegetarian, "nativity_fast");
    } else if (date.isBetween(cal.d("nativityOfGod"), cal.d("eveOfTheophany") - 1.days)) {
      return FastingModel(FT.fastFree, "svyatki");
    } else if (date.isBetween(
        cal.d("sundayOfPublicianAndPharisee") + 1.days, cal.d("sundayOfProdigalSon"))) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(
        cal.d("sundayOfDreadJudgement") + 1.days, cal.greatLentStart - 1.days)) {
      return FastingModel(FT.cheesefare);
    } else if (date.isBetween(cal.greatLentStart, cal.d("palmSunday") - 1.days)) {
      return (date == cal.d("annunciation"))
          ? FastingModel(FT.fishAllowed)
          : FastingModel(FT.vegetarian, "great_lent");
    } else if (date.isBetween(cal.d("palmSunday") + 1.days, cal.pascha - 1.days)) {
      return FastingModel(FT.vegetarian);
    } else if (date.isBetween(cal.pascha + 1.days, cal.pascha + 7.days)) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(cal.pentecost + 1.days, cal.pentecost + 7.days)) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(cal.d("beginningOfApostlesFast"), cal.d("peterAndPaul") - 1.days)) {
      return _isMonWedFri(date)
          ? FastingModel(FT.vegetarian, "apostles_fast")
          : FastingModel(FT.fishAllowed, "apostles_fast");
    } else if (date.isBetween(cal.d("beginningOfDormitionFast"), cal.d("dormition") - 1.days)) {
      return FastingModel(FT.vegetarian, "dormition_fast");
    } else if (date.isBetween(cal.d("beginningOfNativityFast"), stNicholas - 1.days)) {
      return _isMonWedFri(date)
          ? FastingModel(FT.vegetarian, "nativity_fast")
          : FastingModel(FT.fishAllowed, "nativity_fast");
    } else if (date.isBetween(stNicholas, cal.endOfYear)) {
      return _isSatSun(date)
          ? FastingModel(FT.fishAllowed, "nativity_fast")
          : FastingModel(FT.vegetarian, "nativity_fast");
    } else if (date.isBetween(cal.d("nativityOfGod"), cal.pentecost + 7.days)) {
      return _isWedFri(date) ? FastingModel(FT.fishAllowed) : FastingModel(FT.noFast);
    } else {
      return _isWedFri(date) ? FastingModel(FT.vegetarian) : FastingModel(FT.noFast);
    }
  }

  FastingModel getFastingMonastic(DateTime date) {
    final palmSunday = cal.d("palmSunday");

    if (date == cal.d("meetingOfLord")) {
      return meetingOfLord(date, monastic: true);
    } else if (date == cal.d("theophany")) {
      return FastingModel(FT.noFastMonastic);
    } else if (date == cal.d("nativityOfTheotokos") ||
        date == cal.d("peterAndPaul") ||
        date == cal.d("dormition") ||
        date == cal.d("veilOfTheotokos")) {
      return _isMonWedFri(date) ? FastingModel(FT.fishAllowed) : FastingModel(FT.noFastMonastic);
    } else if (date == cal.d("nativityOfJohn") ||
        date == cal.d("transfiguration") ||
        date == cal.d("entryIntoTemple") ||
        date == cal.d("palmSunday") ||
        date == stNicholas) {
      return FastingModel(FT.fishAllowed);
    } else if (date == cal.d("eveOfTheophany")) {
      return FastingModel(FT.xerophagy, "fast_day");
    } else if (date == cal.d("beheadingOfJohn") || date == cal.d("exaltationOfCross")) {
      return FastingModel(FT.withOil, "fast_day");
    } else if (date == cal.startOfYear) {
      return _isTueThurs(date) ? FastingModel(FT.withOil) : monasticApostolesFast(date);
    } else if (date.isBetween(cal.startOfYear + 1.days, cal.d("nativityOfGod") - 1.days)) {
      return monasticGreatLent(date);
    } else if (date.isBetween(cal.d("nativityOfGod"), cal.d("eveOfTheophany") - 1.days)) {
      return FastingModel(FT.fastFree, "svyatki");
    } else if (date.isBetween(
        cal.d("sundayOfPublicianAndPharisee") + 1.days, cal.d("sundayOfProdigalSon"))) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(
        cal.d("sundayOfDreadJudgement") + 1.days, cal.greatLentStart - 1.days)) {
      return FastingModel(FT.cheesefare);
    } else if (date == cal.greatLentStart) {
      return FastingModel(FT.noFood);
    } else if (date.isBetween(cal.greatLentStart + 1.days, cal.greatLentStart + 4.days)) {
      return FastingModel(FT.xerophagy);
    } else if (date.isBetween(cal.greatLentStart + 5.days, palmSunday - 1.days)) {
      return (date == cal.d("annunciation"))
          ? FastingModel(FT.fishAllowed)
          : monasticGreatLent(date);
    } else if (date.isBetween(palmSunday + 1.days, palmSunday + 4.days)) {
      return FastingModel(FT.xerophagy);
    } else if (date == palmSunday + 5.days) {
      return FastingModel(FT.noFood);
    } else if (date == palmSunday + 6.days) {
      return FastingModel(FT.withOil);
    } else if (date.isBetween(cal.pascha + 1.days, cal.pascha + 7.days)) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(cal.pentecost + 1.days, cal.pentecost + 7.days)) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(cal.d("beginningOfApostlesFast"), cal.d("peterAndPaul") - 1.days)) {
      return monasticApostolesFast(date);
    } else if (date.isBetween(cal.d("beginningOfDormitionFast"), cal.d("dormition") - 1.days)) {
      return monasticGreatLent(date);
    } else if (date.isBetween(cal.d("beginningOfNativityFast"), stNicholas - 1.days)) {
      return monasticApostolesFast(date);
    } else if (date.isBetween(stNicholas, cal.endOfYear)) {
      return _isTueThurs(date) ? FastingModel(FT.withOil) : monasticApostolesFast(date);
    } else {
      return _isMonWedFri(date) ? FastingModel(FT.xerophagy) : FastingModel(FT.noFastMonastic);
    }
  }

  FastingModel meetingOfLord(DateTime date, {required bool monastic}) {
    if (date.isBetween(
        cal.d("sundayOfPublicianAndPharisee") + 1.days, cal.d("sundayOfProdigalSon"))) {
      return FastingModel(FT.fastFree);
    } else if (date.isBetween(
        cal.d("sundayOfDreadJudgement") + 1.days, cal.d("beginningOfGreatLent") - 1.days)) {
      return FastingModel(FT.cheesefare);
    } else if (date == cal.greatLentStart) {
      return monastic ? FastingModel(FT.noFood) : FastingModel(FT.vegetarian, "great_lent");
    } else {
      return _isMonWedFri(date)
          ? FastingModel(FT.fishAllowed)
          : FastingModel(monastic ? FT.noFastMonastic : FT.noFast);
    }
  }

  FastingModel monasticGreatLent(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.friday:
        return FastingModel(FT.xerophagy);
      case DateTime.tuesday:
      case DateTime.thursday:
        return FastingModel(FT.withoutOil);
      default:
        return FastingModel(FT.withOil);
    }
  }

  FastingModel monasticApostolesFast(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return FastingModel(FT.withoutOil);
      case DateTime.wednesday:
      case DateTime.friday:
        return FastingModel(FT.xerophagy);
      default:
        return FastingModel(FT.fishAllowed);
    }
  }
}

extension ChurchFastingFunc on ChurchFasting {
  bool _isWedFri(DateTime date) =>
      date.weekday == DateTime.wednesday || date.weekday == DateTime.friday;

  bool _isMonWedFri(DateTime date) =>
      date.weekday == DateTime.monday ||
      date.weekday == DateTime.wednesday ||
      date.weekday == DateTime.friday;

  bool _isSatSun(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  bool _isTueThurs(DateTime date) =>
      date.weekday == DateTime.tuesday || date.weekday == DateTime.thursday;
}
