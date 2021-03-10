import 'dart:async';
import 'dart:math';
import 'package:sensors/sensors.dart';

/// Callback for phone shakes
typedef PhoneShakeCallback = void Function();

/// ShakeDetector class for phone shake functionality
class ShakeDetector {
  /// User callback for phone shake
  final PhoneShakeCallback onPhoneShake;

  /// Shake detection threshold
  final double shakeThresholdGravity;

  /// Minimum time between shake
  final int shakeSlopTimeMS;

  /// Time before shake count resets
  final int shakeCountResetTime;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;

  /// StreamSubscription for Accelerometer events
  StreamSubscription streamSubscription;

  /// This constructor automatically calls [startListening] and starts detection and callbacks.\
  ShakeDetector.autoStart(
      {this.onPhoneShake,
        this.shakeThresholdGravity = 2.7,
        this.shakeSlopTimeMS = 500,
        this.shakeCountResetTime = 3000}) {
    startListening();
  }

  /// Starts listening to accerelometer events
  void startListening() {
    streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      var x = event.x;
      var y = event.y;
      var z = event.z;

      var gX = x / 9.80665;
      var gY = y / 9.80665;
      var gZ = z / 9.80665;

      // gForce will be close to 1 when there is no movement.
      var gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThresholdGravity) {
        var now = DateTime.now().millisecondsSinceEpoch;
        // ignore shake events too close to each other (500ms)
        if (mShakeTimestamp + shakeSlopTimeMS > now) {
          return;
        }

        // reset the shake count after 3 seconds of no shakes
        if (mShakeTimestamp + shakeCountResetTime < now) {
          mShakeCount = 0;
        }

        mShakeTimestamp = now;
        mShakeCount++;

        onPhoneShake();
      }
    });
  }

  /// Stops listening to accelerometer events
  void stopListening() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }
  }
}
