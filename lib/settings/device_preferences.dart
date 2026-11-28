import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingSize {
  system(0),
  large(1.2),
  extraLarge(1.4);

  const ReadingSize(this.minimumScale);
  final double minimumScale;
}

enum HomeDrawMarket { ny, fl }

class DevicePreferences extends ChangeNotifier {
  static const _marketKey = 'settings.homeDrawMarket';
  static const _sizeKey = 'settings.readingSize';
  static const _motionKey = 'settings.reduceMotion';

  late SharedPreferences _storage;
  HomeDrawMarket _market = HomeDrawMarket.ny;
  ReadingSize _size = ReadingSize.system;
  bool _reduceMotion = false;

  HomeDrawMarket get market => _market;
  ReadingSize get size => _size;
  bool get reduceMotion => _reduceMotion;

  void restore(SharedPreferences storage) {
    _storage = storage;
    _market = HomeDrawMarket.values.asNameMap()[storage.get(_marketKey)] ??
        HomeDrawMarket.ny;
    _size = ReadingSize.values.asNameMap()[storage.get(_sizeKey)] ??
        ReadingSize.system;
    _reduceMotion = storage.get(_motionKey) == true;
  }

  Future<void> setMarket(HomeDrawMarket value) async {
    if (!await _storage.setString(_marketKey, value.name)) {
      throw StateError(_marketKey);
    }
    _market = value;
    notifyListeners();
  }

  Future<void> setSize(ReadingSize value) async {
    if (!await _storage.setString(_sizeKey, value.name)) {
      throw StateError(_sizeKey);
    }
    _size = value;
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    if (!await _storage.setBool(_motionKey, value)) {
      throw StateError(_motionKey);
    }
    _reduceMotion = value;
    notifyListeners();
  }

  MediaQueryData applyTo(MediaQueryData system) => system.copyWith(
        textScaler: size == ReadingSize.system
            ? system.textScaler
            : _ReadingTextScaler(system.textScaler, size.minimumScale),
        disableAnimations: system.disableAnimations || reduceMotion,
      );
}

// Preserve the system's nonlinear scaling while letting widgets such as the
// AppBar apply their own scaling limits to the final result.
class _ReadingTextScaler extends TextScaler {
  const _ReadingTextScaler(this.system, this.minimum);
  final TextScaler system;
  final double minimum;

  @override
  double scale(double fontSize) =>
      math.max(system.scale(fontSize), fontSize * minimum);

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _ReadingTextScaler &&
      other.system == system &&
      other.minimum == minimum;

  @override
  int get hashCode => Object.hash(system, minimum);
}
