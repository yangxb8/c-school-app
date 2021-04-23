// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

// 🌎 Project imports:
import '../../data/model/exam/speech_exam.dart';
import '../../data/service/app_state_service.dart';
import '../../global_widgets/speech_exam_bottom_sheet.dart';

class SettingPanelHomeScreen extends StatelessWidget {
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
              elevation: 2.0,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ];
  }

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
}
