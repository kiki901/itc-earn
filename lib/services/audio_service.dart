import 'package:flutter/services.dart';

class AudioService {
  static bool _enabled = true;

  static void setEnabled(bool value) => _enabled = value;

  static void _vibrate([int duration = 50]) {
    if (_enabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static void _lightVibrate() {
    if (_enabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void _heavyVibrate() {
    if (_enabled) {
      HapticFeedback.heavyImpact();
    }
  }

  static void playGiftBoxOpen() {
    _heavyVibrate();
  }

  static void playCoinCollect() {
    _lightVibrate();
  }

  static void playTaskComplete() {
    _vibrate(100);
  }

  static void playLevelUp() {
    _heavyVibrate();
  }

  static void playPurchase() {
    _vibrate(80);
  }

  static void playSuccess() {
    _vibrate(60);
  }

  static void playWheelSpin() {
    _lightVibrate();
  }

  static void playWheelStop() {
    _heavyVibrate();
  }

  static void playButtonTap() {
    _lightVibrate();
  }

  static void playError() {
    if (_enabled) {
      HapticFeedback.vibrate();
    }
  }
}
