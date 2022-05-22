import 'dart:async';

import 'package:flutter/material.dart';

class Observable<T> {
  T _value;
  late final StreamController<T> _controller = StreamController.broadcast();

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
            if (snap.hasData) {
              return builder(snap.data as T);
            }
            return loadWidget ?? Container();
          default:
            return loadWidget ?? Container();
        }
      },
    );
  }

  void notify() {
    _controller.add(_value);
  }
}
