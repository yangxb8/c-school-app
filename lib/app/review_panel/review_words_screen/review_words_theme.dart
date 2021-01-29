import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class ReviewWordsTheme {

  ReviewWordsTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFFFFFF);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);

  static Color lightBlue = '#B5D0FA'.toColor();
  static Color darkBlue = '#484C75'.toColor();
  static Color lightYellow = '#FBEB99'.toColor();
  static Color lightGreen = '#21B2BB'.toColor();

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText1: body2,
    bodyText2: body1,
    caption: caption,
  );

  static TextStyle lectureCardLevel = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    letterSpacing: 0.27,
    color: lightGreen,
  );

  static TextStyle lectureCardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle lectureCardMeta = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 19,
    letterSpacing: 0.27,
    color: ReviewWordsTheme.darkBlue,
  );

  static TextStyle wordCardWord = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 55,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordListTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 35,
    letterSpacing: 0.27,
    color: lightYellow,
  );

  static TextStyle wordListItem = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 25,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordListItemPinyin = wordListItem.copyWith(
    fontSize: 30,
  );

  static TextStyle wordCardMeaning = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 45,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordCardHint = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 25,
      letterSpacing: 0.27,
      color: darkBlue,
      decoration: TextDecoration.none
  );

  static TextStyle wordCardPinyin = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 40,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordCardSubTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordCardExample = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 25,
    letterSpacing: 0.27,
    color: darkBlue,
  );

  static TextStyle wordCardExamplePinyin = wordCardExample.copyWith(
    fontSize: 20,
    letterSpacing: 0.2,
  );

  static TextStyle wordCardExampleCenterWord = wordCardExample.copyWith(
    fontWeight: FontWeight.bold,
  );

  static TextStyle wordCardExampleLinkedWord = wordCardExample.copyWith(
    decoration: TextDecoration.underline,
  );

  static TextStyle exampleMeaning = wordCardExample.copyWith(
    fontSize: 20,
    color: Colors.grey,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}
