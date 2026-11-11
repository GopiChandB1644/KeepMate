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
import kotlin.math.min

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val ENGINE_ID = "keepremind_engine"
        private const val PDF_CHANNEL = "com.keepremind.app/pdf_renderer"
        private const val LEGACY_PDF_CHANNEL = "com.keepmate.app/pdf_renderer"
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

