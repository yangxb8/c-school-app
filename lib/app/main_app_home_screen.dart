// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/main_app_controller.dart';
import 'discover_panel/discover_panel_home_screen.dart';
import 'review_panel/review_panel_home_screen.dart';
import 'setting_panel/setting_panel_home_screen.dart';
import 'study_panel/study_panel_home_screen.dart';

class MainAppHomeScreen extends StatefulWidget {
  @override
  _MainAppHomeScreenState createState() => _MainAppHomeScreenState();
}

class _MainAppHomeScreenState extends State<MainAppHomeScreen> with TickerProviderStateMixin{
  final MainAppController controller = Get.find();
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.lightBlue,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.border_color), label: 'home.panel.study.title'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'home.panel.discover.title'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'home.panel.review.title'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), label: 'home.panel.account.title'.tr),
          ],
          onTap: (int i) => controller.panelIndex.value = i,
        ),
        body: Obx(() => activatePanel(controller.panelIndex.value)));
  }

  Widget activatePanel(int panelIdx) {
    switch (panelIdx) {
      case 0:
        return StudyPanelHomeScreen(
          animationController: animationController,
        );
      case 1:
        return DiscoverPanelHomeScreen();
      case 2:
        return ReviewPanelHomeScreen(
          animationController: animationController,
        );
      case 3:
        return SettingPanelHomeScreen();
      default:
        return null;
    }
  }
}
