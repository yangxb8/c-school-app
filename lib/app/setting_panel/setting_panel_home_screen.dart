import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:spoken_chinese/app/models/exams.dart';
import 'package:spoken_chinese/service/app_state_service.dart';
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
                  onTap: () {},
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

  List<SettingsSection> _getDebugSection() {
    return [
      SettingsSection(
        title: 'Debug Section',
        tiles: [
          SettingsTile(
            title: 'Recorder dialog',
            leading: Icon(Icons.mic),
            //TODO: fetch exam properly
            onTap: () => showSpeechExamBottomSheet(
                exam: SpeechExam(
                    questionVoiceData: null,
                    examId: null,
                    mode: null,
                    refText: null,
                    title: null,
                    question: null,
                    lectureId: null)),
          ),
        ],
      ),
    ];
  }
}
