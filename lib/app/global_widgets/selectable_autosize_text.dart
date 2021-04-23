// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:auto_size_text/auto_size_text.dart';
// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableAutoSizeText extends StatelessWidget {
  /// Creates a [AutoSizeText] widget.
  ///
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing [DefaultTextStyle].
  const SelectableAutoSizeText(String this.data,
      {Key? key,
      this.textKey,
      this.style,
      this.strutStyle,
      this.minFontSize = 12,
      this.maxFontSize = double.infinity,
      this.stepGranularity = 1,
      this.presetFontSizes,
      this.textAlign,
      this.textDirection,
      this.wrapWords = true,
      this.overflow,
      this.overflowReplacement,
      this.textScaleFactor,
      this.maxLines,
      this.focusNode,
      this.autofocus = false,
      this.showCursor = false,
      this.cursorWidth = 2.0,
      this.cursorHeight,
      this.cursorRadius,
      this.cursorColor,
      this.enableInteractiveSelection = true,
      this.dragStartBehavior = DragStartBehavior.start,
      this.toolbarOptions,
      this.onTap,
      this.scrollPhysics,
      this.textHeightBehavior,
      this.textWidthBasis})
      : selectable = true,
        textSpan = null,
        locale = null,
        softWrap = null,
        semanticsLabel = null,
        super(key: key);

  /// Creates a [AutoSizeText] widget with a [TextSpan].
  const SelectableAutoSizeText.rich(TextSpan this.textSpan,
      {Key? key,
      this.textKey,
      this.style,
      this.strutStyle,
      this.minFontSize = 12,
      this.maxFontSize = double.infinity,
      this.stepGranularity = 1,
      this.presetFontSizes,
      this.textAlign,
      this.textDirection,
      this.wrapWords = true,
      this.overflow,
      this.overflowReplacement,
      this.textScaleFactor,
      this.maxLines,
      this.focusNode,
      this.autofocus = false,
      this.showCursor = false,
      this.cursorWidth = 2.0,
      this.cursorHeight,
      this.cursorRadius,
      this.cursorColor,
      this.enableInteractiveSelection = true,
      this.dragStartBehavior = DragStartBehavior.start,
      this.toolbarOptions,
      this.onTap,
      this.scrollPhysics,
      this.textHeightBehavior,
      this.textWidthBasis})
      : data = null,
        selectable = true,
        locale = null,
        softWrap = null,
        semanticsLabel = null,
        super(key: key);

  const SelectableAutoSizeText.richUnselectable(
    TextSpan this.textSpan, {
    Key? key,
    this.textKey,
    this.style,
    this.strutStyle,
    this.minFontSize = 12,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1,
    this.presetFontSizes,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.wrapWords = true,
    this.overflow,
    this.overflowReplacement,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
  })  : data = null,
        selectable = false,
        focusNode = null,
        autofocus = null,
        showCursor = null,
        cursorWidth = null,
        cursorHeight = null,
        cursorRadius = null,
        cursorColor = null,
        enableInteractiveSelection = null,
        dragStartBehavior = null,
        toolbarOptions = null,
        onTap = null,
        scrollPhysics = null,
        textHeightBehavior = null,
        textWidthBasis = null,
        super(key: key);

  const SelectableAutoSizeText.unselectable(
    String this.data, {
    Key? key,
    this.textKey,
    this.style,
    this.strutStyle,
    this.minFontSize = 12,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1,
    this.presetFontSizes,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.wrapWords = true,
    this.overflow,
    this.overflowReplacement,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
  })  : textSpan = null,
        selectable = false,
        focusNode = null,
        autofocus = null,
        showCursor = null,
        cursorWidth = null,
        cursorHeight = null,
        cursorRadius = null,
        cursorColor = null,
        enableInteractiveSelection = null,
        dragStartBehavior = null,
        toolbarOptions = null,
        onTap = null,
        scrollPhysics = null,
        textHeightBehavior = null,
        textWidthBasis = null,
        super(key: key);

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool? autofocus;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the theme's `cursorColor` when null.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double? cursorWidth;

  /// The text to display.
  ///
  /// This will be null if a [textSpan] is provided instead.
  final String? data;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior? dragStartBehavior;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool? enableInteractiveSelection;

  /// Defines the focus for this widget.
  ///
  /// Text is only selectable when widget is focused.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// focusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  final FocusNode? focusNode;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  final Locale? locale;

  /// The maximum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double maxFontSize;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be resized according
  /// to the specified bounds and if necessary truncated according to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// The minimum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double minFontSize;

  /// Called when the user taps on this selectable text.
  ///
  /// The selectable text builds a [GestureDetector] to handle input events like tap,
  /// to trigger focus requests, to move the caret, adjust the selection, etc.
  /// Handling some of those events by wrapping the selectable text with a competing
  /// GestureDetector is problematic.
  ///
  /// To unconditionally handle taps, without interfering with the selectable text's
  /// internal gesture detector, provide this callback.
  ///
  /// To be notified when the text field gains or loses the focus, provide a
  /// [focusNode] and add a listener to that.
  ///
  /// To listen to arbitrary pointer events without competing with the
  /// selectable text's internal gesture detector, use a [Listener].
  final GestureTapCallback? onTap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// If the text is overflowing and does not fit its bounds, this widget is
  /// displayed instead.
  final Widget? overflowReplacement;

  /// Predefines all the possible font sizes.
  ///
  /// **Important:** PresetFontSizes have to be in descending order.
  final List<double>? presetFontSizes;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// True if the text is selectable
  final bool selectable;

  /// An alternative semantics label for this text.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the actual text. This will overwrite any of the semantics labels applied
  /// directly to the [TextSpan]s.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// Text(r'$$', semanticsLabel: 'Double dollars')
  /// ```
  final String? semanticsLabel;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  final bool? softWrap;

  /// The step size in which the font size is being adapted to constraints.
  ///
  /// The Text scales uniformly in a range between [minFontSize] and
  /// [maxFontSize].
  /// Each increment occurs as per the step size set in stepGranularity.
  ///
  /// Most of the time you don't want a stepGranularity below 1.0.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double stepGranularity;

  /// The strut style to use. Strut style defines the strut, which sets minimum
  /// vertical layout metrics.
  ///
  /// Omitting or providing null will disable strut.
  ///
  /// Omitting or providing null for any properties of [StrutStyle] will result in
  /// default values being used. It is highly recommended to at least specify a
  /// font size.
  ///
  /// See [StrutStyle] for details.
  final StrutStyle? strutStyle;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's 'inherit' property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// Sets the key for the resulting [Text] widget.
  ///
  /// This allows you to find the actual `Text` widget built by `AutoSizeText`.
  final Key? textKey;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  ///
  /// This property also affects [minFontSize], [maxFontSize] and [presetFontSizes].
  ///
  /// The value given to the constructor as textScaleFactor. If null, will
  /// use the [MediaQueryData.textScaleFactor] obtained from the ambient
  /// [MediaQuery], or 1.0 if there is no [MediaQuery] in scope.
  final double? textScaleFactor;

  /// The text to display as a [TextSpan].
  ///
  /// This will be null if [data] is provided instead.
  final TextSpan? textSpan;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// Configuration of toolbar options.
  ///
  /// Paste and cut will be disabled regardless.
  ///
  /// If not set, select all and copy will be enabled by default.
  final ToolbarOptions? toolbarOptions;

  /// Whether words which don't fit in one line should be wrapped.
  ///
  /// If false, the fontSize is lowered as far as possible until all words fit
  /// into a single line.
  final bool wrapWords;

  // The default font size if none is specified.
  static const double _defaultFontSize = 14.0;

  void _sanityCheck(TextStyle? style, int? maxLines) {
    assert(overflow == null || overflowReplacement == null,
        'Either overflow or overflowReplacement have to be null.');
    assert(maxLines == null || maxLines > 0,
        'MaxLines has to be grater than or equal to 1.');
    assert(
        key == null || key != textKey, 'Key and textKey cannot be the same.');

    if (presetFontSizes == null) {
      assert(stepGranularity >= 0.1,
          'StepGranularity has to be greater than or equal to 0.1. It is not a good idea to resize the font with a higher accuracy.');
      assert(minFontSize >= 0,
          'MinFontSize has to be greater than or equal to 0.');
      assert(maxFontSize > 0, 'MaxFontSize has to be greater than 0.');
      assert(minFontSize <= maxFontSize,
          'MinFontSize has to be smaller or equal than maxFontSize.');
      assert(minFontSize / stepGranularity % 1 == 0,
          'MinFontSize has to be multiples of stepGranularity.');
      if (maxFontSize != double.infinity) {
        assert(maxFontSize / stepGranularity % 1 == 0,
            'MaxFontSize has to be multiples of stepGranularity.');
      }
    } else {
      assert(
          presetFontSizes!.isNotEmpty, 'PresetFontSizes has to be nonempty.');
    }
  }

  List _calculateFontSize(
      BoxConstraints size, TextStyle? style, int? maxLines) {
    var span = TextSpan(
      style: textSpan?.style ?? style,
      text: textSpan?.text ?? data,
      children: textSpan?.children,
      recognizer: textSpan?.recognizer,
    );

    var userScale =
        textScaleFactor ?? MediaQuery.textScaleFactorOf(Get.context!);

    int left;
    int right;

    var adjustedPresetFontSizes = presetFontSizes?.reversed.toList();
    if (adjustedPresetFontSizes == null) {
      num defaultFontSize = style!.fontSize!.clamp(minFontSize, maxFontSize);
      var defaultScale = defaultFontSize * userScale / style.fontSize!;
      if (_checkTextFits(span, defaultScale, maxLines, size)) {
        return [defaultFontSize * userScale, true];
      }

      left = (minFontSize / stepGranularity).floor();
      right = (defaultFontSize / stepGranularity).ceil();
    } else {
      left = 0;
      right = adjustedPresetFontSizes.length - 1;
    }

    var lastValueFits = false;
    while (left <= right) {
      var mid = (left + (right - left) / 2).toInt();
      double scale;
      if (adjustedPresetFontSizes == null) {
        scale = mid * userScale * stepGranularity / style!.fontSize!;
      } else {
        scale = adjustedPresetFontSizes[mid] * userScale / style!.fontSize!;
      }
      if (_checkTextFits(span, scale, maxLines, size)) {
        left = mid + 1;
        lastValueFits = true;
      } else {
        right = mid - 1;
      }
    }

    if (!lastValueFits) {
      right += 1;
    }

    double fontSize;
    if (adjustedPresetFontSizes == null) {
      fontSize = right * userScale * stepGranularity;
    } else {
      fontSize = adjustedPresetFontSizes[right] * userScale;
    }

    return [fontSize, lastValueFits];
  }

  bool _checkTextFits(
      TextSpan text, double? scale, int? maxLines, BoxConstraints constraints) {
    if (!wrapWords) {
      var words = text.toPlainText().split(RegExp('\\s+'));

      var wordWrapTp = TextPainter(
        text: TextSpan(
          style: text.style,
          text: words.join('\n'),
        ),
        textAlign: textAlign ?? TextAlign.left,
        textDirection: textDirection ?? TextDirection.ltr,
        textScaleFactor: scale ?? 1,
        maxLines: words.length,
        locale: locale,
        strutStyle: strutStyle,
      );

      wordWrapTp.layout(maxWidth: constraints.maxWidth);

      if (wordWrapTp.didExceedMaxLines ||
          wordWrapTp.width > constraints.maxWidth) {
        return false;
      }
    }

    var tp = TextPainter(
      text: text,
      textAlign: textAlign ?? TextAlign.left,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaleFactor: scale ?? 1,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
    );

    tp.layout(maxWidth: constraints.maxWidth);

    return !(tp.didExceedMaxLines ||
        tp.height > constraints.maxHeight ||
        tp.width > constraints.maxWidth);
  }

  Widget _buildText(double fontSize, TextStyle? style, int? maxLines) {
    if (selectable) {
      if (data != null) {
        return SelectableText(data!,
            key: textKey,
            focusNode: focusNode,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: fontSize / style!.fontSize!,
            showCursor: showCursor!,
            autofocus: autofocus!,
            toolbarOptions: toolbarOptions,
            maxLines: maxLines,
            cursorWidth: cursorWidth!,
            cursorHeight: cursorHeight,
            cursorRadius: cursorRadius,
            cursorColor: cursorColor,
            dragStartBehavior: dragStartBehavior!,
            enableInteractiveSelection: enableInteractiveSelection!,
            onTap: onTap,
            scrollPhysics: scrollPhysics,
            textHeightBehavior: textHeightBehavior,
            textWidthBasis: textWidthBasis);
      } else {
        return SelectableText.rich(textSpan!,
            key: textKey,
            focusNode: focusNode,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: fontSize / style!.fontSize!,
            showCursor: showCursor!,
            autofocus: autofocus!,
            toolbarOptions: toolbarOptions,
            maxLines: maxLines,
            cursorWidth: cursorWidth!,
            cursorHeight: cursorHeight,
            cursorRadius: cursorRadius,
            cursorColor: cursorColor,
            dragStartBehavior: dragStartBehavior!,
            enableInteractiveSelection: enableInteractiveSelection!,
            onTap: onTap,
            scrollPhysics: scrollPhysics,
            textHeightBehavior: textHeightBehavior,
            textWidthBasis: textWidthBasis);
      }
    } else {
      if (data != null) {
        return Text(
          data!,
          key: textKey,
          style: style!.copyWith(fontSize: fontSize),
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: 1,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
        );
      } else {
        return Text.rich(
          textSpan!,
          key: textKey,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: fontSize / style!.fontSize!,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      var defaultTextStyle = DefaultTextStyle.of(context);

      var adjustedStyle = style;
      if (style == null || style!.inherit) {
        adjustedStyle = defaultTextStyle.style.merge(style);
      }
      if (adjustedStyle!.fontSize == null) {
        adjustedStyle = adjustedStyle.copyWith(fontSize: _defaultFontSize);
      }

      var adjustedMaxLines = maxLines ?? defaultTextStyle.maxLines;

      _sanityCheck(adjustedStyle, adjustedMaxLines);

      var result = _calculateFontSize(size, adjustedStyle, adjustedMaxLines);
      var fontSize = result[0] as double;
      var textFits = result[1] as bool;

      Widget text;

      text = _buildText(fontSize, adjustedStyle, adjustedMaxLines);

      if (overflowReplacement != null && !textFits) {
        return overflowReplacement!;
      } else {
        return text;
      }
    });
  }
}
