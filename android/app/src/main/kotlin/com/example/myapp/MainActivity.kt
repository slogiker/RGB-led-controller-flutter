
package com.example.myapp

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ir_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "transmitHex") {
                val hexCode = call.argument<String>("hexCode")
                val frequency = call.argument<Int>("frequency")
                if (hexCode != null && frequency != null) {
                    transmit(hexCode, frequency)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun transmit(hexCode: String, frequency: Int) {
        val irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as ConsumerIrManager
        if (!irManager.hasIrEmitter()) {
            return
        }

        // This is a generic implementation assuming a 32-bit hex code.
        // Real IR codes have specific timings for headers, bits, and repeats.
        // This might not work for all devices.
        val pattern = hexToPattern(hexCode)
        irManager.transmit(frequency, pattern)
    }

    private fun hexToPattern(hex: String): IntArray {
        // Assuming a common NEC-like protocol structure.
        // The timings are in microseconds.
        val headerOn = 9000
        val headerOff = 4500
        val bitOn = 560
        val zeroOff = 560
        val oneOff = 1690
        val pulses = mutableListOf<Int>()

        try {
            val longValue = hex.replace("0x", "", true).toLong(16)

            pulses.add(headerOn)
            pulses.add(headerOff)

            for (i in 31 downTo 0) {
                pulses.add(bitOn)
                if ((longValue shr i) and 1L == 1L) {
                    pulses.add(oneOff)
                } else {
                    pulses.add(zeroOff)
                }
            }
            pulses.add(bitOn) // Final burst to mark end of frame
        } catch (e: NumberFormatException) {
            // Handle cases where the hex string is invalid
            return intArrayOf()
        }


        return pulses.toIntArray()
    }
}
