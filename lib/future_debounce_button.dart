library future_debounce_button;

// FutureDebounceButton widget
export 'fdb_widget.dart';

/// Defines the type of the [FutureDebounceButton] widget
enum FDBType { elevated, filled, filledTonal, outlined, text }

/// Defines the state of the [FutureDebounceButton] widget
enum FDBState { disabled, ready, running, abort, success, error }
