// 🐦 Flutter imports:
import 'package:flutter/material.dart';

///
/// Wrap around any widget that makes an async call to show a modal progress
/// indicator while the async call is in progress.
///
/// The progress indicator can be turned on or off using [inAsyncCall]
///
/// The progress indicator defaults to a [CircularProgressIndicator] but can be
/// any kind of widget
///
/// The progress indicator can be positioned using [offset] otherwise it is
/// centered
///
/// The modal barrier can be dismissed using [dismissible]
///
/// The color of the modal barrier can be set using [color]
///
/// The opacity of the modal barrier can be set using [opacity]
///
/// HUD=Heads Up Display
///
class ProgressHUD extends StatelessWidget {
  ProgressHUD({
    Key? key,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.progressIndicator = const CircularProgressIndicator(),
    this.offset,
    this.dismissible = false,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final Color color;
  final bool dismissible;
  final bool inAsyncCall;
  final Offset? offset;
  final double opacity;
  final Widget progressIndicator;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    widgetList.add(child);
    if (inAsyncCall) {
      Widget layOutProgressIndicator;
      if (offset == null) {
        layOutProgressIndicator = Center(child: progressIndicator);
      } else {
        layOutProgressIndicator = Positioned(
          left: offset!.dx,
          top: offset!.dy,
          child: progressIndicator,
        );
      }
      final modal = [
        Opacity(
          opacity: opacity,
          child: ModalBarrier(dismissible: dismissible, color: color),
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return Stack(
      children: widgetList,
    );
  }
}
