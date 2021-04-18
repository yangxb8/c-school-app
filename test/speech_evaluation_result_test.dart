// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:c_school_app/app/data/model/exam/speech_evaluation_result.dart';

// 🌎 Project imports:

// 🌎 Project imports:

void main() {
  test('Speech evaluation result can be cast', () {
    var exampleJson = '''{
  "Response": {
    "PronAccuracy": 65,
    "PronFluency": 0.99,
    "PronCompletion": 1,
    "SuggestedScore": 65,
    "RequestId": "xxxxxxx",
    "Words": [
      {
        "MemBeginTime": 1,
        "MemEndTime": 2,
        "PronAccuracy": 65,
        "PronFluency": 0.3,
        "Word": "xxx",
        "MatchTag": 1,
        "PhoneInfos": [
          {
            "MemBeginTime": 1,
            "MemEndTime": 2,
            "PronAccuracy": 52,
            "Phone": "b",
            "Stress": true,
            "DetectedStress": false
          }
        ]
      }
    ]
  }
}''';
    var json = jsonDecode(exampleJson);
    var result = SentenceInfo.fromJson(json['Response']);
    print(json);
    expect(result.pronAccuracy, equals(65));
  });
}
