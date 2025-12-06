// Stub file for non-web platforms (VM, tests, etc.)
// Provides fake implementations of dart:html and dart:js APIs

// Stub for js.context
dynamic get context => _StubContext();

class _StubContext {
  dynamic operator [](String key) => null;
}

// Stub for html.window
final window = _StubWindow();

class _StubWindow {
  final console = _StubConsole();
}

class _StubConsole {
  void log(Object? message) {
    // No-op for non-web platforms
  }
}
