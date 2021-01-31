// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:c_school_app/controller/main_app_controller.dart';
import '../i18n/main_app_home_screen.i18n.dart';
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
  void initState() async{
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
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Colors.lightBlue,
          style: TabStyle.textIn,
          items: [
            TabItem(icon: Icons.border_color, title: 'Study'.i18n),
            TabItem(icon: Icons.explore, title: 'Discover'.i18n),
            TabItem(icon: Icons.library_books, title: 'Review'.i18n),
            TabItem(icon: Icons.supervisor_account, title: 'Account'.i18n),
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
