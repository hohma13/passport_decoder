package com.aloteq.passport_decoder

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Environment
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import com.aloteq.passport_decoder.data.Passport
import com.aloteq.passport_decoder.utils.KeyStoreUtils
import com.aloteq.passport_decoder.utils.NFCDocumentTag
import com.aloteq.passport_decoder.utils.NFCDocumentTag.PassportCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import io.reactivex.disposables.CompositeDisposable
import net.sf.scuba.smartcards.CardServiceException
import org.jmrtd.AccessDeniedException
import org.jmrtd.BACDeniedException
import org.jmrtd.MRTDTrustStore
import org.jmrtd.PACEException
import kotlin.collections.HashMap

/** PassportDecoderPlugin */
class PassportDecoderPlugin()
    : FlutterPlugin, ActivityAware, NewIntentListener, MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var channel: MethodChannel
    private lateinit var eventChanel: EventChannel
    private lateinit var applicationContext: Context
    private lateinit var activity: Activity
    private var events: EventSink? = null

    private var nfcAdapter: NfcAdapter? = null

    private var mrz: List<String> = emptyList()

    var disposable = CompositeDisposable()

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "passport_decoder")
        eventChanel = EventChannel(binding.binaryMessenger, "passport_decoder_events")
        applicationContext = binding.applicationContext
        channel.setMethodCallHandler(this)
        eventChanel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onNewIntent(intent: Intent?): Boolean {
        if (NfcAdapter.ACTION_TAG_DISCOVERED == intent?.action || NfcAdapter.ACTION_TECH_DISCOVERED == intent?.action) {
            // drop NFC events
            val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
            val folder = applicationContext.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)!!
            val keyStore = KeyStoreUtils().readKeystoreFromFile(folder)

            val mrtdTrustStore = MRTDTrustStore()
            if (keyStore != null) {
                val certStore = KeyStoreUtils().toCertStore(keyStore = keyStore)
                mrtdTrustStore.addAsCSCACertStore(certStore)
            }

            val subscribe = NFCDocumentTag().handleTag(
                    tag = tag!!,
                    documentNumber = mrz.elementAt(1),
                    dateOfBirth = mrz.elementAt(2),
                    dateOfExpiry = mrz.elementAt(0),
                    mrtdTrustStore = mrtdTrustStore,
                    passportCallback = object : PassportCallback {

                        override fun onPassportReadStart() {
                            Log.i("Plugin", "onPassportReadStart: start")
                            eventSuccess(result = mapOf(pair = Pair("PassportReadStart", "start")))
                        }

                        override fun onPassportReadFinish() {
                            eventSuccess(result = mapOf(pair = Pair("PassportReadFinish", "finish")))
                            Log.i("Plugin", "onPassportReadFinish: finish")
                        }

                        override fun onPassportRead(passport: Passport?) {
                            val personalDetail = passport?.personDetails
                            val additionalPersonDetails = passport?.additionalPersonDetails
                            var personalDetailMap: Map<String,Any> = emptyMap()
                            var additionalPersonDetailsMap: Map<String,Any> = emptyMap()
                            if (personalDetail != null)
                                personalDetailMap =  mapOf(pair = Pair("personalDetails", mapOf(pairs = *arrayOf(
                                        Pair("givenNames", "${personalDetail.primaryIdentifier}"),
                                        Pair("surname", "${personalDetail.secondaryIdentifier?.replace("<","")}"),
                                        Pair("gender", "${personalDetail.gender}"),
                                        Pair("nationality", "${personalDetail.nationality}"),
                                        Pair("dateOfBirth", "${personalDetail.dateOfBirth}"),
                                        Pair("documentNumber", "${personalDetail.documentNumber}"),
                                        Pair("documentCode", "${personalDetail.documentCode}"),
                                        Pair("dateOfExpiry", "${personalDetail.dateOfExpiry}")
                                ))))
                            if(additionalPersonDetails != null)
                                additionalPersonDetailsMap =  mapOf(pair = Pair("additionalPersonDetails", mapOf(pairs = *arrayOf(
                                        Pair("nameOfHolder", "${additionalPersonDetails.nameOfHolder}"),
                                        Pair("personalNumber", "${additionalPersonDetails.personalNumber}"),
                                        Pair("personalSummary", "${additionalPersonDetails.personalSummary}"),
                                        Pair("fullDateOfBirth", "${additionalPersonDetails.fullDateOfBirth}")
                                ))))

                                eventSuccess(result = personalDetailMap )
                            Log.i("Plugin", "onPassportRead: $passport")
                        }

                        override fun onAccessDeniedException(exception: AccessDeniedException) {
                            Log.i("Plugin", "onAccessDeniedException: $exception")
                            eventSuccess(result = mapOf(pair = Pair("AccessDeniedException", "start")))

//                            eventError(
//                                    details = "ex",
//                                    code = "500",
//                                    message = exception.message ?: "error"
//                            )

                        }

                        override fun onBACDeniedException(exception: BACDeniedException) {
                            Log.i("Plugin", "onBACDeniedException: $exception")
                            eventSuccess(result = mapOf(pair = Pair("BACDeniedException", "${exception.message}")))
//
//                            eventError(
//                                    details = "ex",
//                                    code = "500",
//                                    message = exception.message ?: "error"
//                            )
                        }

                        override fun onPACEException(exception: PACEException) {
                            Log.i("Plugin", "onPACEException: $exception")
                            eventSuccess(result = mapOf(pair = Pair("PACEException", "${exception.message}")))
//
//                            eventError(
//                                    details = "ex",
//                                    code = "500",
//                                    message = exception.message ?: "error"
//                            )
                        }

                        override fun onCardException(exception: CardServiceException) {
                            eventSuccess(result = mapOf(pair = Pair("CardServiceException", "${exception.message}")))
//
//                            eventError(
//                                    details = "ex",
//                                    code = "500",
//                                    message = exception.message ?: "error"
//                            )
                        }

                        override fun onGeneralException(exception: Exception?) {
                            Log.i("Plugin", "onGeneralException: $exception ")
                            eventSuccess(result = mapOf(pair = Pair("GeneralException", "${exception?.message}")))
//
//                            eventError(
//                                    details = "ex",
//                                    code = "500",
//                                    message = exception?.message ?: "error"
//                            )
                        }
                    }
            )
            disposable.add(subscribe)
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        disposable.dispose()
        nfcAdapter = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "getPassportData" -> result.success(startReadPassport(call))
            "readNfcSupported" -> result.success(nfcIsEnabled())
            "dispose" -> result.success(true)
            else -> result.notImplemented()
        }
    }


    private fun startReadPassport(call: MethodCall): Boolean {
        val arg = call.arguments
        if (arg is Map<*, *>) {
            mrz = arg.map { it.value.toString() }
        }
        nfcAdapter = NfcAdapter.getDefaultAdapter(applicationContext)
        val intent = Intent(activity.applicationContext, activity.javaClass)
        intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        val pendingIntent = PendingIntent.getActivity(activity.applicationContext, 0, intent, 0)
        val techList = arrayOf<Array<String>>()
        nfcAdapter?.enableForegroundDispatch(activity, pendingIntent, null, techList)

        if (nfcAdapter != null) return true
        return false
    }

    private fun nfcIsEnabled(): Boolean? {
        val adapter = NfcAdapter.getDefaultAdapter(applicationContext) ?: return false
        return adapter.isEnabled
    }

    override fun onListen(arguments: Any?, eventSink: EventSink?) {
        events = eventSink
    }

    override fun onCancel(arguments: Any?) {
        nfcAdapter?.disableForegroundDispatch(activity)
        events = null
    }

    private fun eventSuccess(result: Map<String, Any>) {
        val resultNew: HashMap<String, Any> = hashMapOf()
        resultNew.putAll(result)


        val mainThread = Handler(activity.mainLooper)
        val runnable = Runnable {
            if (events != null) {
                // Event stream must be handled on main/ui thread
                events!!.success(resultNew)
            }
        }
        mainThread.post(runnable)
    }

    private fun eventError(code: String, message: String, details: Any) {
        val mainThread = Handler(activity.mainLooper)
        val runnable = Runnable {
            if (events != null) {
                // Event stream must be handled on main/ui thread
                events!!.error(code, message, details)
            }
        }
        mainThread.post(runnable)
    }
}
