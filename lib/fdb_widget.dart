import 'dart:async';
import 'package:flutter/material.dart';
import 'package:future_debounce_button/button_controller.dart';
import 'package:future_debounce_button/future_debounce_button.dart';

/// # Future Debounce Button
/// A button widget that handles asyncronous calls (REST requests etc)
/// and changes its states based on the state of the future it's given.
///
///  ```dart
/// FutureDebounceButton(
///   onPressed: ... // required, the Future function to be called
///   onSuccess: ... // optional, what to do when the future is completed
///   onAbort: ... // optional, what to do when the user aborts the future
///   onError: ... // optional, what to do when the future is completed with an error
/// );
/// ```
///
/// The `onSuccess` function is called when the `onPressed` future is completed
/// with a value. The `onError` function is called when the `onPressed`
/// future is completed with an error.
///
/// If the `onAbort` function is provided, the button becomes "abortable"
/// (the future could be abandoned and possible result is dropped
/// instead of being fed to `onSuccess` handler).
///
/// The Future can be aborted by pressing the button again before the
/// `onPressed` future is completed.
///
/// In this case, the `abortChild` or `abortText` is displayed while the
/// future is running. The `onAbort` function is called when the user
/// decides to abort the `onPressed` future.
///
/// To prevent accidental cancellation of a future, the button is debounced
/// for a period of time specified by `debounceDuration` before it can be
/// pressed again. This is only useful if the `onAbort` is employed.
///
/// The `timeout` parameter is used to specify the maximum duration the
/// `onPressed` future can run before it is considered to have failed.
/// If the `timeout` is not provided, the `onPressed` future will run
/// indefinitely.
class FutureDebounceButton<T> extends StatefulWidget {
  /// dictates is the button is enabled or disabled
  final bool enabled;

  /// The `Future` function to be called when the button is pressed.
  /// This future will be debounced.
  final Future<T> Function() onPressed;

  /// The `Function` to be called when the `onPressed` future
  /// is completed with a value.
  final void Function(T value)? onSuccess;

  /// The `Function` to be called when the `onPressed` future
  /// is completed with an error.
  final Function(dynamic error, dynamic stackTrace)? onError;

  /// What to do if the user decides to abort the `onPressed` future.
  final Function()? onAbort;

  /// The type of button to be displayed. Defaults to `FDBType.elevated`
  ///
  /// <img src="https://github.com/13302296C/future_debounce_button/raw/master/media/buttons.png" alt="Button types" width="500"/>
  final FDBType buttonType;

  /// When isAbortable is `true`, the button will activate abort action
  /// when pressed again before the `onPressed` future is completed.
  bool get isAbortable => onAbort != null;

  /// Triggers every time the button changes state.
  ///
  /// The possible emitted values are:
  /// - `FDBState.disabled` - the button is disabled
  /// - `FDBState.ready` - the button is ready to be pressed
  /// - `FDBState.running` - the button is pressed and the `onPressed` future is running
  /// - `FDBState.abort` - the button is pressed and the `onPressed` future is running
  /// - `FDBState.success` - the `onPressed` future has completed with a value
  /// - `FDBState.error` - the `onPressed` future has completed with an error
  final void Function(FDBState)? onStateChange;

  /// The widget to be displayed before the `onPressed` future has started.
  final Widget? actionCallChild;

  /// Button text displayed before the `onPressed` future has started.
  /// Defaults to 'Go'. This labes is only used if `child` is not provided.
  final String? actionCallText;

  /// The style to be used for the button before the `onPressed` future has started.
  final ButtonStyle? actionCallButtonStyle;

  /// The widget to be displayed while the `onPressed` future is running and
  /// user can not abort the call.
  final Widget? loadingChild;

  /// Button text displayed while the `onPressed` future is running and user
  /// can not abort the call. Defaults to ''. This label is only used
  /// if `loadingChild` is not provided.
  final String? loadingText;

  /// The style to be used for the button while the `onPressed` future is running
  /// and user can not abort the call.
  final ButtonStyle? loadingButtonStyle;

  /// The widget to be displayed while the `onPressed` future is running
  /// and user can abort the call.
  final Widget? abortChild;

  /// The widget to be displayed when the abort action is triggered.
  final Widget? abortPressedChild;

  /// Button text displayed while the `onPressed` future is running and user
  /// can abort the call. Defaults to 'Abort'. This label is only used if
  /// `abortChild` is not provided.
  final String? abortText;

  /// Button text displayed when the abort action is triggered.
  /// Defaults to 'Cancelled'. This label is only used if
  /// `abortPressedChild` is not provided.
  final String? abortPressedText;

