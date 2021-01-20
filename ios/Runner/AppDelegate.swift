import UIKit
import Flutter
import TAIOralEvaluation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let soeChannel = FlutterMethodChannel(name: "soe", binaryMessenger: controller.binaryMessenger)
    var soeDelegate;
    soeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "soeStartRecord" {
        // Reinit SoeDelegate instance
        soeDelegate = SoeDelegate()
        let args = call.arguments as? Dictionary<String, Any>
        let refText = args["refText"] as? String
        let scoreCoeff = args["scoreCoeff"] as? Double
        let mode = args["mode"] as? String
        let audioPath = args["audioPath"] as? String
        soeDelegate?.soeStartRecord(refText:refText,scoreCoeff:scoreCoeff,mode:mode,audioPath:audioPath,result:result)
      } else if call.method == "soeStopRecordAndEvaluate" {
        soeDelegate?.soeStopRecordAndEvaluate(result:result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class SoeDelegate {
    let oralEvaluation = TAIOralEvaluation()
    var evaluationFinish = false
    
    init() {
        // By setting delegate to self, function like oralEvaluation() can be registered
        oralEvaluation.delegate = self
    }
    
    func stopRecordAndEvaluation(){
        oralEvaluation.stopRecordAndEvaluation(callback:{ (error:TAIError!) in
            if error.code == TAIErrCode_Succ {
                result(nil)
            }
            result(FlutterError(code: error.code,
                                message: error.desc,
                                details: error))
        })
    }
    
    func soeStartRecord(refText:String, scoreCoeff:Double,mode:String,audioPath:String,result:FlutterResult) {
        if oralEvaluation.isRecording() {
            return
        }
        let param:TAIOralEvaluationParam! = TAIOralEvaluationParam()
        param.sessionId = NSUUID.UUID().UUIDString()
        param.appId = "1303827440"
        param.soeAppId = "soe_1001872"
        param.secretId = "AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP"
        param.secretKey = "rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF"
        param.token = PrivateInfo.shareInstance().token
        param.workMode = TAIOralEvaluationWorkMode_Once
        param.evalMode = evalModeFromString(mode:mode)
        param.serverType = TAIOralEvaluationServerType_Chinese
        param.scoreCoeff = scoreCoeff
        param.fileType = TAIOralEvaluationFileType_Mp3
        param.storageMode = TAIOralEvaluationStorageMode_Disable
        param.textMode = TAIOralEvaluationTextMode_Noraml
        param.refText = refText
        param.audioPath = audioPath
        if param.workMode == TAIOralEvaluationWorkMode_Stream {
            param.timeout = 5
            param.retryTimes = 5
        }
        else{
            param.timeout = 30
            param.retryTimes = 0
        }
        let fragSize:CGFloat = _fragSizeTextField.text.floatValue()
        if fragSize == 0 {
            return
        }
        let recordParam:TAIRecorderParam! = TAIRecorderParam()
        recordParam.fragEnable = (param.workMode == TAIOralEvaluationWorkMode_Stream ? true: false)
        recordParam.fragSize = fragSize * 1024
        recordParam.vadEnable = true
        recordParam.vadInterval = _vadTextField.text.intValue()
        oralEvaluation.recorderParam = recordParam
        oralEvaluation.startRecordAndEvaluation(param, callback:{ (error:TAIError!) in
            if error.code == TAIErrCode_Succ {
                result(nil)
            }
            result(FlutterError(code: error.code,
                                message: error.desc,
                                details: error))
        })
    }

    func oralEvaluation(oralEvaluation:TAIOralEvaluation!, onEvaluateData data:TAIOralEvaluationData!, result:TAIOralEvaluationRet!, error:TAIError!) {
        if error.code != TAIErrCode_Succ {
            _recordButton.setTitle("开始录制", forState:UIControlStateNormal)
        }
        let log:String! = String(format:"oralEvaluation:seq:%ld, end:%ld, error:%@, ret:%@", (data.seqId as! long), (data.bEnd as! long), error, result)
        self.response = log
    }

    //TODO
    func onEndOfSpeechInOralEvaluation(oralEvaluation:TAIOralEvaluation!) {
        result(FlutterError(code: error.code,
                            message: error.desc,
                            details: error))
    }

    func evalModeFromString(mode:String) -> TAIOralEvaluationEvalMode {
        switch mode {
        case "WORD":
            return TAIOralEvaluationEvalMode_Word
        case "FREE":
            return TAIOralEvaluationEvalMode_Free
        case "SENTENCE":
            return TAIOralEvaluationEvalMode_Sentence
        case "PARAGRAPH":
            return TAIOralEvaluationEvalMode_Paragraph
        case "WORD_FIX":
            return TAIOralEvaluationEvalMode_Word_Fix
        case "WORD_REALTIME":
            return TAIOralEvaluationEvalMode_Word_RealTime
        case "SCENE":
            return TAIOralEvaluationEvalMode_Scene
        case "MULTI_BRANCH":
            return TAIOralEvaluationEvalMode_Multi_Branch
        default:
            return TAIOralEvaluationEvalMode_Sentence
        }
    }
}
