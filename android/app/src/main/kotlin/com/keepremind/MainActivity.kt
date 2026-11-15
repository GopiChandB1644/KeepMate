package com.keepremind

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.keepremind.alarm.KeepRemindAlarmModel
import com.keepremind.alarm.KeepRemindAlarmScheduler
import com.keepremind.alarm.KeepRemindAlarmService
import com.keepremind.alarm.KeepRemindAlarmStorage
import android.os.Build
import android.content.Intent
import java.io.File
import java.io.FileOutputStream
import kotlin.math.min

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val ENGINE_ID = "keepremind_engine"
        private const val PDF_CHANNEL = "com.keepremind.app/pdf_renderer"
        private const val LEGACY_PDF_CHANNEL = "com.keepmate.app/pdf_renderer"
        private const val ALARM_CHANNEL = "com.keepremind.app/alarm_manager"
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { engine ->
            setupPdfChannel(engine)
            setupAlarmChannel(engine)
            return engine
        }
        val engine = FlutterEngine(context.applicationContext)
        try {
            GeneratedPluginRegistrant.registerWith(engine)
        } catch (t: Throwable) {
            Log.e(TAG, "Error during plugin registration on FlutterEngine", t)
        }
        setupPdfChannel(engine)
        setupAlarmChannel(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupPdfChannel(flutterEngine)
        setupAlarmChannel(flutterEngine)
    }

    private fun setupAlarmChannel(engine: FlutterEngine) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val medicineId = call.argument<String>("medicineId") ?: ""
                        val medicineName = call.argument<String>("medicineName") ?: ""
                        val dosage = call.argument<String>("dosage") ?: ""
                        val mealInstruction = call.argument<String>("mealInstruction") ?: ""
                        val doseTime = call.argument<String>("doseTime") ?: ""
                        val triggerTimestamp = (call.argument<Number>("triggerTimestamp"))?.toLong() ?: 0L
                        val snoozeMinutes = call.argument<Int>("snoozeMinutes") ?: 5
                        val maxDurationMinutes = call.argument<Int>("maxDurationMinutes") ?: 10
                        val vibrationEnabled = call.argument<Boolean>("vibrationEnabled") ?: true
                        val soundUri = call.argument<String>("soundUri")

                        val model = KeepRemindAlarmModel(
                            id = id,
                            medicineId = medicineId,
                            medicineName = medicineName,
                            dosage = dosage,
                            mealInstruction = mealInstruction,
                            doseTime = doseTime,
                            triggerTimestamp = triggerTimestamp,
                            snoozeMinutes = snoozeMinutes,
                            maxDurationMinutes = maxDurationMinutes,
                            vibrationEnabled = vibrationEnabled,
                            soundUri = soundUri
                        )
                        val success = KeepRemindAlarmScheduler.scheduleAlarm(this, model)
                        result.success(success)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in scheduleAlarm", e)
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    KeepRemindAlarmScheduler.cancelAlarm(this, id)
                    result.success(true)
                }
                "cancelMedicineAlarms" -> {
                    val medicineId = call.argument<String>("medicineId") ?: ""
                    KeepRemindAlarmScheduler.cancelAlarmsForMedicine(this, medicineId)
                    result.success(true)
                }
                "cancelAllAlarms" -> {
                    KeepRemindAlarmScheduler.cancelAllAlarms(this)
                    result.success(true)
                }
                "stopActiveAlarm" -> {
                    val stopIntent = Intent(this, KeepRemindAlarmService::class.java).apply {
                        action = KeepRemindAlarmService.ACTION_STOP_ALARM
                    }
                    startService(stopIntent)
                    result.success(true)
                }
                "canScheduleExactAlarms" -> {
                    val can = KeepRemindAlarmScheduler.canScheduleExactAlarms(this)
                    result.success(can)
                }
                "canUseFullScreenIntent" -> {
                    val can = KeepRemindAlarmScheduler.canUseFullScreenIntent(this)
                    result.success(can)
                }
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = android.net.Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SETTINGS_ERROR", e.message, null)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "getPendingAlarmActions" -> {
                    val storage = KeepRemindAlarmStorage(this)
                    val actions = storage.getPendingActions()
                    result.success(actions)
                }
                "removePendingAlarmAction" -> {
                    val actionId = call.argument<String>("actionId") ?: ""
                    KeepRemindAlarmStorage(this).removePendingAction(actionId)
                    result.success(true)
                }
                "clearPendingAlarmActions" -> {
                    KeepRemindAlarmStorage(this).clearPendingActions()
                    result.success(true)
                }
                "getPendingNativeAlarms" -> {
                    val storage = KeepRemindAlarmStorage(this)
                    val alarms = storage.getAllAlarms().map { it.toJson().toString() }
                    result.success(alarms)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setupPdfChannel(engine: FlutterEngine) {
        val handler = MethodChannel.MethodCallHandler { call, result ->
            when (call.method) {
                "renderPages" -> {
                    val pdfPath = call.argument<String>("path")
                    val maxPages = call.argument<Int>("maxPages") ?: 4
                    if (pdfPath == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@MethodCallHandler
                    }
                    try {
                        val renderedList = renderPdfPages(pdfPath, maxPages)
                        result.success(renderedList)
                    } catch (e: Exception) {
                        Log.e(TAG, "renderPdfPages failed", e)
                        result.error("RENDER_FAILED", e.message, null)
                    }
                }
                "renderFirstPage" -> {
                    val pdfPath = call.argument<String>("path")
                    if (pdfPath == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@MethodCallHandler
                    }
                    try {
                        val rendered = renderPdfFirstPage(pdfPath)
                        result.success(rendered)
                    } catch (e: Exception) {
                        Log.e(TAG, "renderPdfFirstPage failed", e)
                        result.error("RENDER_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(engine.dartExecutor.binaryMessenger, PDF_CHANNEL).setMethodCallHandler(handler)
        MethodChannel(engine.dartExecutor.binaryMessenger, LEGACY_PDF_CHANNEL).setMethodCallHandler(handler)
    }

    private fun renderPdfPages(pdfPath: String, maxPages: Int): List<String> {
        val file = File(pdfPath)
        if (!file.exists()) return emptyList()
        val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY) ?: return emptyList()
        val renderer = PdfRenderer(pfd)
        val pageCount = renderer.pageCount
        if (pageCount == 0) {
            renderer.close()
            pfd.close()
            return emptyList()
        }

        val renderedPaths = mutableListOf<String>()
        val pagesToRender = min(pageCount, maxPages)
        val timestamp = System.currentTimeMillis()

        try {
            for (i in 0 until pagesToRender) {
                val page = renderer.openPage(i)
                // 2x scale for sharp recognition in Google ML Kit OCR
                val scale = 2
                val width = page.width * scale
                val height = page.height * scale
                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                bitmap.eraseColor(Color.WHITE)
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                page.close()

                val outFile = File(cacheDir, "pdf_render_${timestamp}_page_$i.jpg")
                FileOutputStream(outFile).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 92, out)
                }
                bitmap.recycle()
                renderedPaths.add(outFile.absolutePath)
            }
        } finally {
            renderer.close()
            pfd.close()
        }

        return renderedPaths
    }

    private fun renderPdfFirstPage(pdfPath: String): String? {
        val pages = renderPdfPages(pdfPath, 1)
        return pages.firstOrNull()
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
