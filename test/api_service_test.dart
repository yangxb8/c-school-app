import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_school_app/model/user.dart';
import 'package:c_school_app/util/extensions.dart';

void main(){
  //TODO: This test isn't implemented
  test('save user data to firestore',(){
    var userCollectionTest = {
      'nickname': 'test',
      'membershipType': [EnumToString.convertToString(MembershipType.FREE)],
      'membershipEndAt': Timestamp.now(),
      'rankHistory': [
        {'date': Timestamp.now(), 'rank': 1}
      ],
      'progress': {
        'learnedLectures': {
          '1': {
            'studyTime': '',
            'testScore': [1, 2, 3],
            'speechRef': ['speechID1', 'speechID2']
          }
        },
        'history': {
          DateTime.now().yyyyMMdd(): {
            'sessions': [
              {'start': Timestamp.now(), 'end': Timestamp.now()}
            ]
          }
        }
      },
      'userGeneratedData': {
        'savedLecturesID': [1, 2, 3],
        'memo': [{'created':Timestamp.now(),'lectureId':1,'slideId':1,'content':'this is some test memo'}]
      }
    };
  });
}