package com.aloteq.passport_decoder

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.startActivity
import com.aloteq.passport_decoder.data.Passport
import com.aloteq.passport_decoder.utils.KeyStoreUtils
import com.aloteq.passport_decoder.utils.NFCDocumentTag
import com.aloteq.passport_decoder.utils.NFCDocumentTag.PassportCallback
import com.google.gson.Gson
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
                            eventSuccess(result = "{\"PassportReadStart\": \"start\"}")
                        }

                        override fun onPassportReadFinish() {
                            eventSuccess(result = "{\"PassportReadEnd\": \"end\"}")

                            Log.i("Plugin", "onPassportReadFinish: finish")
                        }

                        override fun onPassportRead(passport: Passport?) {
                            val json = Gson().toJson(passport)
                            eventSuccess(result = json)
                        }

                        override fun onAccessDeniedException(exception: AccessDeniedException) {
                            Log.e("Plugin", "onAccessDeniedException: $exception")
                            eventError(details = "ex", code = "500", message = exception.message
                                    ?: "error")
                        }

                        override fun onBACDeniedException(exception: BACDeniedException) {
                            Log.e("Plugin", "onBACDeniedException: $exception")
                            eventError(details = "ex", code = "500", message = exception.message
                                    ?: "error")
                        }

                        override fun onPACEException(exception: PACEException) {
                            Log.e("Plugin", "onPACEException: $exception")
                            eventError(details = "ex", code = "500", message = exception.message
                                    ?: "error")
                        }

                        override fun onCardException(exception: CardServiceException) {
                            Log.e("Plugin", "onCardException: $exception ")
                            eventError(details = "ex", code = "500", message = exception.message
                                    ?: "error")
                        }

                        override fun onGeneralException(exception: Exception?) {
                            Log.e("Plugin", "onGeneralException: $exception ")
                            eventError(details = "ex", code = "500", message = exception?.message
                                    ?: "error")
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
            "openNFCSettings" -> result.success(openNfcSettings())
            "dispose" -> result.success(dispose())
            else -> result.notImplemented()
        }
    }

    private fun openNfcSettings() :Boolean{
        val intent = Intent(Settings.ACTION_NFC_SETTINGS).apply {
            flags = FLAG_ACTIVITY_NEW_TASK
        }

        startActivity(applicationContext,intent, Bundle())
        return true
    }


    private fun startReadPassport(call: MethodCall): Boolean {
        val arg = call.arguments
        if (arg is Map<*, *>) {
            mrz = arg.map { it.value.toString() }
        }
        nfcAdapter = NfcAdapter.getDefaultAdapter(applicationContext)
        if (nfcAdapter == null) return false

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

    private fun dispose(): Boolean{
        nfcAdapter?.disableForegroundDispatch(activity)
        events = null
        return true
    }

    private fun eventSuccess(result: String) {
        val mainThread = Handler(activity.mainLooper)
        val runnable = Runnable {
            if (events != null) {
                // Event stream must be handled on main/ui thread
                events!!.success(result)
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
