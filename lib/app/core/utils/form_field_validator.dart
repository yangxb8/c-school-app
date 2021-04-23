/// same function signature as FormTextField's validator;
typedef ValidatorFunction<T> = T Function(T value);

abstract class FieldValidator<T> {
  FieldValidator(this.errorText);

  /// the errorText to display when the validation fails
  final String errorText;

  /// checks the input against the given conditions
  bool isValid(T value);

  /// call is a special function that makes a class callable
  /// returns null if the input is valid otherwise it returns the provided error errorText
  String? call(T value) {
    return isValid(value) ? null : errorText;
  }
}

abstract class TextFieldValidator extends FieldValidator<String> {
  TextFieldValidator(String errorText) : super(errorText);

  @override
  String? call(String value) {
    return (ignoreEmptyValues && value.isEmpty) ? null : super.call(value);
  }

  // return false if you want the validator to return error
  // message when the value is empty.
  bool get ignoreEmptyValues => true;

  /// helper function to check if an input matches a given pattern
  bool hasMatch(String pattern, String input) =>
      RegExp(pattern).hasMatch(input);
}

class RequiredValidator extends TextFieldValidator {
  RequiredValidator({required String errorText}) : super(errorText);

  @override
  bool get ignoreEmptyValues => false;

  @override
  String? call(String? value) {
    return isValid(value) ? null : errorText;
  }

  @override
  bool isValid(String? value) {
    return value != null && value.isNotEmpty;
  }
}

class MaxLengthValidator extends TextFieldValidator {
  MaxLengthValidator(this.max, {required String errorText}) : super(errorText);

  final int max;

  @override
  bool isValid(String value) {
    return value.length <= max;
  }
}

class MinLengthValidator extends TextFieldValidator {
  MinLengthValidator(this.min, {required String errorText}) : super(errorText);

  final int min;

  @override
  bool get ignoreEmptyValues => false;

  @override
  bool isValid(String value) {
    return value.length >= min;
  }
}

class LengthRangeValidator extends TextFieldValidator {
  LengthRangeValidator(
      {required this.min, required this.max, required String errorText})
      : super(errorText);

  final int max;
  final int min;

  @override
  bool get ignoreEmptyValues => false;

  @override
  bool isValid(String value) {
    return value.length >= min && value.length <= max;
  }
}

class RangeValidator extends TextFieldValidator {
  RangeValidator(
      {required this.min, required this.max, required String errorText})
      : super(errorText);

  final num max;
  final num min;

  @override
  bool isValid(String value) {
    try {
      final numericValue = num.parse(value);
      return (numericValue >= min && numericValue <= max);
    } catch (_) {
      return false;
    }
  }
}

class EmailValidator extends TextFieldValidator {
  EmailValidator({required String errorText}) : super(errorText);

  /// regex pattern to validate email inputs.
  final _emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";

  @override
  bool isValid(String value) => hasMatch(_emailPattern, value);
}

class PatternValidator extends TextFieldValidator {
  PatternValidator(this.pattern, {required String errorText})
      : super(errorText);

  final String pattern;

  @override
  bool isValid(String value) => hasMatch(pattern, value);
}

class MultiValidator extends FieldValidator {
  MultiValidator(this.validators) : super(_errorText);

  final List<FieldValidator> validators;

  static String _errorText = '';

  @override
  String? call(dynamic value) {
    return isValid(value) ? null : _errorText;
  }

  @override
  bool isValid(value) {
    for (var validator in validators) {
      if (!validator.isValid(value)) {
        _errorText = validator.errorText;
        return false;
      }
    }
    return true;
  }
}

/// a special match validator to check if the input equals another provided value;
class MatchValidator {
  MatchValidator({required this.errorText});

  final String errorText;

  String? validateMatch(String? value, String? value2) {
    return value == value2 ? null : errorText;
  }
}
