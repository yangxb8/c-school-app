// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

// 🌎 Project imports:
import '../../data/model/exam/speech_exam.dart';
import '../../core/service/app_state_service.dart';
import '../../global_widgets/speech_evaluation/speech_evaluation.dart';

class SettingPanelHomeScreen extends StatelessWidget {
  List<SettingsSection> _getDebugSection() {
    return [
      SettingsSection(
        title: 'Debug Section',
        tiles: [
          SettingsTile(
              title: 'Recorder dialog',
              leading: Icon(Icons.mic),
              trailing: null,
              //TODO: fetch exam properly
              onPressed: (_) => Get.bottomSheet(
                    SpeechEvaluation(
                        exam: SpeechExam()
                          ..refText = '大家好才是真的好。'.split('')
                          ..refPinyins = [
                            'dà',
                            'jiā',
                            'hǎo',
                            'cái',
                            'shì',
                            'zhēn',
                            'de',
                            'hǎo',
                            '。'
                          ]
                          ..question = 'TEST'
                          ..title = 'TEST'),
                    elevation: 2.0,
                    backgroundColor: Colors.white,
                  )),
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
          (Get.find<AppStateService>().isDebug ? _getDebugSection() : []),
    );
  }
}
