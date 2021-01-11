import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/model/exams.dart';
import '../../controller/ui_view_controller/speech_recording_controller.dart';

class FloatBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  const FloatBottomSheetContainer({Key key, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showSpeechExamBottomSheet<T>({@required SpeechExam exam}) async {
  final result = await showCustomModalBottomSheet(
    context: Get.context,
    builder: (context, scrollController) => SpeechExamBottomSheet(exam: exam),
    containerWidget: (_, animation, child) => FloatBottomSheetContainer(
      child: child,
    ),
    expand: false,
    useRootNavigator: true,
    isDismissible: false,
    enableDrag: false,
  );

  return result;
}

// SpeechExamBottomSheetController is prepared in main.initServices()
class SpeechExamBottomSheet extends GetView<SpeechRecordingController> {
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);
  final SpeechExam exam;
  static final int MAX_SPEECHES_SHOWN = 4;
  SpeechExamBottomSheet({Key key, @required this.exam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // set exam of controller
    controller.initWithExam(exam);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(FontAwesome5.comment_dots),
                IconButton(
                  icon: Icon(FontAwesome.times_circle),
                  onPressed: () => Get.back(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: IconButton(
                icon: Icon(FontAwesome.play_circle),
                onPressed: () => controller.playQuestion,
              ),
              title: Row(
                children: exam.question.split('').asMap().entries.map((entry) {
                  var idx = entry.key;
                  var word = entry.value;
                  TextButton(
                    onPressed: () => controller.wordSelected.value = idx,
                    child: Text(word),
                  );
                }) as List,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            //TODO: replace this row with last speech result analysis
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                controller.lastSpeech == null
                    ? Container()
                    : RadarChart(
                        data: [
                          [
                            controller.lastSpeech.evaluationResult.PronAccuracy
                                .toInt(),
                            (controller.lastSpeech.evaluationResult
                                        .PronFluency *
                                    100)
                                .toInt(),
                            (controller.lastSpeech.evaluationResult
                                        .PronCompletion *
                                    100)
                                .toInt()
                          ]
                        ],
                        features: [
                          'PronAccuracy',
                          'PronFluency',
                          'PronCompletion'
                        ],
                        ticks: [0, 50, 100],
                      ),
                controller.lastSpeech ==null
                    ? Container()
                    : BarChart(
                        //TODO: make bar chart properly
                        null,
                        swapAnimationDuration: animDuration,
                      )
              ],
            ),
          ),
          Center(
            child: IconButton(
              icon: Icon(FontAwesome.microphone),
              onPressed: () => controller.handleRecordButtonPressed(),
              iconSize: 35.0,
            ),
          ),
        ],
      ),
    );
  }
}
