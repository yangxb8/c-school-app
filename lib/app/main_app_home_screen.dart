// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'discover_panel/discover_panel_home_screen.dart';
import 'review_panel/review_panel_home_screen.dart';
import 'setting_panel/setting_panel_home_screen.dart';
import 'study_panel/study_panel_home_screen.dart';

class MainAppHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ObxValue(
        (RxInt panelIndex) => Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: panelIndex.value,
              selectedItemColor: Colors.lightBlueAccent,
              unselectedItemColor: Colors.grey,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: const Icon(Icons.border_color), label: 'home.panel.study.title'.tr),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.explore), label: 'home.panel.discover.title'.tr),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.library_books), label: 'home.panel.review.title'.tr),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.supervisor_account),
                    label: 'home.panel.account.title'.tr),
              ],
              onTap: (int i) => panelIndex.value = i,
            ),
            body: activatePanel(panelIndex.value)!),
        0.obs);
  }

  Widget? activatePanel(int panelIdx) {
    switch (panelIdx) {
      case 0:
        return StudyPanelHomeScreen();
      case 1:
        return DiscoverPanelHomeScreen();
      case 2:
        return ReviewPanelHomeScreen();
      case 3:
        return SettingPanelHomeScreen();
      default:
        return null;
    }
  }
}
