import 'package:flamingo/flamingo.dart';

/// Controller that can commit its track to firestore
abstract class TrackableController{
  /// Commit track to firestore
  void updateTrack();
  /// Get track from firestore, usually by calling 
  /// UserService.user.getControllerTrack<T extends ControllerTrackInterface>()
  ControllerTrack get controllerTrack;
}

/// State for the controller, extends this.
class ControllerTrack extends Model{
  // The constructor is here only for flamingo to recognize it
  ControllerTrack({
  Map<String, dynamic> values,
  }) : super(values: values);
}