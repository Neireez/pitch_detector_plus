package com.nixbees.pitch_detector_plus

import android.annotation.SuppressLint
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel.EventSink

class AudioCaptureStreamHandler {
    private var actualSampleRate: Int = 0
    private var audioSource: Int = MediaRecorder.AudioSource.DEFAULT
    private var isCapturing: Boolean = false
    private var thread: Thread? = null
    private var _events: EventSink? = null
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    val sampleRate: Int = 44100
    val bufferSize: Int = 1120

    companion object {
        private const val TAG: String = "AudioCaptureStream"
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_FLOAT
    }

    fun setEventSink(sink: EventSink) {
        _events = sink
    }

    fun startRecording() {
        if (thread != null) return

        isCapturing = true
        val runnableObj = Runnable { record() }
        thread = Thread(runnableObj)
        thread?.start()
    }

    fun stopRecording() {
        if (thread == null) return
        isCapturing = false

        actualSampleRate = 1 // -> we are currently stopping
        thread?.join(5000)
        thread = null
        actualSampleRate = 2 // -> we are stopped
    }

    private fun sendError(key: String?, msg: String?) {
        uiThreadHandler.post {
            if (isCapturing) {
                _events?.error(key, msg, null)
            }
        }
    }

    private fun sendBuffer(audioBuffer: ArrayList<FloatArray>, bufferIndex: Int) {
        uiThreadHandler.post(object : Runnable {
            var index: Int = -1

            override fun run() {
                if (isCapturing) {
                    _events?.success(
                        mapOf(
                            "data" to audioBuffer[index],
                            "type" to "PITCH_RAW_DATA"
                        )
                    )
                }
            }

            fun init(idx: Int): Runnable {
                this.index = idx
                return this
            }

        }.init(bufferIndex))
    }

    @SuppressLint("MissingPermission")
    private fun record() {
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO)

//        val bufferSize: Int = 812//AudioRecord.getMinBufferSize(sampleRate, CHANNEL_CONFIG, AUDIO_FORMAT)
        val bufferCount = 2
        var bufferIndex = 0
        val audioBuffer = ArrayList<FloatArray>()
        val record: AudioRecord = AudioRecord.Builder()
            .setAudioSource(audioSource)
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AUDIO_FORMAT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(CHANNEL_CONFIG)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize)
            .build()

        for (i in 1..bufferCount) {
            audioBuffer.add(FloatArray(bufferSize))
        }

        if (record.state != AudioRecord.STATE_INITIALIZED) {
            sendError("AUDIO_RECORD_INITIALIZE_ERROR", "AudioRecord can't initialize")
        }

        record.startRecording()

        actualSampleRate = record.sampleRate

        while (record.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
            Thread.yield()
        }

        while (isCapturing) {
            try {
                record.read(audioBuffer[bufferIndex], 0, audioBuffer[bufferIndex].size, AudioRecord.READ_BLOCKING)
                sendBuffer(audioBuffer, bufferIndex)
            } catch (e: Exception) {
                Log.d(TAG, e.toString())
                sendError("AUDIO_RECORD_READ_ERROR", "AudioRecord can't read")
                Thread.yield()
            }
            bufferIndex = (bufferIndex + 1) % bufferCount
        }

        record.stop()
        record.release()
    }
}