import '../../core/values/icons/c_school_icons.dart';
import '../../core/service/app_state_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class ToggleGenderAction extends StatelessWidget {
  ToggleGenderAction({Key? key}) : super(key: key);

  final AppStateService appStateService = Get.find();

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Obx(() => appStateService.speakerGender.value == SpeakerGender.male
          ? Icon(CSchool.male)
          : Icon(CSchool.female)),
      onPressed: Get.find<AppStateService>().toggleSpeakerGender,
    );
  }
}
