package com.keepremind.alarm

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log

class KeepRemindAlarmAudioPlayer(private val context: Context) {
    companion object {
        private const val TAG = "KeepRemindAlarmAudioPlayer"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var isPlaying = false

    @Synchronized
    fun start(vibrationEnabled: Boolean, customSoundUri: String? = null) {
        if (isPlaying) {
            Log.d(TAG, "Audio player is already running, skipping start")
            return
        }

        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager

        // 1. Request Audio Focus
        requestAudioFocus()

        // 2. Start Continuous Alarm Audio Playback
        try {
            val soundUri = resolveAlarmSoundUri(customSoundUri)
            mediaPlayer = MediaPlayer().apply {
                setDataSource(context, soundUri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = true
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                    stop()
                    true
                }
                prepare()
                start()
            }
            isPlaying = true
            Log.d(TAG, "Continuous alarm audio started with URI: $soundUri")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start primary alarm sound, attempting fallback", e)
            tryFallbackSound()
        }

        // 3. Start Rhythmic Vibration
        if (vibrationEnabled) {
            startVibration()
        }
    }

    private fun resolveAlarmSoundUri(customUriStr: String?): Uri {
        if (!customUriStr.isNullOrEmpty()) {
            try {
                val parsed = Uri.parse(customUriStr)
                if (parsed != null) return parsed
            } catch (e: Exception) {
                Log.w(TAG, "Could not parse custom sound URI: $customUriStr", e)
            }
        }
        var uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (uri == null) {
            uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        }
        if (uri == null) {
            uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        }
        return uri
    }

    private fun tryFallbackSound() {
        try {
            val fallbackUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            mediaPlayer = MediaPlayer().apply {
                setDataSource(context, fallbackUri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = true
                prepare()
                start()
            }
            isPlaying = true
            Log.d(TAG, "Fallback notification audio started successfully")
        } catch (fallbackEx: Exception) {
            Log.e(TAG, "Fallback audio also failed", fallbackEx)
        }
    }

    private fun requestAudioFocus() {
        val am = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(attrs)
                .build()
            am.requestAudioFocus(audioFocusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            am.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
        }
    }

    private fun abandonAudioFocus() {
        val am = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { am.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            am.abandonAudioFocus(null)
        }
    }

    private fun startVibration() {
        try {
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vibratorManager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }

            val pattern = longArrayOf(0, 800, 400, 800, 400, 800, 1000)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
            Log.d(TAG, "Rhythmic vibration started")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting vibration", e)
        }
    }

    @Synchronized
    fun stop() {
        Log.d(TAG, "Stopping alarm audio player and releasing resources")
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.reset()
                it.release()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing MediaPlayer", e)
        } finally {
            mediaPlayer = null
            isPlaying = false
        }

        try {
            vibrator?.cancel()
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling vibration", e)
        } finally {
            vibrator = null
        }

        abandonAudioFocus()
    }
}
