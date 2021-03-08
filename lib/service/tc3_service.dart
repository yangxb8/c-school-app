import 'dart:convert';

import 'package:c_school_app/app/model/soe_request.dart';
import 'package:c_school_app/app/model/speech_evaluation_result.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';

class SoeService extends GetConnect {
  static const action = 'TransmitOralProcessWithInit';
  static const version = '2018-07-24';
  static const SECRET_ID = 'AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP';
  static const SECRET_KEY = 'rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF';
  static const endpoint = 'soe.tencentcloudapi.com';
  static const service = 'soe';

  Future<SentenceInfo> sendSoeRequest(SoeRequest request) async{
    final now = DateTime.now();
    final timestamp = (now.millisecondsSinceEpoch / 1000).floor().toString();
    final payload = request.toString();
    final sign = _generateAuth(payload, now);
    final response = await post('https://$endpoint', payload, headers: {
      'Host': endpoint,
      'X-TC-Action': action,
      'X-TC-RequestClient': GetPlatform.isIOS ? 'cschool_ios' : 'cschool_android',
      'X-TC-Timestamp': timestamp,
      'X-TC-Version': version,
      'X-TC-Language': 'zh-CN',
      'Content-Type': 'application/json',
      'Authorization': sign,
    });
    return SentenceInfo.fromJson(jsonDecode(response.bodyString));
  }

  String _generateAuth(String payload, DateTime now) {
    // 时间处理, 获取世界时间日期
    final timestamp = (now.millisecondsSinceEpoch / 1000).floor().toString();
    // final timestamp = '1615105577';
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    // ************* 步骤 1：拼接规范请求串 *************
    final signedHeaders = 'content-type;host';

    final hashedRequestPayload = sha256.convert(utf8.encode(payload)).toString();
    final httpRequestMethod = 'POST';
    final canonicalUri = '/';
    final canonicalQueryString = '';
    final canonicalHeaders = 'content-type:application/json\n' 'host:' + endpoint + '\n';

    final canonicalRequest = httpRequestMethod +
        '\n' +
        canonicalUri +
        '\n' +
        canonicalQueryString +
        '\n' +
        canonicalHeaders +
        '\n' +
        signedHeaders +
        '\n' +
        hashedRequestPayload;
    // ************* 步骤 2：拼接待签名字符串 *************
    final algorithm = 'TC3-HMAC-SHA256';
    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();
    final credentialScope = date + '/' + service + '/' + 'tc3_request';
    final stringToSign =
        algorithm + '\n' + timestamp + '\n' + credentialScope + '\n' + hashedCanonicalRequest;
    // ************* 步骤 3：计算签名 *************
    final kDate = _hmac256(date, 'TC3' + SECRET_KEY).bytes;
    final kService = _hmac256(service, kDate).bytes;
    final kSigning = _hmac256('tc3_request', kService).bytes;
    final signature = _hmac256(stringToSign, kSigning).toString();
    // ************* 步骤 4：拼接 Authorization *************
    final sign = algorithm +
        ' ' +
        'Credential=' +
        SECRET_ID +
        '/' +
        credentialScope +
        ', ' +
        'SignedHeaders=' +
        signedHeaders +
        ', ' +
        'Signature=' +
        signature;
    return sign;
  }

  Digest _hmac256(String message, dynamic secret) {
    final List<int> key = (secret is String) ? utf8.encode(secret) : secret;
    return Hmac(sha256, key).convert(utf8.encode(message));
  }
}