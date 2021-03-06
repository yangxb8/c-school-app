import 'dart:convert';

import 'package:crypto/crypto.dart';

// 密钥参数
    final SECRET_ID = "AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP";
    final SECRET_KEY = "rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF";

    final endpoint = "soe.tencentcloudapi.com";
    final service = "soe"
    final action = "TransmitOralProcessWithInit"
    final version = "2018-07-24"
    //final timestamp = getTime()
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    //时间处理, 获取世界时间日期
    final date = '${now.year}-${now.month}-${now.day}';

    // ************* 步骤 1：拼接规范请求串 *************
    final signedHeaders = "content-type;host";

    final payload = jsonEncode({
      "SeqId": 1,
      "IsEnd": 1,
      "VoiceFileType": 3,
      "VoiceEncodeType": 1,
      "UserVoiceData": "yugyggyugyu",
      "SessionId": "111",
      "RefText": "你好",
      "WorkMode": 1,
      "EvalMode": 1,
      "ScoreCoeff": 4
    });

    final hashedRequestPayload = sha256.convert(utf8.encode(payload)).toString();
    final httpRequestMethod = "POST";
    final canonicalUri = "/";
    final canonicalQueryString = "";
    final canonicalHeaders = "content-type:application/json; charset=utf-8\n" + "host:" + endpoint + "\n";

    final canonicalRequest = httpRequestMethod + "\n"
                         + canonicalUri + "\n"
                         + canonicalQueryString + "\n"
                         + canonicalHeaders + "\n"
                         + signedHeaders + "\n"
                         + hashedRequestPayload;

    // ************* 步骤 2：拼接待签名字符串 *************
    final algorithm = "TC3-HMAC-SHA256";
    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();
    final credentialScope = date + "/" + service + "/" + "tc3_request";
    final stringToSign = algorithm + "\n" +
                    timestamp.toString() + "\n" +
                    credentialScope + "\n" +
                    hashedCanonicalRequest;

    // ************* 步骤 3：计算签名 *************
    final kDate = Hmac(sha256, utf8.encode('TC3' + SECRET_KEY)).convert(date);
    final kService = sha256(service, kDate)
    final kSigning = sha256('tc3_request', kService)
    final signature = sha256(stringToSign, kSigning, 'hex')
    console.log(signature)
    console.log("----------------------------")

    // ************* 步骤 4：拼接 Authorization *************
    final authorization = algorithm + " " +
                    "Credential=" + SECRET_ID + "/" + credentialScope + ", " +
                    "SignedHeaders=" + signedHeaders + ", " +
                    "Signature=" + signature
    console.log(authorization)
    console.log("----------------------------")