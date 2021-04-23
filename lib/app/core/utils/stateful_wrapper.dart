// 🐦 Flutter imports:
import 'package:flutter/material.dart';

extension WidgetWrapper on Widget {
  Widget statefulWrapper(
      {Function? onInit,
      Function? afterFirstLayout,
      Function? deactivate,
      Function? didUpdateWidget,
      Function? dispose}) {
    return StatefulWrapper(
      onInit: onInit,
      afterFirstLayout: afterFirstLayout,
      deactivate: deactivate,
      didUpdateWidget: didUpdateWidget,
      dispose: dispose,
      child: this,
    );
  }

  Widget onInit(Function onInit) {
    return StatefulWrapper(onInit: onInit, child: this);
  }

  Widget afterFirstLayout(Function afterFirstLayout) {
    return StatefulWrapper(afterFirstLayout: afterFirstLayout, child: this);
  }
}

/// Wrapper for stateful functionality to provide onInit calls in stateles widget
class StatefulWrapper extends StatefulWidget {
  const StatefulWrapper(
      {this.onInit,
      this.afterFirstLayout,
      required this.child,
      this.didUpdateWidget,
      this.deactivate,
      this.dispose});

  final Function? afterFirstLayout;
  final Widget child;
  final Function? deactivate;
  final Function? didUpdateWidget;
  final Function? dispose;
  final Function? onInit;

  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper>
    with AfterLayoutMixin<StatefulWrapper> {
  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.afterFirstLayout != null) {
      widget.afterFirstLayout!();
    }
  }

  @override
  void deactivate() {
    if (widget.deactivate != null) {
      widget.deactivate!();
    }
    super.deactivate();
  }

  @override
  void didUpdateWidget(StatefulWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget!(oldWidget);
    }
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose!();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit!();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context);
}
