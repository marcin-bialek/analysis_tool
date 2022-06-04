import 'dart:async';

import 'package:flutter/material.dart';

class Observable<T> {
  T _value;
  late final StreamController<T> _controller = StreamController.broadcast();
  final _listeners = <void Function(T value)>{};

  T get value => _value;
  Stream<T> get stream => _controller.stream;

  set value(T value) {
    _value = value;
    notify();
  }

  Observable(T value) : _value = value;

  Widget observe(Widget Function(T value) builder, {Widget? loadWidget}) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: _value,
      builder: (_, snap) {
        switch (snap.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            return builder(snap.data as T);
          default:
            return loadWidget ?? Container();
        }
      },
    );
  }

  void notify() {
    _controller.add(_value);
    for (final callback in _listeners) {
      callback(_value);
    }
  }

  void addListener(void Function(T value) callback) {
    _listeners.add(callback);
  }

  void removeListener(void Function(T value) callback) {
    _listeners.remove(callback);
  }
}
