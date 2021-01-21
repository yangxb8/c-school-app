package site.alphasho.c_school_app

import android.content.Context
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.tencent.taisdk.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import java.util.*


class MainActivity: FlutterActivity() {
    // Smart Oral evaluation
    private val SOE_CHANNEL = "soe"
    // Natural Language Processing
    private val NLP_CHANNEL = "nlp"
    private val soeActivity = SoeActivity()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOE_CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "soeStartRecord" -> {
                    val refText = call.argument<String>("refText")?:""
                    val scoreCoeff = call.argument<Double>("scoreCoeff")?:""
                    val mode = call.argument<String>("mode")?:""
                    val audioPath = call.argument<String>("audioPath")?:""
                    val error = soeActivity.soeStartRecord(refText, scoreCoeff as Double, mode, audioPath, applicationContext)
                    if(error == null) result.success(null)
                    else result.error("SOE-START", "Soe start record error", error)
                }
                "soeStopRecordAndEvaluate" -> {
                    val dataAndEvaluationResult = runBlocking { soeActivity.soeStopRecordAndEvaluate() }
                    if (dataAndEvaluationResult != null) {
                        if(dataAndEvaluationResult.contains("error")){
                            val error = dataAndEvaluationResult["error"]
                            result.error("SOE-STOP","Soe stop and evaluation error", error)
                        } else result.success(dataAndEvaluationResult)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

}

class SoeActivity {
    private var oral: TAIOralEvaluation? = null
    private var lastErrorCode: Int? = null
    private var lastResult: Map<String, Any?>? = null
    private val POLLING_INTERVAL = 200L
    private val NO_SPEECH_DETECT_INTERVAL = 5000
    private var processEnd = false

    suspend fun soeStopRecordAndEvaluate(): Map<String, Any?>? {
        // This might happen when onEndOfSpeech event is fired
        if(oral?.isRecording!!){
            oral!!.stopRecordAndEvaluation { error ->
                lastErrorCode = error.code
            }
        }
        // Wait until lastResult is ready (onEvaluationData event will set it)
        while(!processEnd) {
            delay(POLLING_INTERVAL)
        }
        return lastResult
    }

    fun soeStartRecord(refText: String, scoreCoeff: Double, mode: String, audioPath:String, applicationContext: Context): Map<String, Any?>? {
        init()
        oral!!.setListener(object : TAIOralEvaluationListener {
            // when evaluation result is ready
            override fun onEvaluationData(data: TAIOralEvaluationData, result: TAIOralEvaluationRet?, error: TAIError) {
                lastErrorCode = error.code
                if(!data.bEnd) return
                processEnd = true
                lastResult = if(error.code==TAIErrCode.SUCC){
                        mapOf("audioPath" to audioPath, "evaluationResult" to Gson().toJson(result?.sentenceInfoSet))
                    } else {
                        mapOf("error" to Gson().toJson(error))
                    }
            }

            // when no speech is detected, stop recording
            override fun onEndOfSpeech() {
                oral!!.stopRecordAndEvaluation { error ->
                    lastErrorCode = error.code
                }
            }

            // when volume changed
            override fun onVolumeChanged(volume: Int) {
                // we don't use this event yet
            }
        })
        //1.初始化参数
        val param = TAIOralEvaluationParam()
        param.context = applicationContext
        param.appId = "1303827440"
        param.soeAppId = "default"
        param.sessionId = UUID.randomUUID().toString()
        param.workMode = TAIOralEvaluationWorkMode.ONCE
        param.timeout = 5
        param.evalMode = evalModeFromString(mode)
        param.storageMode = TAIOralEvaluationStorageMode.DISABLE
        param.serverType = TAIOralEvaluationServerType.CHINESE
        param.fileType = TAIOralEvaluationFileType.MP3 //只支持mp3
        param.secretId = "AKIDorfD1yrBxYu3w2zWGj0aAXpzqPib3yKP"
        param.secretKey = "rSqCKqlO6cz5wRWKGdoNaY6SaR0PhtgF"
        param.scoreCoeff = scoreCoeff
        param.refText = refText
        param.audioPath = audioPath
        val recordParam = TAIRecorderParam()
        recordParam.vadEnable = true;
        recordParam.vadInterval = NO_SPEECH_DETECT_INTERVAL;
        oral!!.setRecorderParam(recordParam)
        //2.开始录制
        oral!!.startRecordAndEvaluation(param) {error ->
            //结果返回
            lastErrorCode = error.code
            lastResult = if(error.code==TAIErrCode.SUCC){
                null
            } else {
                mapOf("error" to Gson().toJson(error))
            }
        }
        return lastResult
    }

    private fun init() {
        oral = TAIOralEvaluation()
        lastErrorCode = null
        lastResult = null
        processEnd = false
    }

    private fun evalModeFromString(mode:String): Int {
        return when (mode) {
            "WORD" -> TAIOralEvaluationEvalMode.WORD
            "SENTENCE" -> TAIOralEvaluationEvalMode.SENTENCE
            "FREE" -> TAIOralEvaluationEvalMode.FREE
            "PARAGRAPH" -> TAIOralEvaluationEvalMode.PARAGRAPH
            "WORD_FIX" -> TAIOralEvaluationEvalMode.WORD_FIX
            "WORD_REALTIME" -> TAIOralEvaluationEvalMode.WORD_REALTIME
            "SCENE" -> TAIOralEvaluationEvalMode.SCENE
            "MULTI_BRANCH" -> TAIOralEvaluationEvalMode.MULTI_BRANCH
            // default
            else -> TAIOralEvaluationEvalMode.SENTENCE
        }
    }

}