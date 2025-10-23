package com.example.myapp

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ir_service"
    private var irManager: ConsumerIrManager? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as ConsumerIrManager
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "transmitIR") {
                if (irManager == null || !irManager!!.hasIrEmitter()) {
                    result.error("NO_IR_BLASTER", "No IR blaster found on this device.", null)
                    return@setMethodCallHandler
                }

                val hexCode = call.argument<String>("code")
                if (hexCode != null) {
                    try {
                        val frequency = 38000 // Standard frequency for many IR devices
                        val pattern = hexToPattern(hexCode)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            irManager!!.transmit(frequency, pattern)
                            result.success(true)
                        } else {
                            result.error("UNSUPPORTED_SDK", "IR transmission not supported on this SDK version.", null)
                        }
                    } catch (e: Exception) {
                        result.error("TRANSMIT_FAILED", "Failed to transmit IR code: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "IR code cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // This function converts a hex string into an IR pulse pattern.
    // This is a simplified example for an NEC-like protocol.
    private fun hexToPattern(hex: String): IntArray {
        val pulses = mutableListOf<Int>()
        val longValue = hex.replace("0x", "", true).toLong(16)

        // NEC protocol timings in microseconds
        val headerOn = 9000
        val headerOff = 4500
        val bitOn = 560
        val zeroOff = 560
        val oneOff = 1690

        // Header
        pulses.add(headerOn)
        pulses.add(headerOff)

        // 32-bit data
        for (i in 31 downTo 0) {
            pulses.add(bitOn)
            if ((longValue shr i) and 1L == 1L) {
                pulses.add(oneOff) // Logical '1'
            } else {
                pulses.add(zeroOff) // Logical '0'
            }
        }

        // Final burst to mark end of frame
        pulses.add(bitOn)

        return pulses.toIntArray()
    }
}
