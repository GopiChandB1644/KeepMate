package com.keepmate.app.keepmate

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
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val ENGINE_ID = "keepmate_engine"
        private const val PDF_CHANNEL = "com.keepmate.app/pdf_renderer"
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { engine ->
            setupPdfChannel(engine)
            return engine
        }
        val engine = FlutterEngine(context.applicationContext)
        try {
            GeneratedPluginRegistrant.registerWith(engine)
        } catch (t: Throwable) {
            Log.e(TAG, "Error during plugin registration on FlutterEngine", t)
        }
        setupPdfChannel(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    private fun setupPdfChannel(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, PDF_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "renderFirstPage") {
                val pdfPath = call.argument<String>("path")
                if (pdfPath == null) {
                    result.error("INVALID_PATH", "Path is null", null)
                    return@setMethodCallHandler
                }
                try {
                    val rendered = renderPdfFirstPage(pdfPath)
                    result.success(rendered)
                } catch (e: Exception) {
                    Log.e(TAG, "renderPdfFirstPage failed", e)
                    result.error("RENDER_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun renderPdfFirstPage(pdfPath: String): String? {
        val file = File(pdfPath)
        if (!file.exists()) return null
        val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY) ?: return null
        val renderer = PdfRenderer(pfd)
        if (renderer.pageCount == 0) {
            renderer.close()
            pfd.close()
            return null
        }
        val page = renderer.openPage(0)
        // 2x scale for sharp OCR recognition in ML Kit
        val scale = 2
        val width = page.width * scale
        val height = page.height * scale
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(Color.WHITE)
        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
        page.close()
        renderer.close()
        pfd.close()

        val outFile = File(cacheDir, "pdf_render_${System.currentTimeMillis()}.jpg")
        FileOutputStream(outFile).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 92, out)
        }
        bitmap.recycle()
        return outFile.absolutePath
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
