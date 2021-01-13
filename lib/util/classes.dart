import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';

/// Wrapper for stateful functionality to provide onInit calls in stateles widget
class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Function afterFirstLayout;
  final Widget child;
  const StatefulWrapper(
      {this.onInit, this.afterFirstLayout, @required this.child});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper>
    with AfterLayoutMixin<StatefulWrapper> {
  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.afterFirstLayout != null) {
      widget.afterFirstLayout();
    }
  }
}
