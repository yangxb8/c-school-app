// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:styled_widget/styled_widget.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/app/ui_view/speech_exam_bottom_sheet.dart';
import 'package:c_school_app/service/app_state_service.dart';

import '../ui_view/charts.dart';

class SettingPanelHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var value = true;
    return SettingsList(
      sections: [
            SettingsSection(
              title: 'Section',
              tiles: [
                SettingsTile(
                  title: 'Language',
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint),
                  switchValue: value,
                  onToggle: (bool value) {},
                ),
              ],
            ),
          ] +
          (AppStateService.isDebug ? _getDebugSection() : []),
    );
  }

  List<SettingsSection> _getDebugSection() {
    return [
      SettingsSection(
        title: 'Debug Section',
        tiles: [
          SettingsTile(
              title: 'Recorder dialog',
              leading: Icon(Icons.mic),
              //TODO: fetch exam properly
              onPressed: (_) => Get.bottomSheet(
                  SpeechExamBottomSheet(
                      exam: SpeechExam()
                        ..refText = '大家好才是真的好。'
                        ..question = 'TEST'
                        ..title = 'TEST'),
                  elevation: 2.0)),
          SettingsTile(
              title: 'Evaluation Result Chart',
              leading: Icon(Icons.quickreply_outlined),
              //TODO: fetch exam properly
              onPressed: (_) => Get.dialog(SizedBox(
                height: 200,
                width: 300,
                child: SpeechEvaluationRadialBarChart(sentenceInfo: testData))
                    .card().center(),
              )),
        ],
      ),
    ];
  }
}