  /// The style to be used for the button while the `onPressed` future is running
  /// and user can abort the call.
  final ButtonStyle? abortButtonStyle;

  /// The duration of the abort state. Defaults to 1 second.
  final Duration? abortStateDuration;

  /// The widget to display when the `onPressed` future has failed.
  final Widget? errorChild;

  /// Button text displayed when the `onPressed` future has failed.
  final String? errorText;

  /// The style of the button in error state.
  final ButtonStyle? errorButtonStyle;

  /// The duration of the error state. Defaults to 1 second.
  /// If the duration is set to `null`, the error state will be displayed
  /// forever. If the duration is set to `Duration.zero`, the error state
  /// will be displayed for one frame.
  final Duration? errorStateDuration;

  /// The widget to display when the `onPressed` future has failed.
  final Widget? successChild;

  /// Button text displayed when the `onPressed` future has succeeded.
  final String? successText;

  /// The style of the button in success state.
  final ButtonStyle? successButtonStyle;

  /// The duration of the success state. Defaults to 1 second.
  /// If the duration is set to `null`, the success state will be displayed
  /// forever. If the duration is set to `Duration.zero`, the success state
  /// will be displayed for one frame.
  final Duration? successStateDuration;

  /// The duration of the debounce before the button could be pressed again.
  /// This helps prevent accidental double-taps that cancel the request
  /// right after it fired. This is only useful if the `onAbort`
  /// is employed. You can also use this to defer the user from being able
  /// to abort the call for `x` amount of time. Defaults to 250 milliseconds.
  final Duration debounceDuration;

  /// Future timeout. If the `timeout` is provided, the `onPressed` future
  /// will be cancelled after the `timeout` duration.
  /// The `onError` function will be called with a `TimeoutException`.
  /// Defaults to `null` (no timeout).
  final Duration? timeout;

  const FutureDebounceButton({
    Key? key,
    this.enabled = true,
    required this.onPressed,
    this.onSuccess,
    this.onError,
    this.onAbort,
    this.onStateChange,
    this.buttonType = FDBType.filled,
    this.actionCallText = 'Go',
    this.actionCallChild,
    this.actionCallButtonStyle,
    this.loadingText,
    this.loadingChild,
    this.loadingButtonStyle,
    this.abortText = 'Abort',
    this.abortPressedText = 'Cancelled',
    this.abortChild,
    this.abortPressedChild,
    this.abortButtonStyle,
    this.abortStateDuration = const Duration(seconds: 1),
    this.errorText = 'Error',
    this.errorChild,
    this.errorButtonStyle,
    this.errorStateDuration = const Duration(seconds: 1),
    this.successText = 'Success!',
    this.successChild,
    this.successButtonStyle,
    this.successStateDuration = const Duration(seconds: 1),
    this.debounceDuration = const Duration(milliseconds: 250),
    this.timeout,
  })  : assert(onPressed is! Future),
        super(key: key);

  @override
  State<FutureDebounceButton<T>> createState() => _FutureDebounceButtonState();

  /// Returns the default error button style for the given [FDBType].
  static ButtonStyle defaultErrorButtonStyle(FDBType buttonType) {
    switch (buttonType) {
      case FDBType.elevated:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.filled:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.filledTonal:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.outlined:
        return ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.red[300]),
          side: MaterialStateProperty.all(
            BorderSide(color: Colors.red[300]!),
          ),
        );
      case FDBType.text:
        return ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.red[300]),
        );
    }
  }

  /// Returns the default success button style for the given [FDBType].
  static ButtonStyle defaultSuccessButtonStyle(FDBType buttonType) {
    switch (buttonType) {
      case FDBType.elevated:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.filled:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.filledTonal:
        return ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        );
      case FDBType.outlined:
        return ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.green[300]),
          side: MaterialStateProperty.all(
            BorderSide(color: Colors.green[300]!),
          ),
        );
      case FDBType.text:
        return ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.green[300]),
        );
    }
  }
}

