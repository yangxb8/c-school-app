import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:spoken_chinese/controller/review_words_controller.dart';

class WordsList extends GetView<ReviewWordsController> {
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
      ]
    );
  }
}
