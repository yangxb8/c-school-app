import '../../core/service/app_state_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:styled_widget/styled_widget.dart';

const speedIconStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);

class ToggleAudioSpeedAction extends StatelessWidget {
  ToggleAudioSpeedAction({Key? key}) : super(key: key);

  final AppStateService appStateService = Get.find();

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Obx(() => Text(
            appStateService.audioSpeed.value == 1.0 ? '🐇' : '🐢',
            style: speedIconStyle,
          ).borderRadius(all: 10)),
      onPressed: appStateService.toggleAudioSpeed,
    );
  }
}