class _FutureDebounceButtonState<T> extends State<FutureDebounceButton<T>>
    with TickerProviderStateMixin {
  /// Animation controller for the circular progress indicator.
  late AnimationController animationController;

  late ButtonController _c;

  @override
  void dispose() {
    _c.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _c = ButtonController<T>(
      initialState: widget.enabled ? FDBState.ready : FDBState.disabled,
      enabled: widget.enabled,
      onStateChange: widget.onStateChange,
      onPressed: widget.onPressed,
      onSuccess: widget.onSuccess,
      onError: widget.onError,
      onAbort: widget.onAbort,
      abortStateDuration: widget.abortStateDuration,
      errorStateDuration: widget.errorStateDuration,
      successStateDuration: widget.successStateDuration,
      debounceDuration: widget.debounceDuration,
      timeout: widget.timeout,
      obj: this,
    );

    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  FDBState _state = FDBState.disabled;

  @override
  Widget build(BuildContext context) {
    _state = FDBState.disabled;
    _c.enabled = widget.enabled;
    return StreamBuilder(
        stream: _c.state,
        builder: (context, AsyncSnapshot<FDBState> state) {
          _state = FDBState.disabled;
          if (state.hasData && state.data != null) {
            _state = state.data!;
          } else {
            _state = FDBState.disabled;
          }
          switch (_state) {
            case FDBState.disabled:
            case FDBState.ready:
              return _buildActionButton();
            case FDBState.running:
              if (_c.canAbort) {
                // Display the abort button.
                return _buildAbortButton();
              } else if (!_c.abortCanBePressed) {
                //disabled action button
                return _buildActionButton();
              } else {
                // Display the loading button.
                return _buildLoadingButton();
              }
            case FDBState.success:
              return _buildSuccessButton();
            case FDBState.error:

              // Display the error button.
              return _buildErrorButton();
            case FDBState.abort:
              return _buildAbortPressedButton();
          }
        });
  }

  /// Builds the action button.
  Widget _buildActionButton() {
    return _buildButton(
      onPressed: _c.onActionPressed,
      child: widget.actionCallChild ?? Text(widget.actionCallText!),
    );
  }

  /// Builds a [CircularProgressIndicator] with [valueColor] animation.
  Widget _cpi() => SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        valueColor: animationController
            .drive(ColorTween(begin: Colors.cyan, end: Colors.yellow)),
        strokeWidth: 2,
      ));

  /// Builds the loading button.
  Widget _buildLoadingButton() {
    return _buildButton(
      onPressed: () {},
      child: widget.loadingChild ??
          (widget.loadingText != null ? Text(widget.loadingText!) : _cpi()),
    );
  }

  /// Builds the abort button.
  Widget _buildAbortButton() {
    return _buildButton(
      onPressed: _c.onAbortPressed,
      child: widget.abortChild ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cpi(),
              const SizedBox(width: 5),
              Text(widget.abortText!),
            ],
          ),
    );
  }

  /// Builds the abort button.
  Widget _buildAbortPressedButton() {
    return _buildButton(
      onPressed: () {},
      child: widget.abortPressedChild ?? Text(widget.abortPressedText!),
    );
  }

  /// Builds the error button.
  Widget _buildErrorButton() {
    return _buildButton(
      onPressed: () {},
      child: widget.errorChild ?? Text(widget.errorText!),
    );
  }

  /// Builds the success button
  Widget _buildSuccessButton() {
    return _buildButton(
      onPressed: () {},
      child: widget.successChild ?? Text(widget.successText!),
    );
  }

  /// Returns the button style based on the current state.
  ButtonStyle? get _buttonStyle {
    switch (_state) {
      case FDBState.disabled:
      case FDBState.ready:
        return widget.actionCallButtonStyle;
      case FDBState.running:
        if (widget.isAbortable && _c.abortCanBePressed) {
          return widget.abortButtonStyle;
        } else {
          return widget.loadingButtonStyle;
        }
      case FDBState.success:
        return widget.successButtonStyle ??
            FutureDebounceButton.defaultSuccessButtonStyle(widget.buttonType);
      case FDBState.error:
        return widget.errorButtonStyle ??
            FutureDebounceButton.defaultErrorButtonStyle(widget.buttonType);
      case FDBState.abort:
        return widget.abortButtonStyle;
    }
  }

  /// Builds a button based on the [FDBType].
  Widget _buildButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    switch (widget.buttonType) {
      case FDBType.elevated:
        return ElevatedButton(
          onPressed: onPressed,
          style: _buttonStyle,
          child: child,
        );
      case FDBType.filled:
        return FilledButton(
          onPressed: onPressed,
          style: _buttonStyle,
          child: child,
        );
      case FDBType.filledTonal:
        return FilledButton.tonal(
          onPressed: onPressed,
          style: _buttonStyle,
          child: child,
        );
      case FDBType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: _buttonStyle,
          child: child,
        );
      case FDBType.text:
        return TextButton(
          onPressed: onPressed,
          style: _buttonStyle,
          child: child,
        );
    }
  }
}
