import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:c_school_app/app/models/class.dart';
import './classes_list_view.dart';
import 'review_words_theme.dart';
import '../../../i18n/review_words.i18n.dart';

class ReviewWordsHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ReviewWordsTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: getAllClassesUI(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAllClassesUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'All Course'.i18n,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: ReviewWordsTheme.darkerText,
            ),
          ),
          Flexible(
            child: CSchoolClassListView(
              callBack: (CSchoolClass cschoolClass) {
                Get.toNamed('/review/words?classId=${cschoolClass.classId}');
              },
            ),
          )
        ],
      ),
    );
  }
}
