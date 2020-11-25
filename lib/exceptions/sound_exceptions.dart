class NoVoiceDataException implements Exception{

}

class RecordingPermissionException implements Exception{
  RecordingPermissionException();
  
}

class NotSetupException implements Exception {
  String message;
  NotSetupException(this.message);
}