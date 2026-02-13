import 'package:flutter/widgets.dart';

mixin FormFieldErrorStateMixin<T> on FormFieldState<T> {
  bool _isErrorHidden = false;

  @override
  bool validate() {
    setState(() {
      _isErrorHidden = false;
    });
    return super.validate();
  }

  void hideError() {
    if (hasError && !_isErrorHidden) {
      setState(() {
        _isErrorHidden = true;
      });
    }
  }

  bool get isErrorVisible => !_isErrorHidden;
}
