import UIKit
import Flutter
import TAISDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let soeChannel = FlutterMethodChannel(name: "soe", binaryMessenger: controller.binaryMessenger)
    var soeDelegate:SoeDelegate = SoeDelegate();
    soeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "soeStartRecord" {
        // Reinit SoeDelegate instance
        soeDelegate = SoeDelegate()
        let args = call.arguments as! Dictionary<String, Any>
        let refText = args["refText"] as! String
        let scoreCoeff = args["scoreCoeff"] as! Double
        let mode = args["mode"] as! String
        let audioPath = args["audioPath"] as! String
        soeDelegate.soeStartRecord(refText:refText,scoreCoeff:scoreCoeff,mode:mode,audioPath:audioPath,result:result)
      } else if call.method == "soeStopRecordAndEvaluate" {
        soeDelegate.soeStopRecordAndEvaluate(result:result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class SoeDelegate: NSObject,TAIOralEvaluationDelegate {
    let oralEvaluation = TAIOralEvaluation()
    let POLLING_INTERVAL = 0.2
    let NO_SPEECH_DETECT_INTERVAL = 5000
    var evaluationResultJson: String
    var flutterResult: FlutterResult
    var errorDetected: false

    override init() {
        // By setting delegate to self, function like oralEvaluation() can be registered
        super.init()
        oralEvaluation.delegate = self
    }

    func soeStopRecordAndEvaluate(result:@escaping FlutterResult){
        oralEvaluation.stopRecordAndEvaluation({ (error:TAIError!) in
            if error.code == TAIErrCode.succ {
                flutterResult = result
                // Polling evaluationResultJson until its set by oralEvaluation()
                Timer.scheduledTimer(withTimeInterval: POLLING_INTERVAL, repeats: true) { timer in
                    // Error or succeed
                    if errorDetected || evaluationResultJson != nil{
                        // Callback will report to flutter so here we just stop the timer
                        timer.invalidate()
                    }
                }
            }
            result(FlutterError(code: String(error.code.rawValue),
                                message: error.desc,
                                details: error))
        })
    }

    func soeStartRecord(refText:String, scoreCoeff:Double,mode:String,audioPath:String,result:@escaping FlutterResult) {
        if oralEvaluation.isRecording() {
            return
        }
        let param:TAIOralEvaluationParam! = TAIOralEvaluationParam()
        param.sessionId = NSUUID.init().uuidString
        param.appId = "1303827440"
        param.soeAppId = "soe_1001872"
        param.secretId = "AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP"
        param.secretKey = "rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF"
        param.workMode = TAIOralEvaluationWorkMode.once
        param.evalMode = evalModeFromString(mode:mode)
        param.serverType = TAIOralEvaluationServerType.chinese
        param.scoreCoeff = Float(scoreCoeff)
        param.fileType = TAIOralEvaluationFileType.mp3
        param.storageMode = TAIOralEvaluationStorageMode.disable
        param.textMode = TAIOralEvaluationTextMode.noraml
        param.refText = refText
        param.audioPath = audioPath
        if param.workMode == TAIOralEvaluationWorkMode.stream {
            param.timeout = 5
            param.retryTimes = 5
        }
        else{
            param.timeout = 30
            param.retryTimes = 0
        }
        let recordParam:TAIRecorderParam! = TAIRecorderParam()
        recordParam.fragEnable = false
        recordParam.vadEnable = true
        recordParam.vadInterval = NO_SPEECH_DETECT_INTERVAL
        oralEvaluation.setRecorderParam(recordParam)
        oralEvaluation.startRecordAndEvaluation(param, callback:{ (error:TAIError!) in
            if error.code == TAIErrCode.succ {
                result(nil)
            }
            result(FlutterError(code: String(error.code.rawValue),
                                message: error.desc,
                                details: error))
        })
    }

    func oralEvaluation(_ oralEvaluation:TAIOralEvaluation!, onEvaluateData
                            :TAIOralEvaluationData!, result:TAIOralEvaluationRet!, error:TAIError!) {
        if error.code != TAIErrCode.succ {
            errorDetected = true
            flutterResult(FlutterError(code: nil,
                                message: "Evaluation Failed",
                                details: nil))
        }
        flutterResult(result.description())
    }

    // When end of speech is detected
    func onEndOfSpeech(in oralEvaluation: TAIOralEvaluation!) {
        errorDetected = true
        flutterResult(FlutterError(code: nil,
                                message: "End of Speech detected",
                                details: nil))
    }

    // When volumn changed
    func oralEvaluation(_ oralEvaluation: TAIOralEvaluation!, onVolumeChanged volume: Int) {
        // do nothing
        return
    }

    func evalModeFromString(mode:String) -> TAIOralEvaluationEvalMode {
        switch mode {
        case "WORD":
            return TAIOralEvaluationEvalMode.word
        case "FREE":
            return TAIOralEvaluationEvalMode.free
        case "SENTENCE":
            return TAIOralEvaluationEvalMode.sentence
        case "PARAGRAPH":
            return TAIOralEvaluationEvalMode.paragraph
        case "WORD_FIX":
            return TAIOralEvaluationEvalMode.word_Fix
        case "WORD_REALTIME":
            return TAIOralEvaluationEvalMode.word_RealTime
        case "SCENE":
            return TAIOralEvaluationEvalMode.scene
        case "MULTI_BRANCH":
            return TAIOralEvaluationEvalMode.multi_Branch
        default:
            return TAIOralEvaluationEvalMode.sentence
        }
    }
}
