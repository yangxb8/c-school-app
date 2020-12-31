/// Controller that can commit its track to firestore
abstract class TrackableController{
  /// Commit track to firestore
  void updateTrack();
  /// Get track from firestore, usually by calling 
  /// UserService.user.getControllerTrack<T extends ControllerTrackInterface>()
  ControllerTrackInterface get controllerTrack;
}

/// State for the controller, extends Document<YourState>
abstract class ControllerTrackInterface{}