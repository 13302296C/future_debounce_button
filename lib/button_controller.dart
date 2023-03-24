import 'dart:async';
import 'package:flutter/material.dart';
import 'package:future_debounce_button/future_debounce_button.dart';

/// The controller class for the [FutureDebounceX] widget.
class ButtonController<T> {
  /// The reference to the controlled object
  State obj;

  /// The reference to the controlled future
  Future<void>? future;

  final StreamController<FDBState> _state;

  late final Stream<FDBState> state;

  late final StreamSink<FDBState> _stateSink;

  set newState(FDBState value) => _stateSink.add(value);

  FDBState _currentState = FDBState.disabled;

  final void Function(FDBState)? onStateChange;
  late final StreamSubscription _onStateChangeSubscription;

  /// The flag indicating that the button can be pressed to cancel the future.
  bool abortCanBePressed = false;

  /// The flag indicating that the button can be pressed to cancel the future.
  bool get canAbort => abortCanBePressed && onAbort != null;

  // widget arguments
  bool enabled;
  final Future<T> Function() onPressed;
  final void Function(T value)? onSuccess;
  final Function(dynamic error, dynamic stackTrace)? onError;
  final Function()? onAbort;
  final Duration? abortStateDuration;
  final Duration? errorStateDuration;
  final Duration? successStateDuration;
  final Duration debounceDuration;
  final Duration? timeout;

  ButtonController(
      {FDBState initialState = FDBState.disabled,
      this.enabled = false,
      this.onStateChange,
      required this.onPressed,
      this.onSuccess,
      this.onError,
      this.onAbort,
      this.abortStateDuration,
      this.errorStateDuration,
      this.successStateDuration,
      required this.debounceDuration,
      this.timeout,
      required this.obj})
      : _state = StreamController<FDBState>() {
    state = _state.stream.asBroadcastStream();
    _stateSink = _state.sink;
    newState = initialState;

    _onStateChangeSubscription = state.listen((FDBState state) {
      _currentState = state;
      _processStateChange(state);
      if (onStateChange != null) {
        onStateChange!(state);
      }
    });
  }

  bool get isAbortable => onAbort != null;

  void Function()? get onActionPressed => !enabled ||
          _currentState == FDBState.disabled ||
          _currentState == FDBState.running && !abortCanBePressed && isAbortable
      ? null
      : () async {
          if (debounceDuration != Duration.zero) {
            abortCanBePressed = false;
          } else {
            abortCanBePressed = true;
          }
          newState = FDBState.running;
          future = onPressed().then((T value) {
            if (_currentState == FDBState.running) {
              newState = FDBState.success;
              onSuccess?.call(value);
            }
          }).onError((error, stackTrace) {
            newState = FDBState.error;
            onError?.call(error, stackTrace);
          });

          if (timeout != null) {
            future?.timeout(timeout!, onTimeout: () {
              newState = FDBState.error;

              onError?.call(
                  TimeoutException('Request timed out', timeout), null);
            });
          }
          if (debounceDuration != Duration.zero) {
            Future.delayed(debounceDuration).then((value) {
              abortCanBePressed = true;
              // ignore: invalid_use_of_protected_member
              if (obj.mounted) obj.setState(() {});
            });
          }
        };

  void Function()? get onAbortPressed => abortCanBePressed
      ? () {
          newState = FDBState.abort;
          onAbort?.call();
        }
      : null;

  /// Processes the state change
  void _processStateChange(FDBState state) {
    switch (state) {
      case FDBState.disabled:
        break;
      case FDBState.ready:
        break;
      case FDBState.running:
        break;
      case FDBState.abort:
        if (abortStateDuration == null) {
          // show forever
        } else if (abortStateDuration != Duration.zero) {
          // show for a duration
          Future.delayed(abortStateDuration!).then((value) {
            _reset();
          });
        } else {
          // do not show
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reset();
          });
        }
        break;
      case FDBState.success:
        // if the success state duration is not zero -
        // Schedule a reset of the button state after the
        // success state `duration` delay.
        if (successStateDuration == null) {
          // show forever
        } else if (successStateDuration! != Duration.zero) {
          // show for a duration
          Future.delayed(successStateDuration!).then((_) {
            _reset();
          });
        } else {
          // do not show
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reset();
          });
        }
        break;
      case FDBState.error:
        // if the error state duration is not zero -
        // Schedule a reset of the button state after the
        // error state `duration` delay.
        if (errorStateDuration == null) {
          // show forever
        } else if (errorStateDuration != Duration.zero) {
          // show for a duration
          Future.delayed(errorStateDuration!).then((value) {
            _reset();
          });
        } else {
          // do not show
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reset();
          });
        }
        break;
    }
  }

  /// Resets the button state.
  void _reset() {
    future?.ignore();
    future = null;
    abortCanBePressed = false;
    if (enabled) {
      newState = FDBState.ready;
    } else {
      newState = FDBState.disabled;
    }
  }

  /// Disposes the controller
  void dispose() {
    _onStateChangeSubscription.cancel();
  }
}
