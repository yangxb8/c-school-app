import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let soeChannel = FlutterMethodChannel(name: "soe", binaryMessenger: controller.binaryMessenger)
    let soeDelegate = SoeDelegate()
    soeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "soeStartRecord" {
        let args = call.arguments as? Dictionary<String, Any>
        let refText = args["refText"] as? String
        let scoreCoeff = args["scoreCoeff"] as? Double
        let mode = args["mode"] as? String
        let error = soeDelegate?.soeStartRecord()
      } else if call.method == "soeStopRecordAndEvaluate" {
        let error = soeDelegate?.soeStopRecordAndEvaluate()
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class SoeDelegate : UIViewController {
    @IBAction func onRecord(sender:AnyObject!) {
        if self.oralEvaluation().isRecording() {
            weak var ws:SoeDelegate! = self
            self.oralEvaluation().stopRecordAndEvaluation({ (error:TAIError!) in
                ws.response = String(format:"stopRecordAndEvaluation:%@", error)
                ws.recordButton.setTitle("开始录制", forState:UIControlStateNormal)
            })
            return
        }
        _fileName = String(format:"taisdk_%ld.mp3", (NSDate.date().timeIntervalSince1970() as! long))
        if (_coeffTextField.text == "") {
            self.response = "startRecordAndEvaluation:scoreCoeff invalid"
            return
        }
        self.responseTextView.text = ""
        let param:TAIOralEvaluationParam! = TAIOralEvaluationParam()
        param.sessionId = NSUUID.UUID().UUIDString()
        param.appId = PrivateInfo.shareInstance().appId
        param.soeAppId = PrivateInfo.shareInstance().soeAppId
        param.secretId = PrivateInfo.shareInstance().secretId
        param.secretKey = PrivateInfo.shareInstance().secretKey
        param.token = PrivateInfo.shareInstance().token
        param.workMode = (self.transSegment.selectedSegmentIndex as! TAIOralEvaluationWorkMode)
        param.evalMode = (self.modeSegment.selectedSegmentIndex as! TAIOralEvaluationEvalMode)
        param.serverType = (self.serverType.selectedSegmentIndex as! TAIOralEvaluationServerType)
        param.scoreCoeff = _coeffTextField.text.intValue()
        param.fileType = TAIOralEvaluationFileType_Mp3
        param.storageMode = (self.storageSegment.selectedSegmentIndex as! TAIOralEvaluationStorageMode)
        param.textMode = (self.textModeSegment.selectedSegmentIndex as! TAIOralEvaluationTextMode)
        param.refText = _inputTextField.text
        param.audioPath = String(format:"%@/%@.mp3", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0], param.sessionId)
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
        self.oralEvaluation().recorderParam = recordParam
        weak var ws:SoeDelegate! = self
        self.oralEvaluation().startRecordAndEvaluation(param, callback:{ (error:TAIError!) in
            if error.code == TAIErrCode_Succ {
                ws.recordButton.setTitle("停止录制", forState:UIControlStateNormal)
            }
            ws.response = String(format:"startRecordAndEvaluation:%@", error)
        })
    }

    func oralEvaluation(oralEvaluation:TAIOralEvaluation!, onEvaluateData data:TAIOralEvaluationData!, result:TAIOralEvaluationRet!, error:TAIError!) {
        if error.code != TAIErrCode_Succ {
            _recordButton.setTitle("开始录制", forState:UIControlStateNormal)
        }
        let log:String! = String(format:"oralEvaluation:seq:%ld, end:%ld, error:%@, ret:%@", (data.seqId as! long), (data.bEnd as! long), error, result)
        self.response = log
    }

    func onEndOfSpeechInOralEvaluation(oralEvaluation:TAIOralEvaluation!) {
        self.response = "onEndOfSpeech"
        self.onRecord(nil)
    }

    func oralEvaluation(oralEvaluation:TAIOralEvaluation!, onVolumeChanged volume:Int) {
        self.progressView.progress = volume / 120.0
    }

    func oralEvaluation() -> TAIOralEvaluation! {
        if !_oralEvaluation {
            _oralEvaluation = TAIOralEvaluation()
            _oralEvaluation.delegate = self
        }
        return _oralEvaluation
    }
}
