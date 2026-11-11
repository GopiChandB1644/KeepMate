package com.keepmate.app.keepmate

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * MainActivity configured to preserve the FlutterEngine across Activity destruction.
 *
 * When the camera or system document picker opens on devices with aggressive memory
 * management (e.g. Vivo/Funtouch OS, Xiaomi/MIUI), the OS often destroys the background
 * Activity. By caching the FlutterEngine in [FlutterEngineCache] and setting
 * [shouldDestroyEngineWithHost] to false (following the movonride_driver reference architecture),
 * the Dart isolate, navigation stack, forms, and Cubit states remain intact.
 * When the camera returns, the Activity seamlessly re-attaches to the existing engine
 * without restarting the app or dropping the captured photo.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val ENGINE_ID = "keepmate_engine"
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { engine ->
            return engine
        }
        val engine = FlutterEngine(context.applicationContext)
        GeneratedPluginRegistrant.registerWith(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
