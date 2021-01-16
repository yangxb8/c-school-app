import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:c_school_app/app/model/speech_exam.dart';
import 'package:c_school_app/service/app_state_service.dart';
import '../ui_view/speech_exam_bottom_sheet.dart';

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
              onPressed: (BuildContext _) => showSpeechExamBottomSheet(
                  exam: SpeechExam()
                    ..refText = '大家好才是真的好。'
                    ..question = 'TEST'
                    ..title = 'TEST'))
        ],
      ),
    ];
  }
}
